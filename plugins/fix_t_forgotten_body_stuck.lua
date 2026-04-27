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
	local w = room:GetGridWidth()

	-- 包含自身(0)在内的九宫格偏移量
	local offsets = { 0, -w - 1, -w, -w + 1, -1, 1, w - 1, w, w + 1 }
	local isStuck = false

	-- 扫描九宫格
	for _, offset in ipairs(offsets) do
		local checkEnt = room:GetGridEntity(gridIndex + offset)
		if checkEnt and checkEnt:GetType() == GridEntityType.GRID_PILLAR then
			-- 核心：不管你在哪个格子上，只要你离这个柱子的中心距离 <= 25，说明你物理上卡进去了
			if player.Position:Distance(checkEnt.Position) <= 25 then
				isStuck = true
				break
			end
		end
	end

	if isStuck then
		-- 使用一次召回
		player:UseActiveItem(CollectibleType.COLLECTIBLE_RECALL)
	end
end

BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, OnPlayerUpdate)
