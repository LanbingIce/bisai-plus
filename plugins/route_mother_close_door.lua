--- 判断本层是否应该删除活板门
---@return boolean
local function ShouldRemoveTrapdoor()
	local level = Game():GetLevel()
	local stage = level:GetStage() -- 获取 STAGE1_1, STAGE1_2 等枚举值
	local stageType = level:GetStageType() -- 获取场景类型 (区分主线/支线)
	local curses = level:GetCurses()

	-- 判断是否为主线 (0,1,2)
	local isMainRoute = (
		stageType == StageType.STAGETYPE_ORIGINAL
		or stageType == StageType.STAGETYPE_WOTL
		or stageType == StageType.STAGETYPE_AFTERBIRTH
	)

	-- 判断是否为支线 (4,5 - 忏悔新路线)
	local isBranchRoute = (stageType == StageType.STAGETYPE_REPENTANCE or stageType == StageType.STAGETYPE_REPENTANCE_B)
	-- 判断是否为 XL (迷宫诅咒)
	local isXL = (curses & LevelCurse.CURSE_OF_LABYRINTH) ~= 0

	-- 判断是否为该章节的"第二层" (利用枚举值直接判断)
	-- STAGE1_2, STAGE2_2, STAGE3_2 分别对应 2, 4, 6
	local isSecondFloor = (stage == LevelStage.STAGE1_2 or stage == LevelStage.STAGE2_2 or stage == LevelStage.STAGE3_2)

	-- =======================================================
	-- 2. 逻辑分支
	-- =======================================================

	-- 【第四章节及以后】 (Womb/Corpse/Sheol...)
	-- 对应 STAGE4_1 (7) 及以上
	-- 逻辑：全部不删
	if stage >= LevelStage.STAGE4_1 then
		return false
	end

	-- 【主线路线】 (Main Route)
	if isMainRoute then
		-- 这里的特殊情况是第三章 (Depths/Necropolis)
		if stage == LevelStage.STAGE3_1 or stage == LevelStage.STAGE3_2 then
			-- 主线第三章逻辑：
			-- 1层(STAGE3_1 非XL) -> 删
			-- 2层(STAGE3_2) -> 不删
			-- XL (STAGE3_1 带XL) -> 不删

			if isSecondFloor then
				return false
			end -- 2层保留
			if isXL then
				return false
			end -- XL保留
			return true -- 1层删除
		else
			-- 主线第一、二章 (Basement/Caves)：
			-- 无论 1层、2层 还是 XL，全是"删除"
			return true
		end
	end

	-- 【支线路线】 (Repentance Route - 下水道/矿坑/陵墓)
	if isBranchRoute then
		-- 支线逻辑在 1, 2, 3 章是统一的：
		-- 1层 (STAGE_X_1 非XL) -> 不删
		-- 2层 (STAGE_X_2) -> 删
		-- XL (STAGE_X_1 带XL) -> 删

		if isSecondFloor then
			return true
		end -- 2层删除
		if isXL then
			return true
		end -- XL删除
		return false -- 1层保留
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

	local isMotherGoal = BISAI_PLUS.Data.Save.Goal == BISAI_PLUS.Shared.Goal.MOTHER
	if not isMotherGoal then
		return
	end
	-- 防止创世纪逃跑

	if ShouldRemoveTrapdoor() then
		return BISAI_PLUS.GameUtils.ReplaceHeavenDoor(position)
	end
end

---@param level Level
---@param room Room
---@return boolean
local function IsInMomRoomAfterRottenHeart(level, room)
	-- 判断是否在击杀了腐化妈心后的妈腿房间
	local roomName = level:GetCurrentRoomDesc().Data.Name
	if roomName ~= "Mom (mausoleum)" then
		return false
	end
	-- 击杀腐化妈心之后，妈腿房间不会有通往腐化妈心的门，由此可以判断是否击杀了腐化妈心
	for i = 0, DoorSlot.NUM_DOOR_SLOTS - 1 do
		local door = room:GetDoor(i)
		if door and door:IsRoomType(RoomType.ROOM_BOSS) then
			return false
		end
	end
	return true
end

local function OnUpdate()
	local room = Game():GetRoom()
	local level = Game():GetLevel()

	local isMotherGoal = BISAI_PLUS.Data.Save.Goal == BISAI_PLUS.Shared.Goal.MOTHER

	-- 保证见证者路线不脚滑下层

	if not isMotherGoal then
		return
	end

	-- 支线门里的房间不关闭活板门
	local isInSecretExitRoom = room:GetType() == RoomType.ROOM_SECRET_EXIT
	if isInSecretExitRoom then
		return
	end

	-- 如果击杀了腐化妈心，并且在腐化妈腿房间，不关闭活板门
	if IsInMomRoomAfterRottenHeart(level, room) then
		return
	end

	if ShouldRemoveTrapdoor() then
		local trapdoors = BISAI_PLUS.GameUtils.FindTrapdoor(room)
		for i = 1, #trapdoors do
			local trapdoor = trapdoors[i]
			if room:GetType() == RoomType.ROOM_BOSS then
				BISAI_PLUS.GameUtils.CloseTrapdoor(trapdoor)
			else
				BISAI_PLUS.GameUtils.ReplaceWithPortalTeleport(trapdoor)
			end
		end
	end
end

BISAI_PLUS:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, OnEntitySpawn)
BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_UPDATE, OnUpdate)
