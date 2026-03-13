-- 获得失忆症药丸时，立刻将其识别
local function OnPlayerUpdate(_, player)
	-- 确保是真正的角色
	if not BISAI_PLUS.GameUtils.IsRealPlayer(player) then
		return
	end

	local pillColor = player:GetPill(0)

	-- 确保手中是药丸
	if pillColor == PillColor.PILL_NULL then
		return
	end

	local itemPool = Game():GetItemPool()

	-- 确保没有被识别过
	if itemPool:IsPillIdentified(pillColor) then
		return
	end

	-- 确保是失忆症药丸
	if itemPool:GetPillEffect(pillColor) ~= PillEffect.PILLEFFECT_AMNESIA then
		return
	end

	itemPool:IdentifyPill(pillColor)
end

BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, OnPlayerUpdate)
