local function IsGoalToBlueBaby()
	local hasPolaroid = BISAI_PLUS.GameUtils.HasCollectible(CollectibleType.COLLECTIBLE_POLAROID)
	local hasNegative = BISAI_PLUS.GameUtils.HasCollectible(CollectibleType.COLLECTIBLE_NEGATIVE)
	local isBlueBabyGoal = BISAI_PLUS.Data.Save.Goal == BISAI_PLUS.Shared.Goal.BLUE_BABY
	local isChestMegaSatanGoal = not hasNegative
		and hasPolaroid
		and BISAI_PLUS.Data.Save.Goal == BISAI_PLUS.Shared.Goal.MEGA_SATAN
	return isBlueBabyGoal or isChestMegaSatanGoal
end

local function IsGoalToLamb()
	local hasPolaroid = BISAI_PLUS.GameUtils.HasCollectible(CollectibleType.COLLECTIBLE_POLAROID)
	local hasNegative = BISAI_PLUS.GameUtils.HasCollectible(CollectibleType.COLLECTIBLE_NEGATIVE)
	local isLambGoal = BISAI_PLUS.Data.Save.Goal == BISAI_PLUS.Shared.Goal.LAMB
	local isDarkRoomMegaSatanGoal = not hasPolaroid
		and hasNegative
		and BISAI_PLUS.Data.Save.Goal == BISAI_PLUS.Shared.Goal.MEGA_SATAN
	return isLambGoal or isDarkRoomMegaSatanGoal
end

local function IsGoalToSpecial()
	return BISAI_PLUS.Data.Save.Goal == BISAI_PLUS.Shared.Goal.HUSH
		or BISAI_PLUS.Data.Save.Goal == BISAI_PLUS.Shared.Goal.ULTRA_GREED
		or BISAI_PLUS.Data.Save.Goal == BISAI_PLUS.Shared.Goal.DELIRIUM
end

local function OnUpdate()
	local room = Game():GetRoom()
	local level = Game():GetLevel()

	-- 是否是妈心的凹凸房
	local isInEntranceRoom = level:GetCurrentRoomIndex() == GridRooms.ROOM_BLUE_WOOM_IDX
	if isInEntranceRoom then
		return
	end

	-- 是否是能上天堂、下地狱的层
	local isFateDecided = BISAI_PLUS.GameUtils.IsFateDecided(level)
	if not isFateDecided then
		return
	end

	if IsGoalToBlueBaby() or IsGoalToSpecial() then
		BISAI_PLUS.GameUtils.ReplaceTrapDoor(room)
	end
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

	local level = Game():GetLevel()
	local isFateDecided = BISAI_PLUS.GameUtils.IsFateDecided(level)

	-- 是否是能上天堂、下地狱的层
	if not isFateDecided then
		return
	end

	if IsGoalToLamb() or IsGoalToSpecial() then
		return BISAI_PLUS.GameUtils.ReplaceHeavenDoor(position)
	end
end

BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_UPDATE, OnUpdate)
BISAI_PLUS:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, OnEntitySpawn)
