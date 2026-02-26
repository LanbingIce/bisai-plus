local function OnClearAward(_, _, spawnPosition)
	local room = Game():GetRoom()

	-- 见证者路线开启所有带锁的门
	local isMotherGoal = BISAI_PLUS.Data.Save.Goal == BISAI_PLUS.Shared.Goal.MOTHER

	if not isMotherGoal then
		return
	end

	if room:GetType() ~= RoomType.ROOM_BOSS then
		return
	end

	local level = Game():GetLevel()
	local roomName = level:GetCurrentRoomDesc().Data.Name
	local isMomRoom = roomName == "Mom (mausoleum)"

	local hasKnife = BISAI_PLUS.GameUtils.HasCollectible(CollectibleType.COLLECTIBLE_KNIFE_PIECE_1)
		and BISAI_PLUS.GameUtils.HasCollectible(CollectibleType.COLLECTIBLE_KNIFE_PIECE_2)
	-- 击杀妈腿之后，有刀的话就不自动开了，把刀没收
	if isMomRoom and hasKnife then
		return
	end

	for i = 0, DoorSlot.NUM_DOOR_SLOTS - 1 do
		local door = room:GetDoor(i)
		if door and door:IsLocked() and door:TryUnlock(Game():GetPlayer(0), true) then
			break
		end
	end
end

BISAI_PLUS:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, OnClearAward)
