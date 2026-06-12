local function HasQueuedMissingNo(player)
	local item = player.QueuedItem.Item

	if not item then
		return false
	end

	return item.ID == CollectibleType.COLLECTIBLE_MISSING_NO
end

local function OnPreUseD4(_, item, rng, player, flags, slot, varData)
	-- 确保是真正的角色，而不是小罗饰品或者店长稻草人之类的
	if not BISAI_PLUS.GameUtils.IsRealPlayer(player) then
		return
	end

	-- 排除骰子房效果(一/六点)
	if flags & UseFlag.USE_REMOVEACTIVE == UseFlag.USE_REMOVEACTIVE then
		return
	end

	-- 排除七巧板
	if flags & UseFlag.USE_NOANIM == UseFlag.USE_NOANIM then
		-- 情况A：下层时的七巧板触发 (房间帧数为0)
		if Game():GetRoom():GetFrameCount() == 0 then
			return
		end

		-- 情况B：拾取时的七巧板触发
		local data = player:GetData()

		if data.BisaiPlus_HasQueuedMissingNo and not HasQueuedMissingNo(player) then
			data.BisaiPlus_HasQueuedMissingNo = nil
			return
		end
	end

	-- 生成一个混沌魂火
	local itemWisp = (
		Game():Spawn(
			EntityType.ENTITY_FAMILIAR,
			FamiliarVariant.ITEM_WISP,
			Vector.Zero,
			Vector.Zero,
			player,
			CollectibleType.COLLECTIBLE_CHAOS,
			1
		)

	)
	-- 令这个魂火无碰撞箱
	itemWisp.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE

	-- 令这个魂火不可见
	itemWisp.Visible = false

	local data = player:GetData()
	data.BisaiPlus_ChaosWisps = data.BisaiPlus_ChaosWisps or {}
	table.insert(data.BisaiPlus_ChaosWisps, itemWisp)
end

local function OnUseD4(_, item, rng, player, flags, slot, varData)
	if not BISAI_PLUS.GameUtils.IsRealPlayer(player) then
		return
	end

	local data = player:GetData()
	if data.BisaiPlus_ChaosWisps then
		for _, wisp in ipairs(data.BisaiPlus_ChaosWisps) do
			wisp:Kill()
			SFXManager():Stop(SoundEffect.SOUND_STEAM_HALFSEC)
		end
		data.BisaiPlus_ChaosWisps = nil
	end
end

local function OnPostPlayerUpdate(_, player)
	if not HasQueuedMissingNo(player) then
		return
	end
	local data = player:GetData()

	data.BisaiPlus_HasQueuedMissingNo = true
end

BISAI_PLUS:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, OnPreUseD4, CollectibleType.COLLECTIBLE_D4)
BISAI_PLUS:AddCallback(ModCallbacks.MC_USE_ITEM, OnUseD4, CollectibleType.COLLECTIBLE_D4)
BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, OnPostPlayerUpdate)
