local function OnPickupInit(_, pickup)
	local negative = BISAI_PLUS.Data.Save.Goal == BISAI_PLUS.Shared.Goal.LAMB
	local polaroid = BISAI_PLUS.Data.Save.Goal == BISAI_PLUS.Shared.Goal.BLUE_BABY

	if pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE then
		-- 全家福->底片
		if negative and pickup.SubType == CollectibleType.COLLECTIBLE_POLAROID then
			pickup:Morph(
				EntityType.ENTITY_PICKUP,
				PickupVariant.PICKUP_COLLECTIBLE,
				CollectibleType.COLLECTIBLE_NEGATIVE,
				true,
				true,
				true
			)
		end

		-- 底片->全家福
		if polaroid and pickup.SubType == CollectibleType.COLLECTIBLE_NEGATIVE then
			pickup:Morph(
				EntityType.ENTITY_PICKUP,
				PickupVariant.PICKUP_COLLECTIBLE,
				CollectibleType.COLLECTIBLE_POLAROID,
				true,
				true,
				true
			)
		end
	end
end

BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, OnPickupInit)
