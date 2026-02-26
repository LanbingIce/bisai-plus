local function OnPlayerUpdate(_, player)
	local state = BISAI_PLUS.Data.Save.State
	-- WONTFIX 表骨哥在此时依然可以在本体和灵魂之间切换
	repeat -- 准备阶段和暂停状态禁止任何角色操作
		local isPaused = state == BISAI_PLUS.Shared.State.PAUSED or state == BISAI_PLUS.Shared.State.READY
		if not isPaused then
			break
		end
		player:AddControlsCooldown(1)
	until true
end

BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, OnPlayerUpdate)
