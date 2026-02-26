local function OnPlayerUpdate(_, player)
	if not BISAI_PLUS.GameUtils.IsRealPlayer(player) then
		return
	end
	-- 为大撒旦终点添加钥匙
	if
		BISAI_PLUS.Data.Save.State == BISAI_PLUS.Shared.State.RUNNING
		and BISAI_PLUS.Data.Save.Goal == BISAI_PLUS.Shared.Goal.MEGA_SATAN
	then
		if not player:HasCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_1) then
			player:AddCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_1)
		end
		if not player:HasCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_2) then
			player:AddCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_2)
		end
	end
end

BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, OnPlayerUpdate)
