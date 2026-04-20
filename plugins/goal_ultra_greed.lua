-- 箱子的Variant没有一个共用的值，所以只能列出所有的箱子Variant来判断了
local chestVariants = {
	[PickupVariant.PICKUP_CHEST] = true, -- 普通箱子
	[PickupVariant.PICKUP_BOMBCHEST] = true, -- 石头箱子
	[PickupVariant.PICKUP_SPIKEDCHEST] = true, -- 刺箱
	[PickupVariant.PICKUP_ETERNALCHEST] = true, -- 白箱子
	[PickupVariant.PICKUP_MIMICCHEST] = true, -- 伪装刺箱子
	[PickupVariant.PICKUP_OLDCHEST] = true, -- 旧箱子
	[PickupVariant.PICKUP_WOODENCHEST] = true, -- 木箱子
	[PickupVariant.PICKUP_MEGACHEST] = true, -- 大金箱
	[PickupVariant.PICKUP_HAUNTEDCHEST] = true, -- 幽灵箱
	[PickupVariant.PICKUP_LOCKEDCHEST] = true, -- 金箱子
	[PickupVariant.PICKUP_REDCHEST] = true, -- 红箱子
}

-- 清除房间内的箱子皮和空道具底座
local function ClearRoomRemnants()
	-- 搜索当前房间内的所有SubType是0的掉落物实体
	-- 因为被玩家拾取的道具底座和打开的箱子的SubType会变为0
	local pickups = Isaac.FindByType(EntityType.ENTITY_PICKUP, -1, 0, true, true)
	for i = 1, #pickups do
		local variant = pickups[i].Variant
		-- 是否是箱子或者是道具底座
		local isRemnant = variant == PickupVariant.PICKUP_COLLECTIBLE or chestVariants[variant]

		if not isRemnant then
			return
		end
		-- 如果确实是道具底座或者是箱子，就把它移除掉
		pickups[i]:Remove()
	end
end

local function IsUltraGreedRoom()
	local goal = BISAI_PLUS.Data.Save.Goal
	if goal ~= BISAI_PLUS.Shared.Goal.ULTRA_GREED then
		return false
	end

	return BISAI_PLUS.Shared.GoalData[goal].IsStage() and BISAI_PLUS.Shared.GoalData[goal].IsRoom()
end

local function OnNPCUpdate(_, npc)
	-- 确保实体是大贪婪
	if npc.Type ~= EntityType.ENTITY_ULTRA_GREED then
		return
	end
	-- 确保是大贪婪终点
	if BISAI_PLUS.Data.Save.Goal ~= BISAI_PLUS.Shared.Goal.ULTRA_GREED then
		return
	end

	-- 确保是普通难度
	if Game().Difficulty ~= Difficulty.DIFFICULTY_NORMAL then
		return
	end

	repeat -- 大贪婪一阶段死亡后召唤二阶段的处理
		-- Variant：0 表示大贪婪一阶段
		if npc.Variant ~= 0 then
			break
		end
		local sprite = npc:GetSprite()

		-- 大贪婪一阶段死亡动画播放完后，会播放Final动画
		if not sprite:IsPlaying("Final") then
			break
		end

		if sprite:GetFrame() == 0 then
			-- 防止游戏减速情况下，动画多次播放第0帧，导致多次召唤
			sprite:SetFrame(1)
			-- Final开始播放时，召唤大贪婪二阶段的实体并隐藏（因为召唤时是Idle状态）
			local greed2 =
				Game():Spawn(EntityType.ENTITY_ULTRA_GREED, 1, npc.Position, Vector.Zero, nil, 0, npc.InitSeed)
			greed2.Visible = false
		else
			-- 下一帧把一阶段的大贪婪移除
			-- 此时二阶段已经取消隐藏，所以动画可以正常衔接
			npc:Remove()
		end

	until true

	repeat -- 大贪婪二阶段动画处理
		-- Variant：1 表示大贪婪二阶段
		if npc.Variant ~= 1 then
			break
		end
		local sprite = npc:GetSprite()
		-- Idle(已隐藏)->Hanging(已隐藏)->BreakFreeShort ->Appearing(被跳过)-> 正常状态
		-- 召唤出来的第一帧是Idle，已经被隐藏了不会显示出来
		-- 第二帧会变成Hanging（上吊），立刻跳到BreakFreeShort状态（雕像震动，砸地）
		if sprite:IsPlaying("Hanging") then
			sprite:Play("BreakFreeShort", true)
			npc.Visible = true
			-- 究极贪婪上吊会增加15%的血量和血量上限，一阶段会上吊，血量3500->4025，没有问题
			-- 二阶段并不会上吊，因此2500血量是正常的
			-- 但是直接用代码召唤二阶段贪婪，也会触发上吊
			-- 因此需要手动把增加的血量去掉
			npc.HitPoints = 2500
			npc.MaxHitPoints = 2500
		elseif sprite:IsPlaying("Appearing") and sprite:GetFrame() < 30 then
			-- Appearing状态（上吊的大贪婪跳下来的动画）直接跳过
			-- 需要判断当前不是第30帧，防止游戏在减速的情况下重复设置，重复设置会让大贪婪卡住
			sprite:SetFrame(30)
			-- 已经跳过了Appearing状态，取消隐藏状态
			npc.Visible = true
		elseif sprite:IsPlaying("BreakFreeShort") and sprite:GetFrame() >= 78 then
			-- BreakFreeShort状态结束后（79帧之后）会导致AI异常，因此必须在第79帧跳到Appearing状态
			-- 游戏在加速状态下（兴奋药，坏表）时，第78帧结束之后就会导致AI异常，因此需要在第78帧就跳
			sprite:Play("Appearing", true)
			-- 隐藏Appearing状态，防止贴图违和，只隐藏1帧，人眼基本看不出来
			npc.Visible = false
		end
	until true
