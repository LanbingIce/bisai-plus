local Dispatcher = BISAI_PLUS.Dispatcher
local GameUtils = BISAI_PLUS.GameUtils
local function OnPickupCollision(_, pickup, collider, low)
	local player = collider:ToPlayer()

	if not player then
		return
	end

	-- WONTFIX 如果是金咒币，会掉落成普通版本，金咒币没有特殊效果，所以没啥区别
	-- 修改咒币效果：触发时，让咒币掉落在地上
	-- 确保是硬币
	if pickup.Variant ~= PickupVariant.PICKUP_COIN then
		return
	end

	-- 如果角色是里骨哥的魂，则采用其本体
	if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B and player:GetOtherTwin() then
		player = player:GetOtherTwin()
	end

	-- 确保是真正的角色
	if not GameUtils.IsRealPlayer(player) then
		return
	end

	-- 确保没有黑蜡烛
	if player:HasCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE) then
		return
	end

	-- 确保不是黏币
	if pickup.SubType == CoinSubType.COIN_STICKYNICKEL then
		return
	end

	-- 确保有咒币
	if not player:HasTrinket(TrinketType.TRINKET_CURSED_PENNY) then
		return
	end

	-- 下一帧将咒币移除并掉落在地上
	Dispatcher:Dispatch(function()
		GameUtils.DropTrinket(player, TrinketType.TRINKET_CURSED_PENNY)
	end)
end

BISAI_PLUS:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, OnPickupCollision)
