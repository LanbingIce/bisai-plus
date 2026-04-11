local function OnPlayerUpdate(_, player)
	-- 确保是大撒旦终点
	if BISAI_PLUS.Data.Save.Goal ~= BISAI_PLUS.Shared.Goal.MEGA_SATAN then
		return
	end

	-- 确保是RUNNING状态
	if BISAI_PLUS.Data.Save.State ~= BISAI_PLUS.Shared.State.RUNNING then
		return
	end

	-- 确保是真正的角色，而不是小罗饰品或者店长稻草人之类的
	if not BISAI_PLUS.GameUtils.IsRealPlayer(player) then
		return
	end

	-- 为角色添加钥匙碎片1
	if not player:HasCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_1) then
		player:AddCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_1)
	end

	-- 为角色添加钥匙碎片2
	if not player:HasCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_2) then
		player:AddCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_2)
	end
end

BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, OnPlayerUpdate)