end

local function OnUpdate()
	-- 大贪婪路线踩下按钮召唤大贪婪
	if not IsUltraGreedRoom() then
		return
	end

	local room = Game():GetRoom()
	local grid = room:GetGridEntity(67)

	if not grid then
		return
	end

	-- 确保对应位置上面有按钮
	if grid:GetType() ~= GridEntityType.GRID_PRESSURE_PLATE then
		return
	end

	-- VarData为1表示已经召唤了大贪婪
	if grid.VarData == 1 then
		return
	end

	-- State为3表示按钮被踩下
	if grid.State ~= 3 then
		return
	end

	-- VarData为1表示已经召唤了大贪婪
	grid.VarData = 1
	-- 强行把门全部删除
	for i = 0, DoorSlot.NUM_DOOR_SLOTS - 1 do
		room:RemoveDoor(i)
	end

	-- 清除箱子皮和空道具底座
	ClearRoomRemnants()

	-- 位置和贪婪模式的生成位置一样
	local pos = room:GetGridPosition(127)
	-- 种子用当前房间的生成种子
	local seed = room:GetSpawnSeed()
	-- 生成大贪婪
	Game():Spawn(EntityType.ENTITY_ULTRA_GREED, 0, pos, Vector.Zero, nil, 0, seed)
	-- 将房间设为未清理状态
	room:SetClear(false)

	local music = MusicManager()
	music:Crossfade(Music.MUSIC_ULTRAGREED_BOSS)
end

local function OnNewRoom()
	-- 遍历当前游戏中的所有角色，清除他们的上瘾标记
	for i = 0, Game():GetNumPlayers() - 1 do
		local player = Game():GetPlayer(i)
		local data = player:GetData()
		data.BisaiPlus_IsAddicted = nil
	end

	-- 大贪婪终点，凹凸房间生成按钮
	if not IsUltraGreedRoom() then
		return
	end

	-- 如果有奖杯，不生成按钮
	local trophys = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TROPHY, 0, true, true)
	if #trophys > 0 then
		return
	end
	local room = Game():GetRoom()
	-- 先移除原来的按钮
	room:RemoveGridEntity(67, 0, false)
	room:Update()
	-- Variant 3表示矿层的黄色按钮
	room:SpawnGridEntity(67, GridEntityType.GRID_PRESSURE_PLATE, 3, 1, 0)
end

