---@param level Level
---@return boolean
local function IsNormalMomLevel(level)
	-- 确保没有在回溯
	if level:IsAscent() then
		return false
	end
	-- 判断是否是普通妈腿层
	local stageType = level:GetStageType()

	-- 大于2不是主线，不可能是妈腿
	if stageType > StageType.STAGETYPE_AFTERBIRTH then
		return false
	end
	local stage = level:GetStage()

	-- 主线第三章第二层必定是妈腿
	if stage == LevelStage.STAGE3_2 then
		return true
	end

	-- 主线第三章XL诅咒必定是妈腿
	local hasXLCurse = level:GetCurses() & LevelCurse.CURSE_OF_LABYRINTH ~= 0
	if hasXLCurse and stage == LevelStage.STAGE3_1 then
		return true
	end
	return false
end

---@param level Level
---@return boolean
local function IsPreMomLevel(level)
	-- 确保没有在回溯
	if level:IsAscent() then
		return false
	end
	-- 判断是否是普通妈腿层的上一层
	local stage = level:GetStage()
	local stageType = level:GetStageType()
	local isXLCurse = level:GetCurses() & LevelCurse.CURSE_OF_LABYRINTH ~= 0

	-- 主线层逻辑（非忏悔支线）
	local isMainPath = stageType <= StageType.STAGETYPE_AFTERBIRTH
	if isMainPath then
		-- 主线层逻辑：第三章第一层且非XL
		if stage == LevelStage.STAGE3_1 and not isXLCurse then
			return true
		end
	else
		-- 支线层逻辑：第二章节的第二层
		if stage == LevelStage.STAGE2_2 then
			return true
		end

		-- 支线层逻辑：第二章节的第一层是合并层
		if stage == LevelStage.STAGE2_1 and isXLCurse then
			return true
		end
	end

	return false
end

local function OnEntitySpawn(_, type, variant, subType, position, velocity, spawner, seed)
	-- 天堂光柱
	-- subType是1的话，是月亮的光柱
	local isHeavenLightDoor = type == EntityType.ENTITY_EFFECT
		and variant == EffectVariant.HEAVEN_LIGHT_DOOR
		and subType == 0

	if not isHeavenLightDoor then
		return
	end

	-- 防止创世纪逃跑
	local isBeastGoal = BISAI_PLUS.Data.Save.Goal == BISAI_PLUS.Shared.Goal.BEAST
	if not isBeastGoal then
		return
	end

	local level = Game():GetLevel()
	-- 确保在普通妈腿层
	if not IsNormalMomLevel(level) then
		return
	end

	return BISAI_PLUS.GameUtils.ReplaceHeavenDoor(position)
end

-- 防止进入陵墓
local function PreventMausoleumEntry(level, room)
	-- 确保是普通妈腿的上一层
	if not IsPreMomLevel(level) then
		return
	end

	-- 确保在支线门里面
	local isInSecretExitRoom = room:GetType() == RoomType.ROOM_SECRET_EXIT
	if not isInSecretExitRoom then
		return
	end

	-- 把支线门里面的活板门关闭
	local trapdoors = BISAI_PLUS.GameUtils.FindTrapdoor(room)
	for i = 1, #trapdoors do
		local trapdoor = trapdoors[i]
		BISAI_PLUS.GameUtils.CloseTrapdoor(trapdoor)
	end
end

-- 防止在妈腿层误入下层（只能走回溯门）
local function PreventNextLevelExit(level, room)
	-- 确保是普通妈腿层
	if not IsNormalMomLevel(level) then
		return
	end

	-- 保护妈腿层下回溯的房间（不受限制）
	if room:GetType() == RoomType.ROOM_SECRET_EXIT then
		return
	end

	local trapdoors = BISAI_PLUS.GameUtils.FindTrapdoor(room)
	for i = 1, #trapdoors do
		local trapdoor = trapdoors[i]
		if room:GetType() == RoomType.ROOM_BOSS then
			-- BOSS房的下层门关闭
			BISAI_PLUS.GameUtils.CloseTrapdoor(trapdoor)
		else
			-- 禁止其他下层活板门（替换为传送门）
			BISAI_PLUS.GameUtils.ReplaceWithPortalTeleport(trapdoor)
		end
	end
end

local function OnUpdate()
	-- 大霍恩终点妈腿层防止下层
	if BISAI_PLUS.Data.Save.Goal ~= BISAI_PLUS.Shared.Goal.BEAST then
		return
	end
	local level = Game():GetLevel()
	local room = Game():GetRoom()

	PreventMausoleumEntry(level, room)
	PreventNextLevelExit(level, room)
end

BISAI_PLUS:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, OnEntitySpawn)
BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_UPDATE, OnUpdate)
