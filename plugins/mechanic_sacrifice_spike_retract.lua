local function CheckSacrificeSpikes(isRoomEnter)
	local room = Game():GetRoom()

	if room:GetType() ~= RoomType.ROOM_SACRIFICE then
		return
	end

	-- 网格最大索引应该是 GetGridSize() - 1
	for i = 0, room:GetGridSize() - 1 do
		local grid = room:GetGridEntity(i)
		if grid and grid:GetType() == GridEntityType.GRID_SPIKES then
			local threshold = isRoomEnter and 11 or 10
			if grid.VarData >= threshold then
				grid.State = 1
				local sprite = grid:GetSprite()
				if sprite then
					sprite:Play("Unsummon")
				end
			end
		end
	end
end

local function OnPlayerDamage(_, entity, amount, damageFlags, source, countdownFrames)
	CheckSacrificeSpikes(false)
end

local function OnNewRoom()
	CheckSacrificeSpikes(true)
end

BISAI_PLUS:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, OnPlayerDamage, EntityType.ENTITY_PLAYER)
BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, OnNewRoom)
