local TIME_LIMIT_NORMAL = 30 * 60 * 1000 -- 30分钟

---@param player EntityPlayer
---@return integer
local function GetMaxHeartLimit(player)
	local playerType = player:GetPlayerType()
	if playerType == PlayerType.PLAYER_THEFORGOTTEN then
		return 6
	elseif playerType == PlayerType.PLAYER_THESOUL then
		return 6
	elseif
		playerType == PlayerType.PLAYER_MAGDALENE and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)
	then
		return 18
	else
		return 12
	end
end

---@param player EntityPlayer
local function UpdateDamage(player)
	player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
	player:EvaluateItems()
end

-- 内部辅助函数：更新玩家及其子实体的伤害
---@param player EntityPlayer
local function UpdateTotalDamage(player)
	UpdateDamage(player)
	local subPlayer = player:GetSubPlayer()
	if subPlayer then
		UpdateDamage(subPlayer)
	end
end

---@param player EntityPlayer
---@param targetAmount integer
local function AddBrokenHeartStep(player, targetAmount)
	local data = player:GetData()
	data.BisaiPlus_TargetBrokenHearts = targetAmount
	-- 1. 检查是否已达到或超过目标
	if player:GetBrokenHearts() >= targetAmount then
		return
	end

	-- 2. 检查生命上限，如果没有位置了则跳过
	if player:GetHeartLimit() == 0 then
		return
	end

	-- 3. 添加一个碎心
	player:AddBrokenHearts(1)

	-- 4. 刷新属性
	UpdateTotalDamage(player)
	Game():ShakeScreen(5)
end

---@param player EntityPlayer
local function TrimExcessHealth(player)
	-- 计算角色的常规血上限的上限
	local maxHeartLimit = GetMaxHeartLimit(player)
	local currentBrokenHearts = player:GetBrokenHearts()

	local playerType = player:GetPlayerType()
	-- 只有表骨哥的本体碎心不会自动挤掉骨心，手动移除一下
	if playerType == PlayerType.PLAYER_THEFORGOTTEN then
		local currentBoneHearts = player:GetBoneHearts()
		local currentHealth = player:GetHearts()
		-- 甚至骨心移除的时候有时候不会失去红心，手动移除一下
		if currentHealth > currentBoneHearts * 2 then
			player:AddHearts(-1)
		end
		if currentBrokenHearts + currentBoneHearts > maxHeartLimit then
			player:AddBoneHearts(-1)
		end
	end

	-- 如果当前的碎心还没达到上限，则不执行清理逻辑
	if currentBrokenHearts < maxHeartLimit then
		return
	end

	-- 过滤掉没有常规血量逻辑的角色

	if playerType == PlayerType.PLAYER_THELOST or playerType == PlayerType.PLAYER_THELOST_B then
		return
	end

	if player:GetSoulHearts() > 0 then
		player:AddSoulHearts(-1)
	end
end

---@param player EntityPlayer
---@param totalTargetHearts integer
local function EnsureBrokenHearts(player, totalTargetHearts)
	if totalTargetHearts <= 0 then
		return
	end

	local playerType = player:GetPlayerType()
	local mainBody = player
	local soulPart = nil

	-- 1. 识别并归一化骨哥的本体与灵魂
	if playerType == PlayerType.PLAYER_THEFORGOTTEN then
		soulPart = player:GetSubPlayer()
	elseif playerType == PlayerType.PLAYER_THESOUL then
		mainBody = player:GetSubPlayer()
		soulPart = player
	end

	-- 2. 计算碎心分配逻辑
	-- 如果是骨哥，先灵魂后本体，奇数碎心优先给灵魂
	local bodyTarget = totalTargetHearts
	local soulTarget = 0

	if soulPart then
		soulTarget = (totalTargetHearts + 1) // 2
		bodyTarget = totalTargetHearts // 2
	end

	-- 3. 执行添加逻辑
	-- 处理本体
	TrimExcessHealth(mainBody)
	AddBrokenHeartStep(mainBody, bodyTarget)

	-- 处理灵魂（如果存在）
	if soulPart then
		TrimExcessHealth(soulPart)
		AddBrokenHeartStep(soulPart, soulTarget)
	end
end

local function OnPlayerUpdate(_, player)
	if not BISAI_PLUS.GameUtils.IsRealPlayer(player) then
		return
	end
	local targetBrokenHearts = 0

	local totalMS

	if BISAI_PLUS.Data.Save.State == BISAI_PLUS.Shared.State.RUNNING then
		local current_time = Isaac.GetTime()
		local elapsed = current_time - BISAI_PLUS.Data.Runtime.Timer.StartTime
		totalMS = BISAI_PLUS.Data.Save.Timer.StoredTime + elapsed
	else
		totalMS = BISAI_PLUS.Data.Save.Timer.StoredTime
	end

	local timerOverflow = totalMS - TIME_LIMIT_NORMAL
	if timerOverflow < 0 then
		return
	end
	targetBrokenHearts = 1 + timerOverflow // 1000 // 30

	local data = player:GetData()
	repeat --根据TargetBrokenHearts加碎心
		-- 如果角色正在死亡，给2.5秒的冷却时间，结束之后再进行碎心添加
		local sprite = player:GetSprite()
		if sprite:IsPlaying("Death") or sprite:IsPlaying("LostDeath") or sprite:IsPlaying("ForgottenDeath") then
			data.BisaiPlus_BrokenHeartCooldown = 150
		end

		-- 死亡复活期间，不进行碎心的添加，防止反复去世
		if data.BisaiPlus_BrokenHeartCooldown then
			data.BisaiPlus_BrokenHeartCooldown = data.BisaiPlus_BrokenHeartCooldown - 1
			if data.BisaiPlus_BrokenHeartCooldown < 1 then
				data.BisaiPlus_BrokenHeartCooldown = nil
			end
			break
		end

		if BISAI_PLUS.Data.Save.State ~= BISAI_PLUS.Shared.State.RUNNING then
			break
		end

		EnsureBrokenHearts(player, targetBrokenHearts)

	until true
end

BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, OnPlayerUpdate)
