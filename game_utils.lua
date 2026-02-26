---@class GameUtils
local GameUtils = {}

---@param player EntityPlayer
---@return boolean
function GameUtils.IsRealPlayer(player)
	-- 里骨哥的灵魂
	if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
		return false
	end

	-- 临时角色（复得游魂，店长稻草人）
	if player.Parent then
		return false
	end
	return true
end

---@param collectibleType CollectibleType
---@return boolean
function GameUtils.HasCollectible(collectibleType)
	local num = Game():GetNumPlayers()
	for i = 0, num - 1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(collectibleType) then
			return true
		end
	end
	return false
end

---@param trapdoor GridEntity
function GameUtils.CloseTrapdoor(trapdoor)
	-- 0:普通下层坑
	-- 1:虚空门
	if trapdoor and trapdoor:GetType() == GridEntityType.GRID_TRAPDOOR and trapdoor:GetVariant() == 0 then
		-- 0:关闭状态
		-- 1:打开状态
		trapdoor.State = 0
		local sprite = trapdoor:GetSprite()
		if sprite:GetAnimation() ~= "Closed" then
			sprite:Play("Closed", true)
		end
		-- 锁死动画，防止鬼畜
		sprite:SetFrame(0)
	end
end

---@param trapdoor GridEntity
---@param targetIndex? integer
function GameUtils.ReplaceWithPortalTeleport(trapdoor, targetIndex)
	if not trapdoor then
		return
	end
	local spawnPos = trapdoor.Position
	if not targetIndex then
		targetIndex = Game():GetLevel():GetStartingRoomIndex()
	end

	Game():Spawn(
		EntityType.ENTITY_EFFECT,
		EffectVariant.PORTAL_TELEPORT,
		spawnPos,
		Vector.Zero,
		nil,
		1000 + targetIndex,
		1
	)
	if trapdoor.GetGridIndex then
		local room = Game():GetRoom()
		room:RemoveGridEntity(trapdoor:GetGridIndex(), 0, false)
	end
end

---@param pos Vector
function GameUtils.DisappearHeavenDoor(pos)
	-- 一个白色地面发光效果，没有啥副作用
	local fakeHeavenDoor =
		Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.GROUND_GLOW, pos, Vector.Zero, nil, 0, 1)
	-- 生成一个圣光效果，生成者是角色，防止角色被圣光击伤
	Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CRACK_THE_SKY, pos, Vector.Zero, Game():GetPlayer(0), 2, 1)

	-- 把白色地面发光效果伪装为一个天使光柱的关闭动画
	if fakeHeavenDoor then
		local sprite = fakeHeavenDoor:GetSprite()
		sprite:Load("gfx/1000.039_heaven door.anm2", true)
		sprite:Play("Disappear")
	end
end

---@param pos Vector
function GameUtils.ReplaceHeavenDoor(pos)
	if Game():GetRoom():GetType() == RoomType.ROOM_BOSS then
		-- 生成一个假的天堂光柱和圣光效果，伪装成天堂光柱关闭的效果
		GameUtils.DisappearHeavenDoor(pos)
		-- 把原本的天堂光柱替换为地面发光效果
		return { EntityType.ENTITY_EFFECT, EffectVariant.GROUND_GLOW, 0, 1 }
	else
		local index = 1000 + Game():GetLevel():GetStartingRoomIndex()
		-- 天堂光柱替换为传送初始房间的效果
		return { EntityType.ENTITY_EFFECT, EffectVariant.PORTAL_TELEPORT, index, 1 }
	end
end

