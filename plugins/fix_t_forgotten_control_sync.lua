local function OnPlayerUpdate(_, player)
	-- 确保是里骨哥的灵魂
	if player:GetPlayerType() ~= PlayerType.PLAYER_THESOUL_B then
		return
	end

	-- 确保是无法控制的状态
	if player:AreControlsEnabled() then
		return
	end

	-- 获取本体
	local mainPlayer = player:GetOtherTwin()

	if not mainPlayer then
		return
	end

	-- 为本体增加一帧的无法控制时间
	mainPlayer:AddControlsCooldown(1)
end

BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, OnPlayerUpdate)
