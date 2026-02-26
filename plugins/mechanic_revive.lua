local function OnPlayerUpdate(_, player)
	if not BISAI_PLUS.GameUtils.IsRealPlayer(player) then
		return
	end
	-- 结算成绩之后，防止玩家死掉
	if BISAI_PLUS.Data.Save.State ~= BISAI_PLUS.Shared.State.FINISHED then
		return
	end

	if not player:IsDead() then
		return
	end

	player:Revive()
end

BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, OnPlayerUpdate)
