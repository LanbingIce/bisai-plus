local function OnUseItem(_, collectibleID, rngObj, player, useFlags, activeSlot, varData)
	if not BISAI_PLUS.GameUtils.IsRealPlayer(player) then
		return
	end

	-- WONTFIX 少数情况下，不是破传触发的传送（例如咒币）也会导致移除破传（甚至移除金破传）
	-- 修改破传效果：触发时掉落在地上
	-- 确保触发了蓝传
	if collectibleID ~= CollectibleType.COLLECTIBLE_TELEPORT then
		return
	end

	-- 确保是无动画使用
	if useFlags ~= UseFlag.USE_NOANIM then
		return
	end

	-- 确保是虚拟主动
	if activeSlot ~= -1 then
		return
	end
	-- 移除破传，并在地面上生成
	BISAI_PLUS.GameUtils.DropTrinket(player, TrinketType.TRINKET_BROKEN_REMOTE)
end

BISAI_PLUS:AddCallback(ModCallbacks.MC_USE_ITEM, OnUseItem)
