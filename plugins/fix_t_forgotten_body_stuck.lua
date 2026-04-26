local function OnPlayerUpdate(_, player)
	-- 确保是里骨哥的本体
	if player:GetPlayerType() ~= PlayerType.PLAYER_THEFORGOTTEN_B then
		return
	end

	-- Visible为false，说明在被灵魂举着
	local isHeld = not player.Visible

	-- 速度如果不为0，说明还没落地
	local isVelocityZero = math.abs(player.Velocity.X) < 0.0001 and math.abs(player.Velocity.Y) < 0.0001

	-- 确保没有被举着，并且落地了
	if isHeld or not isVelocityZero then
		return
	end

	local room = Game():GetRoom()
	local gridIndex = room:GetGridIndex(player.Position)
	local currentGrid = room:GetGridEntity(gridIndex)

	local isStuck = false

	-- 碰撞检测：是否在柱子里，或者被挤出房间外
	if currentGrid and currentGrid:GetType() == GridEntityType.GRID_PILLAR then
		isStuck = true
	elseif not room:IsPositionInRoom(player.Position, 0) then
		isStuck = true
	end

	if isStuck then
		-- 使用一次召回
		player:UseActiveItem(CollectibleType.COLLECTIBLE_RECALL)
	end
end

BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, OnPlayerUpdate)
