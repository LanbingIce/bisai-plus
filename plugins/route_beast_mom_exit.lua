local DOOR_CONFIGS = {
	[DoorSlot.LEFT0] = {
		GridIndex = 60,
		Rotation = -90,
		Offset = Vector(15, 0),
		CheckTransition = function(pos) return pos.X < 45 end
	},
	[DoorSlot.UP0] = {
		GridIndex = 7,
		Rotation = 0,
		Offset = Vector(0, 15),
		CheckTransition = function(pos) return pos.Y < 125 end
	},
	[DoorSlot.RIGHT0] = {
		GridIndex = 74,
		Rotation = 90,
		Offset = Vector(-15, 0),
		CheckTransition = function(pos) return pos.X > 595 end
	},
	[DoorSlot.DOWN0] = {
		GridIndex = 127,
		Rotation = 180,
		Offset = Vector(0, -15),
		CheckTransition = function(pos) return pos.Y > 435 end
	}
}

local function GetDoorGridIndex(doorSlot)
	local config = DOOR_CONFIGS[doorSlot]
	return config and config.GridIndex or -1
end

local function GetSingleNeighbor2D()
	local game = Game()
	local level = game:GetLevel()
	local room = game:GetRoom()

	local currentIdx = level:GetCurrentRoomIndex()
	local MAP_WIDTH = 13

	local curX = currentIdx % MAP_WIDTH
	local curY = math.floor(currentIdx / MAP_WIDTH)

	local directions = {
		{ dx = -1, dy = 0, slot = DoorSlot.LEFT0 }, -- 0
		{ dx = 0, dy = -1, slot = DoorSlot.UP0 }, -- 1
		{ dx = 1, dy = 0, slot = DoorSlot.RIGHT0 }, -- 2
		{ dx = 0, dy = 1, slot = DoorSlot.DOWN0 }, -- 3
	}

	for _, dir in ipairs(directions) do
		local targetX = curX + dir.dx
		local targetY = curY + dir.dy

		if targetX >= 0 and targetX < MAP_WIDTH and targetY >= 0 and targetY < MAP_WIDTH then
			local targetIdx = targetY * MAP_WIDTH + targetX
			local roomDesc = level:GetRoomByIdx(targetIdx)

			if roomDesc.Data then
				local originalSlot = dir.slot
				local finalSlot = originalSlot

				-- 【核心修复】循环检测空位
				-- 尝试 0 到 3 次旋转 (0度, 90度, 180度, 270度)
				for i = 0, 3 do
					-- 计算当前要检查的方向
					local checkSlot = (originalSlot + i) % 4

					-- 如果这个方向没有门 (GetDoor返回nil)，说明是空墙壁
					if room:GetDoor(checkSlot) == nil then
						finalSlot = checkSlot
						break -- 找到了！跳出循环
					end
				end

				-- 如果循环结束还是没找到(4面墙都有门)，finalSlot 会停在最后一次检查的位置
				-- 但这是不可能的

				return targetIdx, finalSlot, originalSlot
			end
		end
	end

	return 81, -1, -1
end

---@param room Room
local function SpawnMomExitDoor(room)
	local neighborRoom, doorSlot = GetSingleNeighbor2D()

	local level = Game():GetLevel()
	local roomDesc = level:GetRoomByIdx(neighborRoom)

	if roomDesc and roomDesc.Data then
		roomDesc.DisplayFlags = 1 << 0 | 1 << 2
	end

	level:UpdateVisibility()

	local idx = GetDoorGridIndex(doorSlot)
	local targetDoor = room:GetGridEntity(idx)

	if not targetDoor then
		return
	end

	local sprite = targetDoor:GetSprite()

	-- 加载动画文件
	sprite:Load("gfx/grid/door_10_bossroomdoor.anm2", false)

	-- 把红光图层替换成随便一张小图，这样就可以不显示红光
	sprite:ReplaceSpritesheet(4, "gfx/lighting_eye.png")
	sprite:LoadGraphics()
	sprite:SetFrame("Open", 11)

	-- 获取当前方向的配置
	local currentConfig = DOOR_CONFIGS[doorSlot]

	if currentConfig then
		sprite.Rotation = currentConfig.Rotation
		sprite.Offset = currentConfig.Offset
	else
		-- 默认回退（防止异常）
		sprite.Rotation = 0
		sprite.Offset = Vector(-12, 0)
	end

	targetDoor.CollisionClass = GridCollisionClass.COLLISION_WALL_EXCEPT_PLAYER
end

local function ShouldProcessMomExit()
	-- 确保是祸兽路线
	if BISAI_PLUS.Data.Save.Goal ~= BISAI_PLUS.Shared.Goal.BEAST then
		return false
	end

	local level = Game():GetLevel()

	-- 确保不是在回溯过程中
	if level:IsAscent() then
		return false
	end

	-- 确保房间是妈腿房间
	if level:GetCurrentRoomDesc().Data.Name ~= "Mom" then
		return false
	end

	local room = Game():GetRoom()
	if not room or not room:IsClear() then
		return false
	end

	return true
end

local function OnPlayerUpdate(_, player)
	if not ShouldProcessMomExit() then
		return
	end

	if not BISAI_PLUS.GameUtils.IsRealPlayer(player) then
		return
	end

	local level = Game():GetLevel()
	local room = Game():GetRoom()

	-- 1. 获取相邻房间及其方向 (返回值2是 DoorSlot)
	local neighborRoom, doorSlot, originalSlot = GetSingleNeighbor2D()

	-- 如果没有相邻房间，直接退出
	if not neighborRoom then
		return
	end

	-- 2. 获取该方向上的门格子索引并检查是否存在
	local doorIdx = GetDoorGridIndex(doorSlot)
	local targetDoor = room:GetGridEntity(doorIdx)

	-- 如果那个位置没有门（是墙或者是空的），不执行
	if not targetDoor then
		return
	end

	-- 3. 【核心修改】根据方向判定坐标阈值
	local shouldTransition = false
	local pos = player.Position
	local config = DOOR_CONFIGS[doorSlot]

	if config and config.CheckTransition(pos) then
		shouldTransition = true
	end

	if shouldTransition then
		level.LeaveDoor = originalSlot
		Game():StartRoomTransition(neighborRoom, originalSlot)
	end
end

-- 在满足条件时尝试生成妈腿出口门
local function TrySpawnMomExitDoor()
	if not ShouldProcessMomExit() then
		return
	end

	local room = Game():GetRoom()
	SpawnMomExitDoor(room)
end

local function OnClearAward()
	TrySpawnMomExitDoor()
end

local function OnNewRoom()
	TrySpawnMomExitDoor()
end

BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, OnPlayerUpdate)
BISAI_PLUS:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, OnClearAward)
BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, OnNewRoom)
