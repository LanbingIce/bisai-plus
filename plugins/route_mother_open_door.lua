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

local function TryOpenBranchDoors()
	local room = Game():GetRoom()

	-- 见证者路线开启所有带锁的门
	local isMotherGoal = BISAI_PLUS.Data.Save.Goal == BISAI_PLUS.Shared.Goal.MOTHER

	if not isMotherGoal then
		return
	end

	if room:GetType() ~= RoomType.ROOM_BOSS then
		return
	end

	local level = Game():GetLevel()
	local stage = level:GetStage()
	local stageType = level:GetStageType()

	local isBranchRoute = (stageType == StageType.STAGETYPE_REPENTANCE or stageType == StageType.STAGETYPE_REPENTANCE_B)
	local isFirstChapter = (stage == LevelStage.STAGE1_1 or stage == LevelStage.STAGE1_2)

	-- 如果玩家不处于支线层也不是在第一章节，则绝不自动开门
	if not isBranchRoute and not isFirstChapter then
		return
	end

	-- 新需求：如果当前是下水道/污水坑(第二章)，只有在持有碎片1时才自动开门
	if
		IsKnifePiece1Level(level)
		and not BISAI_PLUS.GameUtils.HasCollectible(CollectibleType.COLLECTIBLE_KNIFE_PIECE_1)
	then
		return
	end

	-- 新需求：如果当前是矿洞/灰坑(第三章)，只有在持有碎片2时才自动开门
	if
		IsKnifePiece2Level(level)
		and not BISAI_PLUS.GameUtils.HasCollectible(CollectibleType.COLLECTIBLE_KNIFE_PIECE_2)
	then
		return
	end

	local roomName = level:GetCurrentRoomDesc().Data.Name
	local isMomRoom = roomName == "Mom (mausoleum)"

	-- 腐化妈腿房间（陵墓/狱炎）的肉门（通往尸骸）永远不应该被插件自动打开。
	-- 1. 如果玩家有完整刀，必须由玩家亲自把刀扔刺到门上。
	-- 2. 如果玩家没有刀，门应当保持锁死，从而触发 close_door 插件的“死胡同判定”放行普通活板门。
	if isMomRoom then
		return
	end

	for i = 0, DoorSlot.NUM_DOOR_SLOTS - 1 do
		local door = room:GetDoor(i)
		if door and door:IsLocked() and door:TryUnlock(Game():GetPlayer(0), true) then
			break
		end
	end
end

local function OnClearAward(_, _, spawnPosition)
	TryOpenBranchDoors()
end

local function OnNewRoom()
	local room = Game():GetRoom()
	if not room:IsClear() then
		return
	end
	TryOpenBranchDoors()
end

BISAI_PLUS:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, OnClearAward)
BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, OnNewRoom)
