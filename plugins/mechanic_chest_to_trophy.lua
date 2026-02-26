local function OnPickupInit(_, pickup)
	local level = Game():GetLevel()
	local stage = level:GetStage()
	-- 确保不是天堂、地狱
	if stage == LevelStage.STAGE5 then
		return
	end

	-- 将通关大宝箱替换为奖杯
	if pickup.Variant == PickupVariant.PICKUP_BIGCHEST then
		pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TROPHY, 0, true, true, true)
	end
end

BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, OnPickupInit)