---@param room Room
---@return GridEntity[]
function GameUtils.FindTrapdoor(room)
	local trapdoors = {}
	local gridSize = room:GetGridSize()
	for i = 0, gridSize - 1 do
		local grid = room:GetGridEntity(i)
		repeat
			if not grid then
				break
			end

			if grid:GetType() ~= GridEntityType.GRID_TRAPDOOR then
				break
			end

			-- Variant是1的话是虚空门
			if grid:GetVariant() ~= 0 then
				break
			end

			-- 这是见证者BOSS房的大坑
			if grid:GetSprite():GetFilename() == "gfx/grid/trapdoor_corpse_big.anm2" then
				break
			end

			trapdoors[#trapdoors + 1] = grid
		until true
	end
	return trapdoors
end

---@param room Room
function GameUtils.ReplaceTrapDoor(room)
	local trapdoors = GameUtils.FindTrapdoor(room)
	for i = 1, #trapdoors do
		local trapdoor = trapdoors[i]
		if room:GetType() == RoomType.ROOM_BOSS then
			-- BOSS房间的下层门关闭
			GameUtils.CloseTrapdoor(trapdoor)
		else
			-- 其他房间的下层门替换成传送门
			GameUtils.ReplaceWithPortalTeleport(trapdoor)
		end
	end
end

---@param level Level
---@return boolean
function GameUtils.IsFateDecided(level)
	local stage = level:GetStage()
	-- 凹凸层、子宫2或者腐烂2
	if stage == LevelStage.STAGE4_3 or stage == LevelStage.STAGE4_2 then
		return true
	end
	-- 子宫合并层
	local hasXLCurse = level:GetCurses() & LevelCurse.CURSE_OF_LABYRINTH ~= 0
	if hasXLCurse and stage == LevelStage.STAGE4_1 then
		return true
	end

	return false
end

---@param level Level
---@return integer
function GameUtils.GetConnectedNeighborIndex(level)
	local currentIdx = level:GetCurrentRoomIndex()
	local mapWidth = 13

	local offsets = {
		-1,
		1,
		-mapWidth,
		mapWidth,
	}

	for _, offset in ipairs(offsets) do
		local targetIdx = currentIdx + offset
		if targetIdx >= 0 and targetIdx < 169 then
			local neighborDesc = level:GetRoomByIdx(targetIdx)
			if neighborDesc.Data and neighborDesc.Data.Type ~= RoomType.ROOM_NULL then
				return targetIdx
			end
		end
	end
	return -1
end

-- === 终极版寻路函数：健壮性/权重/多BOSS支持 ===
-- @return: table(路径列表) 或 nil(无路/出错)
function GameUtils.GetPathToBossWeighted(startIdx)
	local game = Game()
	local level = game:GetLevel()
	if not startIdx then
		startIdx = level:GetCurrentRoomIndex()
	end

	-- [防守 1] 索引越界检查 (不在地图上)
	if startIdx < 0 then
		return nil
	end

	local startDesc = level:GetRoomByIdx(startIdx)
	-- [防守 2] 房间数据不存在
	if startDesc.ListIndex < 0 then
		return nil
	end

	-- [防守 3] 处于特殊逻辑房间 (无法通过普通门移动)
	local invalidTypes = {
		[RoomType.ROOM_DUNGEON] = true, -- 爬行空间/地下室
		[RoomType.ROOM_BLACK_MARKET] = true, -- 黑市
		[RoomType.ROOM_NULL] = true, -- 空数据
	}
	if invalidTypes[startDesc.Data.Type] then
		return nil
	end

	local startUUID = startDesc.SafeGridIndex

	-- === 预处理 ===
	local roomSizes = {} -- 记录房间大小权重
	local graph = {} -- 邻接表
	local potentialBosses = {} -- 所有可能的 BOSS 目标
	local WIDTH = 13

	-- 遍历全图
	for i = 0, 168 do
		local roomDesc = level:GetRoomByIdx(i)
		if roomDesc.ListIndex >= 0 then
			local uuid = roomDesc.SafeGridIndex
			local rType = roomDesc.Data.Type

			-- 权重计算
			if not roomSizes[uuid] then
				roomSizes[uuid] = 0
			end
			roomSizes[uuid] = roomSizes[uuid] + 1

			-- [多 BOSS 支持] 收集所有非当前的 BOSS 房
			if rType == RoomType.ROOM_BOSS and uuid ~= startUUID then
				potentialBosses[uuid] = true
			end

			-- 构建连接
			local x = i % WIDTH
			local y = math.floor(i / WIDTH)
			local dirs = { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }

			for _, dir in ipairs(dirs) do
				local nx, ny = x + dir[1], y + dir[2]
				if nx >= 0 and nx < WIDTH and ny >= 0 and ny < 13 then
					local neighborIdx = ny * WIDTH + nx
					local neighborDesc = level:GetRoomByIdx(neighborIdx)
					if neighborDesc.ListIndex >= 0 then
						local neiUUID = neighborDesc.SafeGridIndex
						local neiType = neighborDesc.Data.Type

						-- [防守 4] 通行规则严格限制
						-- 只有 普通房间 和 BOSS房间 视为“路”
						-- 商店/宝箱房等被视为“墙”，防止把玩家导进去出不来
						local isWalkable = (neiType == RoomType.ROOM_DEFAULT) or (neiType == RoomType.ROOM_BOSS)

						if uuid ~= neiUUID and isWalkable then
							if not graph[uuid] then
								graph[uuid] = {}
							end
							-- 简单去重
							local exists = false
							for _, v in ipairs(graph[uuid]) do
								if v == neiUUID then
									exists = true
									break
								end
							end
							if not exists then
								table.insert(graph[uuid], neiUUID)
							end
						end
					end
				end
			end
		end
	end

	-- [防守 5] 没有 BOSS 房 (例如贪婪模式某层)
	if next(potentialBosses) == nil then
		return nil
	end

	-- === Dijkstra 算法 ===
	local dist = {}
	local parents = {}
	local openSet = {}

	dist[startUUID] = 0
	table.insert(openSet, startUUID)

	while #openSet > 0 do
		-- 寻找最小代价节点
		local current = nil
		local minDist = math.huge
		local minIndex = -1

		for i, uuid in ipairs(openSet) do
			local d = dist[uuid] or math.huge
			if d < minDist then
				minDist = d
				current = uuid
				minIndex = i
			end
		end

		table.remove(openSet, minIndex)

		-- [防守 6] 孤岛检查
		-- 如果 graph[current] 为空 (比如周围全是特殊房间)，循环跳过，路径自然断开
		if graph[current] then
			for _, neighborUUID in ipairs(graph[current]) do
				local weight = 100 + (roomSizes[neighborUUID] or 1)
				local newDist = (dist[current] or 0) + weight
				local oldDist = dist[neighborUUID] or math.huge

				if newDist < oldDist then
					dist[neighborUUID] = newDist
					parents[neighborUUID] = current

					local inQueue = false
					for _, v in ipairs(openSet) do
						if v == neighborUUID then
							inQueue = true
							break
						end
					end
					if not inQueue then
						table.insert(openSet, neighborUUID)
					end
				end
			end
		end
	end

	-- === 筛选终点 ===
	local finalTarget = nil
	local maxCost = -1

	-- [防守 7] 检查连通性
	-- 只有当 dist[uuid] 存在时，才说明该 BOSS 是可达的
	for uuid, _ in pairs(potentialBosses) do
		if dist[uuid] then
			if dist[uuid] > maxCost then
				maxCost = dist[uuid]
				finalTarget = uuid
			end
		end
	end

	if not finalTarget then
		return nil
	end

	-- === 回溯路径 ===
	local path = {}
	local curr = finalTarget
	while curr do
		table.insert(path, curr)
		curr = parents[curr]
	end

	local finalPath = {}
	for i = #path, 1, -1 do
		table.insert(finalPath, path[i])
	end

	return finalPath
end

---@param player EntityPlayer
---@param trinketType TrinketType
function GameUtils.DropTrinket(player, trinketType)
	if player:TryRemoveTrinket(trinketType) then
		Game():Spawn(
			EntityType.ENTITY_PICKUP,
			PickupVariant.PICKUP_TRINKET,
			player.Position,
			Vector.Zero,
			nil,
			trinketType,
			1
		)
	end
end

function GameUtils.SeedToString(seed)
	-- 1. 定义字符表 (完全对应 C++ 的 table)
	local table_str = "ABCDEFGHJKLMNPQRSTWXYZ01234V6789"

	-- 2. 确保输入为无符号 32 位整数
	-- (Lua 的 number 可能是浮点数，强制转为整型并截断为 32 位)
	seed = math.tointeger(seed) or 0
	seed = seed & 0xFFFFFFFF

	-- 3. 计算校验和 (Checksum)
	-- 对应: uint32_t cksum = 0, k = seed;
	local cksum = 0
	local k = seed

	-- 对应: do { ... } while (k);
	repeat
		-- cksum = (cksum + (k & 0xFF)) & 0xFF;
		cksum = (cksum + (k & 0xFF)) & 0xFF

		-- cksum = (2 * cksum + (cksum >> 7)) & 0xFF;
		-- 注意：Lua 5.3 中 << 是位左移，优先级正确
		cksum = ((cksum << 1) + (cksum >> 7)) & 0xFF

		-- k >>= 5;
		k = k >> 5
	until k == 0

	-- 4. 组装 40 位种子整数
	-- 对应: uint64_t s = ((seed ^ 0xFEF7FFDull) << 8) | cksum;
	-- 修正：Lua 中异或是 ~ 不是 ^
	local magic = 0xFEF7FFD
	local obfuscated = seed ~ magic
	local s = (obfuscated << 8) | cksum

	-- 5. 生成字符串
	local str = ""

	-- 对应: for (int i = 7; ~i; i--)
	-- 也就是 i 从 7 循环到 0
	for i = 7, 0, -1 do
		-- 对应: s >> (5 * i) & 31
		local shift = 5 * i
		local index = (s >> shift) & 31

		-- 查表拼接 (Lua 索引从 1 开始，所以要 +1)
		local char = string.sub(table_str, index + 1, index + 1)
		str = str .. char

		-- 对应: if (i == 4) str += ' ';
		if i == 4 then
			str = str .. " "
		end
	end

	return str
end

---@type GameUtils
GameUtils = GameUtils
return GameUtils
