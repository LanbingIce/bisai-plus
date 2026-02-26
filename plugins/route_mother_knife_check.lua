---@param level Level
---@param stage1 LevelStage
---@param stage2 LevelStage
---@return boolean
local function IsSpecificRepentanceStage(level, stage1, stage2)
	local stageType = level:GetStageType()
	-- 确保是支线层 (忏悔DLC新增的层)
	local isRepentanceStage = stageType == StageType.STAGETYPE_REPENTANCE
		or stageType == StageType.STAGETYPE_REPENTANCE_B
	if not isRepentanceStage then
		return false
	end

	local stage = level:GetStage()
	local isXLCurse = level:GetCurses() & LevelCurse.CURSE_OF_LABYRINTH ~= 0

	-- 指定章节的第二层
	if stage == stage2 then
		return true
	end

	-- 指定章节的第一层且是合并层
	if stage == stage1 and isXLCurse then
		return true
	end

	return false
end

---@param level Level
---@return boolean
local function IsKnifePiece1Level(level)
	return IsSpecificRepentanceStage(level, LevelStage.STAGE1_1, LevelStage.STAGE1_2)
end

---@param level Level
---@return boolean
local function IsKnifePiece2Level(level)
	return IsSpecificRepentanceStage(level, LevelStage.STAGE2_1, LevelStage.STAGE2_2)
end

local function OnUpdate()
	local room = Game():GetRoom()
	local level = Game():GetLevel()

	local isMotherGoal = BISAI_PLUS.Data.Save.Goal == BISAI_PLUS.Shared.Goal.MOTHER

	if not isMotherGoal then
		return
	end

	--  没有剧情刀就关闭
	local isInSecretExitRoom = room:GetType() == RoomType.ROOM_SECRET_EXIT
	if not isInSecretExitRoom then
		return
	end
	local isNeedClose = false

	if IsKnifePiece1Level(level) then
		local hasPiece1 = BISAI_PLUS.GameUtils.HasCollectible(CollectibleType.COLLECTIBLE_KNIFE_PIECE_1)
		if not hasPiece1 then
			isNeedClose = true
		end
	elseif IsKnifePiece2Level(level) then
		local hasPiece2 = BISAI_PLUS.GameUtils.HasCollectible(CollectibleType.COLLECTIBLE_KNIFE_PIECE_2)
		if not hasPiece2 then
			isNeedClose = true
		end
	end

	if not isNeedClose then
		return
	end

	local trapdoors = BISAI_PLUS.GameUtils.FindTrapdoor(room)
	for i = 1, #trapdoors do
		local trapdoor = trapdoors[i]

		BISAI_PLUS.GameUtils.CloseTrapdoor(trapdoor)
	end
end

BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_UPDATE, OnUpdate)
