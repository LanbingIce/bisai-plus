local positiveRoomHistory = {}
local MAX_HISTORY = 2 -- 只需要保留两个历史记录即可应对发光沙漏

-- 获取当前有效最新的正索引 (自带时间线校验)
local function GetValidLastPositiveIndex()
	local currentFrame = Game():GetFrameCount()

	-- 从后往前遍历，清理掉因为发光沙漏而变成“未来”的记录
	for i = #positiveRoomHistory, 1, -1 do
		if positiveRoomHistory[i].frame > currentFrame then
			table.remove(positiveRoomHistory, i)
		else
			-- 找到第一个帧数小于等于当前帧数的记录
			return positiveRoomHistory[i].index
		end
	end

	-- 保底机制：如果记录全被清空，返回初始房间的索引
	return 84
end

local function OnUseCard(_, cardID, player, useFlags)
	if not BISAI_PLUS.GameUtils.IsRealPlayer(player) then
		return
	end
	-- 确保是皇帝卡
	if cardID ~= Card.CARD_EMPEROR then
		return
	end

	local level = Game():GetLevel()

	-- 使用记录的上一个正索引房间作为起点，如果当前房间具有正索引，则记录的就是当前房间
	-- 上一个房间的索引应该始终能产生有效路径，如果不能，说明有我没考虑到的情况
	local startRoomIndex = GetValidLastPositiveIndex()

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
	if #path <= targetIndex then
		return
	end

	local targetSafeGridIndex = path[targetIndex]
	Game():StartRoomTransition(targetSafeGridIndex, Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT, player, -1)
end

local function OnNewRoom()
	local level = Game():GetLevel()
	local currentRoomIndex = level:GetCurrentRoomIndex()
	local currentFrame = Game():GetFrameCount()

	-- 进入新房间时，先清理因为发光沙漏而超前的历史记录
	GetValidLastPositiveIndex()

	-- 如果当前房间是正索引，更新历史记录
	if currentRoomIndex >= 0 then
		table.insert(positiveRoomHistory, { frame = currentFrame, index = currentRoomIndex })

		-- 维持最大长度为2
		if #positiveRoomHistory > MAX_HISTORY then
			table.remove(positiveRoomHistory, 1)
		end
	end
end

BISAI_PLUS:AddCallback(ModCallbacks.MC_USE_CARD, OnUseCard)
BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, OnNewRoom)
