local LastRoomIndex = 84
-- TODO 修改一下皇帝卡的逻辑
local function OnUseCard(_, cardID, player, useFlags)
	if not BISAI_PLUS.GameUtils.IsRealPlayer(player) then
		return
	end
	-- 修改皇帝卡的效果：向着BOSS房方向前进2格，如果有塔罗牌桌布，改为三格
	-- 确保是皇帝卡
	if cardID ~= Card.CARD_EMPEROR then
		return
	end

	local level = Game():GetLevel()

	-- 使用记录的上一个正索引房间作为起点，如果当前房间具有正索引，则记录的就是当前房间
	-- 上一个房间的索引应该始终能产生有效路径，如果不能，说明有我没考虑到的情况
	local startRoomIndex = LastRoomIndex

	local roomData = level:GetRoomByIdx(startRoomIndex).Data
	-- 起点房间是BOSS房，则不修改效果
	if roomData and roomData.Type == RoomType.ROOM_BOSS then
		return
	end

	local stage = level:GetStage()
	-- 虚空层不改
	if stage == LevelStage.STAGE7 then
		return
	end

	-- 家层不改
	if stage == LevelStage.STAGE8 then
		return
	end

	-- 获取路径
	local path = BISAI_PLUS.GameUtils.GetPathToBossWeighted(startRoomIndex)
	if not path then -- 这里不会触发，如果触发了，说明有我没考虑到的情况，需要修复
		-- 看到太阳卡的动画就知道出问题了
		player:UseCard(Card.CARD_SUN)
		player:UseCard(Card.CARD_FOOL)
		return
	end

	-- 当前房间是1，前进4格是5
	local targetIndex = 5
	-- 有塔罗牌桌布，多前进2格
	if player:HasCollectible(CollectibleType.COLLECTIBLE_TAROT_CLOTH) then
		targetIndex = 7
	end

	-- 如果路径长度不够，不改
	if #path < targetIndex then
		return
	end

	local targetSafeGridIndex = path[targetIndex]
	Game():StartRoomTransition(targetSafeGridIndex, Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT, player, -1)
end

local function OnNewRoom()
	local level = Game():GetLevel()
	local currentRoomIndex = level:GetCurrentRoomIndex()
	if currentRoomIndex >= 0 then
		LastRoomIndex = currentRoomIndex
	end
end

BISAI_PLUS:AddCallback(ModCallbacks.MC_USE_CARD, OnUseCard)
BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, OnNewRoom)
