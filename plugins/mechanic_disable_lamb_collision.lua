-- 掉落奖杯时，移除羔羊身体的碰撞箱并使其半透明，防止选手拿不到奖杯
local function OnTrophyInit(_, _, spawnPosition)
	local bodys = Isaac.FindByType(EntityType.ENTITY_THE_LAMB, 10, -1, true, true)
	for _, body in ipairs(bodys) do
		-- 原先的碰撞箱值是EntityCollisionClass.ENTCOLL_PLAYERONLY
		-- 这里直接设置为EntityCollisionClass.ENTCOLL_NONE，完全移除碰撞箱
		body.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		-- 使身体半透明，提示选手它已经失去碰撞箱了
		-- 这里不能写成body.Color.A = 0.5，因为Color是一个userdata
		local color = body.Color
		color.A = 0.5
		body.Color = color
	end
end

BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, OnTrophyInit, PickupVariant.PICKUP_TROPHY)
