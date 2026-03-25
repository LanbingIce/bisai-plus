local function SpawnFloor(room, gridIndex)
	-- 如果对应的位置不是深渊，这里会取到nil，直接返回就好了
	if not room:GetGridEntity(gridIndex) then
		return
	end
	-- 将深渊移除，这样就能铺路了
	room:RemoveGridEntity(gridIndex, 0, false)

	-- 更新一下，使得移除生效
	room:Update()

	-- 生成地面，这个是正常踩完外面的黄按钮后应该出现的地面
	room:SpawnGridEntity(gridIndex, GridEntityType.GRID_PIT, 261, 0, 0)

	-- 将State设置为1，不然外观会有问题
	local grid = room:GetGridEntity(gridIndex)
	if not grid then
		return
	end
	grid.State = 1
end

-- 返回true表示这个格子是黄按钮
local function HandleGridEntity(room, i)
	local grid = room:GetGridEntity(i)
	if not grid then
		return false
	end
	-- 确保是一个黄按钮
	if grid:GetType() ~= GridEntityType.GRID_PRESSURE_PLATE then
		return false
	end

	-- VarData为1表示已经开了门并铺了路，这个VarData是我们手动设置的，游戏原生VarData永远是0
	if grid.VarData == 1 then
		return true
	end

	-- 确保按钮已经踩下，State为3表示已经踩下
	if grid.State ~= 3 then
		return true
	end

	-- 手动设置VarData为1，表示这个按钮已经被我们处理过了，后续就不需要再处理了
	grid.VarData = 1

	-- 打开神庙逃亡的门
	-- 神庙逃亡的门是1号门
	local door = room:GetDoor(1)
	if not door then
		return true
	end

	-- 如果门已经解锁了，就不需要再解锁了
	if not door:IsLocked() then
		return true
	end

	-- 尝试解锁神庙逃亡的门
	door:TryUnlock(Game():GetPlayer(0), true)

	-- 铺路，两个位置对应踩下外面两个黄色按钮会出现的地面
	-- 大多数情况下，这两个位置的ID是82和112，有较小概率是67和97，所以四个位置都尝试铺一下
	SpawnFloor(room, 67)
	SpawnFloor(room, 97)

	SpawnFloor(room, 82)
	SpawnFloor(room, 112)

	-- 找到矿车，将其移除，防止卡脚
	local mines = Isaac.FindByType(EntityType.ENTITY_MINECART, 10, -1, true, true)
	for _, mine in pairs(mines) do
		mine:Remove()
	end

	return true
end

-- 每帧检测是否有黄按钮刚刚被踩下，如果是，就打开神庙逃亡的门，并铺路
local function OnUpdate()
	-- 确保是见证者路线
	if BISAI_PLUS.Data.Save.Goal ~= BISAI_PLUS.Shared.Goal.MOTHER then
		return
	end

	-- 获取当前房间信息
	local level = Game():GetLevel()
	local roomDesc = level:GetCurrentRoomDesc()

	if not roomDesc then
		return
	end

	local roomData = roomDesc.Data
	if not roomData then
		return
	end

	-- 确保是矿车房
	if roomData.Name ~= "Secret Entrance" then
		return
	end

	local room = Game():GetRoom()

	-- 遍历所有格子
	for i = 0, room:GetGridSize() - 1 do
		-- 找到了黄按钮，直接返回
		if HandleGridEntity(room, i) then
			return
		end
	end
end

BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_UPDATE, OnUpdate)