local function OnStarUpdate(_, star)
	if not IsUltraGreedRoom() then
		return
	end

	-- 锁定伯利恒的位置
	star.Velocity = Vector.Zero
	local room = Game():GetRoom()
	star.Position = room:GetCenterPos()

	if star.Visible then
		return
	end
	-- 如果伯利恒进入凹凸房间了，移除并重新生成一个
	-- TODO：找一个更好的解决方案
	star:Remove()
	Game():Spawn(
		EntityType.ENTITY_FAMILIAR,
		FamiliarVariant.STAR_OF_BETHLEHEM,
		star.Position,
		Vector.Zero,
		nil,
		0,
		star.InitSeed
	)
end

local function OnClearAward()
	if not IsUltraGreedRoom() then
		return
	end
	local music = MusicManager()
	music:Crossfade(Music.MUSIC_BOSS_OVER)
end

-- 将究极贪婪的大多数招式的伤害变成半血伤，最大限度还原贪婪模式下的究极贪婪
local function OnEntityTakeDamage(_, entity, amount, damageFlags, source, countdownFrames)
	-- 确保是在大贪婪房间内
	if not IsUltraGreedRoom() then
		return
	end

	-- 确保受伤的是角色
	local player = entity:ToPlayer()
	if not player then
		return
	end

	-- 确保角色没有吃上瘾药
	if player:GetData().BisaiPlus_IsAddicted then
		return
	end

	-- 确保角色没有圣饼
	if player:HasCollectible(CollectibleType.COLLECTIBLE_WAFER) then
		return
	end

	-- 确保角色没有圣饼效果
	if player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_WAFER) then
		return
	end

	-- 确保伤害来源是实体
	local sourceEntity = source.Entity
	if not sourceEntity then
		return
	end

	local entityType = sourceEntity.Type
	local entityVariant = sourceEntity.Variant

	local finalDamage = amount

	if entityType == EntityType.ENTITY_ULTRA_GREED then -- 究极贪婪
		if damageFlags & DamageFlag.DAMAGE_CRUSH == DamageFlag.DAMAGE_CRUSH then -- 二阶段地裂波
			finalDamage = 1
		elseif damageFlags & DamageFlag.DAMAGE_EXPLOSION == DamageFlag.DAMAGE_EXPLOSION then -- 二阶段爆炸
			finalDamage = 1
		elseif damageFlags & DamageFlag.DAMAGE_LASER == DamageFlag.DAMAGE_LASER then -- 二阶段硫磺火
			finalDamage = 1
		else -- 都不是，返回
			return
		end
	elseif entityType == EntityType.ENTITY_GREED_GAPER then -- 钥匙硬币开出的痴汉
		finalDamage = sourceEntity.CollisionDamage
	elseif entityType == EntityType.ENTITY_KEEPER then -- 召唤的贪婪头
		finalDamage = sourceEntity.CollisionDamage
	elseif entityType == EntityType.ENTITY_PROJECTILE then -- 怪物的子弹
		if
			entityVariant == ProjectileVariant.PROJECTILE_COIN
			and damageFlags & DamageFlag.DAMAGE_EXPLOSION == DamageFlag.DAMAGE_EXPLOSION
		then -- 二阶段的爆炸子弹
			finalDamage = 1
		else -- 其他子弹
			finalDamage = sourceEntity.CollisionDamage
		end
	elseif entityType == EntityType.ENTITY_ULTRA_COIN then -- 究极贪婪召唤的四种硬币
		finalDamage = 1
	end

	if amount ~= finalDamage then
		player:TakeDamage(finalDamage, damageFlags | DamageFlag.DAMAGE_NO_MODIFIERS, source, countdownFrames)
		return false
	end
end

local function OnUsePill(_, pillEffect, player, useFlags)
	-- 确保是在大贪婪房间内
	if not IsUltraGreedRoom() then
		return
	end
	-- 吃到上瘾药，打一个标记
	if pillEffect ~= PillEffect.PILLEFFECT_ADDICTED then
		return
	end
	player:GetData().BisaiPlus_IsAddicted = true
end

BISAI_PLUS:AddCallback(ModCallbacks.MC_NPC_UPDATE, OnNPCUpdate)
BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_UPDATE, OnUpdate)
BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, OnNewRoom)
BISAI_PLUS:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, OnClearAward)
BISAI_PLUS:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, OnStarUpdate, FamiliarVariant.STAR_OF_BETHLEHEM)
BISAI_PLUS:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, OnEntityTakeDamage)
BISAI_PLUS:AddCallback(ModCallbacks.MC_USE_PILL, OnUsePill)
