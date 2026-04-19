local function OnUseItem(_, item, rng, player, flags, slot, varData)
	-- 确保是真正的角色，而不是小罗饰品或者店长稻草人之类的
	if not BISAI_PLUS.GameUtils.IsRealPlayer(player) then
		return
	end

	-- 确保使用的道具是D4
	if item ~= CollectibleType.COLLECTIBLE_D4 then
		return
	end

	-- 排除骰子房效果(一/六点)
	if flags & UseFlag.USE_REMOVEACTIVE == UseFlag.USE_REMOVEACTIVE then
		return
	end

	-- 排除有七巧板的情况
	if player:HasCollectible(CollectibleType.COLLECTIBLE_MISSING_NO) then
		return
	end

	-- 生成一个混沌魂火
	local itemWisp = (
		Game():Spawn(
			EntityType.ENTITY_FAMILIAR,
			FamiliarVariant.ITEM_WISP,
			Vector.Zero,
			Vector.Zero,
			player,
			CollectibleType.COLLECTIBLE_CHAOS,
			1
		)

	)
	-- 令这个魂火无碰撞箱
	itemWisp.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE

	-- 下一帧，移除这个魂火
	BISAI_PLUS.Dispatcher:Dispatch(function()
		if not itemWisp then
			return
		end
		itemWisp:Kill()
	end)
end

BISAI_PLUS:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, OnUseItem)