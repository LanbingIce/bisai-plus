-- 如果选手误入其他终点的最终BOSS房间，那么禁止生成大宝箱，改为生成一个虚空传送门
local function OnClearAward(_, _, spawnPosition)
	-- 如果是当前终点的最终BOSS房间，直接返回，不处理
	local currentGoal = BISAI_PLUS.Data.Save.Goal
	local isCurrentGoalFinalBoss = BISAI_PLUS.Shared.GoalData[currentGoal].IsStage()
		and BISAI_PLUS.Shared.GoalData[currentGoal].IsRoom()

	if isCurrentGoalFinalBoss then
		return
	end

	-- 如果是百变怪房间，直接返回，不处理
	local isDeliriumRoom = BISAI_PLUS.Shared.GoalData[BISAI_PLUS.Shared.Goal.DELIRIUM].IsStage()
		and BISAI_PLUS.Shared.GoalData[BISAI_PLUS.Shared.Goal.DELIRIUM].IsRoom()

	if isDeliriumRoom then
		return
	end

	-- 只处理这些其他终点
	local otherGoals = {
		BISAI_PLUS.Shared.Goal.MEGA_SATAN,
		BISAI_PLUS.Shared.Goal.MOTHER,
		BISAI_PLUS.Shared.Goal.BEAST,
		BISAI_PLUS.Shared.Goal.LAMB,
		BISAI_PLUS.Shared.Goal.BLUE_BABY,
	}

	-- 检查是否是其他终点的最终BOSS房间
	local isOtherGoalFinalBoss = false

	for _, goal in ipairs(otherGoals) do
		local goalData = BISAI_PLUS.Shared.GoalData[goal]
		if goalData.IsStage() and goalData.IsRoom() then
			isOtherGoalFinalBoss = true
			break
		end
	end

	if isOtherGoalFinalBoss then
		-- 禁用通关剧情和宝箱并生成一个虚空门
		local room = Game():GetRoom()
		local gridIndex = room:GetGridIndex(spawnPosition)
		room:SpawnGridEntity(gridIndex, GridEntityType.GRID_TRAPDOOR, 1, 1, 1)
		return true
	end
end

BISAI_PLUS:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, OnClearAward)
