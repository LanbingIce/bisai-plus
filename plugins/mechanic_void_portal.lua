-- 在小蓝人、羔羊、超级撒旦终点的教堂/阴间，如果没有对应的全家福/底片，通关宝箱被替换为虚空门
local function OnPickupInit(_, pickup)
	-- 确保拾取物是大宝箱
	if pickup.Variant ~= PickupVariant.PICKUP_BIGCHEST then
		return
	end

	local goal = BISAI_PLUS.Data.Save.Goal
	local isTargetGoal = goal == BISAI_PLUS.Shared.Goal.BLUE_BABY
		or goal == BISAI_PLUS.Shared.Goal.LAMB
		or goal == BISAI_PLUS.Shared.Goal.MEGA_SATAN
		or goal == BISAI_PLUS.Shared.Goal.MOTHER

	-- 确保是小蓝人、羔羊、超级撒旦终点之一
	if not isTargetGoal then
		return
	end

	local level = Game():GetLevel()

	-- 确保当前是第10层（教堂/阴间）
	if level:GetStage() ~= LevelStage.STAGE5 then
		return
	end

	local stageType = level:GetStageType()
	-- 阴间 (stageType == StageType.STAGETYPE_ORIGINAL)
	-- 教堂 (stageType == StageType.STAGETYPE_WOTL)
	local isSheol = stageType == StageType.STAGETYPE_ORIGINAL
	local isCathedral = stageType == StageType.STAGETYPE_WOTL

	local hasNegative = BISAI_PLUS.GameUtils.HasCollectible(CollectibleType.COLLECTIBLE_NEGATIVE)
	local hasPolaroid = BISAI_PLUS.GameUtils.HasCollectible(CollectibleType.COLLECTIBLE_POLAROID)

	-- 在地狱且有底片，不需要替换
	if isSheol and hasNegative then
		return
	end

	-- 在天堂且有全家福，不需要替换
	if isCathedral and hasPolaroid then
		return
	end

	local room = Game():GetRoom()
	local gridIndex = room:GetGridIndex(pickup.Position)
	-- 移除原有的通关宝箱
	pickup:Remove()
	-- 生成虚空传送门
	room:SpawnGridEntity(gridIndex, GridEntityType.GRID_TRAPDOOR, 1, 1, 1)
end

BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, OnPickupInit)
