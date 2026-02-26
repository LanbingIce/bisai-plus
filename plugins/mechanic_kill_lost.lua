local LOST_HEART_LIMIT = 12
local function KillLostIfNeeded(player)
	if not BISAI_PLUS.GameUtils.IsRealPlayer(player) then
		return
	end
	-- 如果没有血量，说明是狂暴状态，不需要手动处死
	if player:GetSoulHearts() < 1 then
		return
	end

	-- 确保是lost
	local playerType = player:GetPlayerType()
	local isLost = playerType == PlayerType.PLAYER_THELOST or playerType == PlayerType.PLAYER_THELOST_B
	if not isLost then
		return
	end

	-- 确保碎心已满
	if LOST_HEART_LIMIT > player:GetBrokenHearts() then
		return
	end

	-- 处死lost，伤害来源是lost自己，伤害类型是计时器伤害
	local isBerserk = player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_BERSERK)
	if isBerserk then
		-- 狂暴状态下让lost受伤，狂暴状态结束之后就会自动死掉
		-- WONTFIX 这种情况下会触发受伤触发的道具效果
		player:TakeDamage(1, DamageFlag.DAMAGE_TIMER, EntityRef(player), 0)
	else
		-- 非狂暴状态下直接调用Kill方法，避免触发受伤触发的道具效果
		player:Kill()
	end
end

local function OnNewRoom()
	-- lost切换房间时，如果碎心满了，手动处死
	-- WONTFIX 和其他角色不同：使用主动以及拾取物品等情况不会处死lost

	local num = Game():GetNumPlayers()
	for i = 0, num - 1 do
		local player = Isaac.GetPlayer(i)
		KillLostIfNeeded(player)
	end
end

BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, OnNewRoom)
