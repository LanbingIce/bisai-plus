local function OnClearAward(_, _, spawnPosition)
	-- 百变怪房间始终生成奖杯
	local isInDeliriumRoom = BISAI_PLUS.Shared.GoalData[BISAI_PLUS.Shared.Goal.DELIRIUM].IsRoom()
	if not isInDeliriumRoom then
		return
	end
	Game():Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TROPHY, spawnPosition, Vector.Zero, nil, 0, 1)
	return true
end

BISAI_PLUS:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, OnClearAward)
