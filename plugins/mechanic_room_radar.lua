-- TODO 支持大宝箱
-- TODO 有红钥匙/该隐魂/红钥匙碎片的情况下，显示红门
-- TODO 错误技的处理
-- TODO 重构一下代码，现在有点粗糙，比如现在追踪逻辑写到渲染逻辑里面了

local API = BISAI_PLUS.CurrentPluginAPI
local GhostSprite = Sprite()
GhostSprite.Scale = Vector(0.5, 0.5)
GhostSprite.Color = Color(1, 1, 1, 0.5, 0, 0, 0)

-- 经过测试，问号贴图上有6个像素点，他们的任何一个颜色通道，都不会和任何道具重复
-- 因此我们只需要对比其中一个点的其中一个颜色通道，即可高效判断其是否是问号道具
-- Vector(-4, -29)
-- Vector(-3, -31)
-- Vector(-2, -31)
-- Vector(3, -30)
-- Vector(4, -30)
-- Vector(5, -28)

-- 随便选取其中一个点
local BlindCheckPixelPos = Vector(-4, -29)

local QuestionMarkSprite = Sprite()

do
	QuestionMarkSprite:Load("gfx/005.100_collectible.anm2", true)
	QuestionMarkSprite:ReplaceSpritesheet(1, "gfx/items/collectibles/questionmark.png")
	QuestionMarkSprite:LoadGraphics()
	QuestionMarkSprite:SetFrame("Idle", 0)
	QuestionMarkSpriteRed = QuestionMarkSprite:GetTexel(BlindCheckPixelPos, Vector.Zero, 1, 1).Red
end

-- 瞬时状态追踪器（无需持久化，仅用于跨回调传参）
local FlipTransientState = {
	FlipItemNext = false,
	ID = nil,
	Seed = nil,
	Frame = nil,
	-- 记录本房间上一帧每个坐标点的种子
	RoomPedestalSeeds = {},
}

-- 判断一个道具是否是问号道具
local function CheckIsQuestion(collectible)
	local data = collectible:GetData()

	-- 优先取缓存的结果，因为问号道具被拿取之后就不再是问号了，但是我们依然希望其判定为问号，因为在游戏中，拿取道具并不会揭示问号虚影道具
	if data.BisaiPlus_IsQuestion ~= nil then
		return data.BisaiPlus_IsQuestion
	end

	local sprite = collectible:GetSprite()

	local anim = sprite:GetAnimation()
	local frame = sprite:GetFrame()

	sprite:SetFrame("Idle", 0)
	local eRed = sprite:GetTexel(BlindCheckPixelPos, Vector.Zero, 1, 1).Red
	sprite:Play(anim)
	sprite:SetFrame(frame)

	-- 取出当前道具贴图的同一位置的红色通道进行对比
	local isQuestion = eRed == QuestionMarkSpriteRed

	-- 将结果缓存
	data.BisaiPlus_IsQuestion = isQuestion
	return isQuestion
end

local function GetFlipTracker()
	local data = API.GetSaveData()
	if not data or not data.Pedestals then
		data = data or {}
		data.Pedestals = {}
		API.SetSaveData(data)
	end
	return data
end

-- 底座初始化回调：记录实际生成的表面道具极其随机种子
local function OnCollectibleInit(_, entity)
	if Game():GetRoom():GetFrameCount() > 1 then
		return
	end

	FlipTransientState.ID = entity.SubType
	FlipTransientState.Seed = entity.InitSeed
	FlipTransientState.Frame = Isaac.GetFrameCount()
	FlipTransientState.FlipItemNext = true
end

-- 结算回调：将追踪判定结果写入持久化内存，记录对应种子的隐藏虚像 ID
local function OnGetCollectible(_, selectedCollectible, itemPoolType, decrease, seed)
	if Game():GetRoom():GetFrameCount() > 1 then
		return
	end

	local curFrame = Isaac.GetFrameCount()

	if curFrame == FlipTransientState.Frame and FlipTransientState.FlipItemNext then
		local tracker = GetFlipTracker()

		local surfaceSeed = tostring(FlipTransientState.Seed)
		local surfaceId = FlipTransientState.ID

		local ghostSeed = tostring(seed)
		local ghostId = selectedCollectible

		-- 双向绑定：表层种子(InitSeed) -> 虚影数据, 虚影种子(Flip后暴露) -> 表层数据
		tracker.Pedestals[surfaceSeed] = { ID = ghostId, OtherSeed = ghostSeed }
		tracker.Pedestals[ghostSeed] = { ID = surfaceId, OtherSeed = surfaceSeed }

		FlipTransientState.FlipItemNext = false
	end
end

-- 处理单个底座的反转逻辑
local function ProcessFlipPedestal(pickup, pData)
	local strSeed = tostring(pickup.InitSeed)
	local tracker = GetFlipTracker()

	local trackerObj = tracker.Pedestals[strSeed]

	local trackerGhostId = trackerObj and trackerObj.ID
	local currentGhostId = pData.BisaiPlus_FlipGhostID or trackerGhostId

	if currentGhostId then
		if pickup.SubType == 0 then
			-- 底座为空时发生翻转，意味着原本为空的前景翻到了背面，以后就不再有虚影了
			pData.BisaiPlus_FlipGhostID = nil
			if trackerObj then
				tracker.Pedestals[strSeed] = nil
				if trackerObj.OtherSeed then
					tracker.Pedestals[trackerObj.OtherSeed] = nil
				end
			end
		else
			-- 核心反转：当前可见的现行道具转为虚象缓存；新暴露的里层道具留给引擎自动结算
			pData.BisaiPlus_FlipGhostID = pickup.SubType

			-- 因为一会此实体就会完成Flip动画并且 InitSeed 将变成背面的新种子 (GhostSeed)
			-- 把背面的那个种子对应的表面物品（即将变成新的虚影）修改为当前真实的当前表面道具
			if trackerObj and trackerObj.OtherSeed and tracker.Pedestals[trackerObj.OtherSeed] then
				tracker.Pedestals[trackerObj.OtherSeed].ID = pickup.SubType
			end
		end
	end
end

-- 主动使用生死逆转（Flip）：拦截使用瞬间，将现行底座与追踪记录中的虚影发生翻转交换
local function OnPreUseFlip()
	local pedestals = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, -1, true, false)
	local claimedSeeds = {}

	for _, itemEntity in ipairs(pedestals) do
		local pickup = itemEntity:ToPickup()
		if pickup then
			local pData = pickup:GetData()
			-- 根据实体列表顺序进行排重，只对拥有相同种子的第一个道具（本体）执行追踪反转
			local strSeed = tostring(pickup.InitSeed)
			local isDuplicate = claimedSeeds[strSeed] or false
			claimedSeeds[strSeed] = true

			if pData.BisaiPlus_WasDuplicate then
				isDuplicate = true
			end

			local tracker = GetFlipTracker()
			local trackerObj = tracker.Pedestals[strSeed]

			-- 识破篡位的克隆体：如果记录中本体已被拾取过，但当前判定个体 SubType 不为空，则它必是赝品
			if not isDuplicate and trackerObj and trackerObj.IsCollected and pickup.SubType ~= 0 then
				isDuplicate = true
				pData.BisaiPlus_WasDuplicate = true
			end

			if not isDuplicate then
				ProcessFlipPedestal(pickup, pData)
			end
		end
	end
end

-- =========================================================================
-- UI层：针对特殊大房间的脱框雷达指示渲染
-- =========================================================================

-- 获取底座下方的虚影 ID，通过底层种子的映射关系进行回溯全局检索
local function TryGetGhostID(pickup, pData)
	-- 性能优化：如果在实体数据上记录了已检查标志，不管有没有虚影（即使为 nil），都可以避免每帧重复字典检索
	if pData.BisaiPlus_GhostChecked then
		return pData.BisaiPlus_FlipGhostID
	end

	local strSeed = tostring(pickup.InitSeed)
	local tracker = GetFlipTracker()

	local ghostId = nil
	if tracker.Pedestals[strSeed] then
		ghostId = tracker.Pedestals[strSeed].ID
	end

	-- 解析结果无论为数值还是 nil 都一次性打上标记缓存，将后续每帧该道具的消耗降至最低 (O(1))
	pData.BisaiPlus_FlipGhostID = ghostId
	pData.BisaiPlus_GhostChecked = true

	return ghostId
end

-- 收集单一底座的数据（包裹虚影层和表相层），转换为渲染表所需的数据结构并装入传入的列表
local function ProcessRadarItem(item, roomCenter, validItems, hasFlip, isMirror, isDuplicate)
	local pickup = item:ToPickup()

	-- 计算底座相对于房间中心的向量偏置，若是下水道的镜子中，则 x 轴取反
	local offset = item.Position - roomCenter
	if isMirror then
		offset.X = -offset.X
	end

	local pData = pickup:GetData()
	local isBlind = CheckIsQuestion(pickup)

	local ghostId = TryGetGhostID(pickup, pData)
	-- 如果本房间已经有同样种子的底座被雷达渲染了虚影，说明当前底座是其复眼复制品本体不该有虚像
	if isDuplicate then
		ghostId = nil
	end

	local hasActiveGhost = (hasFlip and ghostId ~= nil)

	-- 1. 插入表层、玩家眼睛直接能看到的“表相道具”属性
	table.insert(validItems, {
		Item = pickup,
		Offset = offset,
		IsGhost = false, -- 这表示自己是表相，应当正常渲染
		DisplayType = pickup.SubType,
		IsBlind = isBlind,
		HasGhostSibling = hasActiveGhost,
	})

	-- 2. 如果检查到他背后有灵（也就是底座下藏有 Flip 道具），且当前角色带有 Flip 道具
	-- 则继续向列表追加插入一条“潜藏层”特殊对象，供后面透明渲染
	if hasActiveGhost then
		table.insert(validItems, {
			Item = pickup,
			Offset = offset,
			IsGhost = true, -- 提醒渲染器这是一个虚像，要施加透明化滤镜和位移
			DisplayType = ghostId, -- 将底裤展示的值覆盖显示为我们追踪到的结果
			IsBlind = isBlind,
			HasGhostSibling = true,
		})
	end
end

-- 在雷达渲染前，先行执行底层追踪信息的更新（处理 D6 Reroll、克隆筛选及结算判定）
local function UpdatePedestalTracker(item, currentRoomPedestals, claimedSeeds)
	local pickup = item:ToPickup()
	local pData = pickup:GetData()
	local strSeed = tostring(pickup.InitSeed)

	-- 用逻辑网格索引作为特征码，免疫爆炸等引起的微小物理位移导致误判
	local posKey = tostring(Game():GetRoom():GetGridIndex(item.Position))
	currentRoomPedestals[posKey] = strSeed

	-- 如果发现当前坐标上上一帧的种子和现在的不仅存在且不同，说明这百分之百是同一物理位置被Roll或重建出来的变异体
	local previousSeed = FlipTransientState.RoomPedestalSeeds[posKey]
	if previousSeed and previousSeed ~= strSeed then
		local tracker = GetFlipTracker()
		local oldObj = tracker.Pedestals[previousSeed]

		-- 开始实施追踪绑定的继承过户
		if oldObj and oldObj.OtherSeed ~= strSeed then
			local ghostSeed = oldObj.OtherSeed

			-- 迁移本尊数据
			tracker.Pedestals[strSeed] = tracker.Pedestals[previousSeed]
			tracker.Pedestals[previousSeed] = nil

			-- 更新背面的虚影指向新的表层种子并脱下旧外衣，至于新的虚影ID到底变成了啥，其实以撒底层也没立刻结算，
			-- 所以这里的 ID 暂时保留即可，雷达可以继续画旧虚影，如果你想完全模拟D6也可以让它重新判定
			if ghostSeed and tracker.Pedestals[ghostSeed] then
				tracker.Pedestals[ghostSeed].OtherSeed = strSeed
			end

			-- 取消之前判定并重建档案
			pData.BisaiPlus_OriginalSeed = strSeed
			pData.BisaiPlus_GhostChecked = false
			pData.BisaiPlus_FlipGhostID = nil
		end
	end

	-- 利用引擎获取到实体的严格时序机制，把克隆底座标记为 Duplicate
	local isDuplicate = claimedSeeds[strSeed] or false
	claimedSeeds[strSeed] = true

	-- 初始化标记：这是否是个克隆体
	if pData.BisaiPlus_OriginalSeed == nil then
		pData.BisaiPlus_OriginalSeed = strSeed
		pData.BisaiPlus_WasDuplicate = isDuplicate
	end

	local actualDuplicate = isDuplicate or pData.BisaiPlus_WasDuplicate

	local tracker = GetFlipTracker()
	local trackerObj = tracker.Pedestals[strSeed]

	if not actualDuplicate and trackerObj then
		-- 如果本体底座目前为空，则打上永久拾取标记
		if pickup.SubType == 0 then
			if not trackerObj.IsCollected then
				trackerObj.IsCollected = true
			end
		-- 如果它不是空，但之前已被标记为拾取过，说明这是老本体离开后“篡位”第一顺位的新克隆品
		elseif trackerObj.IsCollected then
			actualDuplicate = true
			pData.BisaiPlus_WasDuplicate = true
		end
	end

	return actualDuplicate
end

local function OnUpdate()
	local items = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)
	local currentRoomPedestals = {}
	local claimedSeeds = {}

	for _, item in ipairs(items) do
		local actualDuplicate = UpdatePedestalTracker(item, currentRoomPedestals, claimedSeeds)
		item:ToPickup():GetData().BisaiPlus_IsDuplicateFlag = actualDuplicate
	end

	FlipTransientState.RoomPedestalSeeds = currentRoomPedestals
end

-- 搜集当前房间内所有需要渲染在雷达上的底座
local function GatherRadarItems()
	local hasFlip = BISAI_PLUS.GameUtils.HasCollectible(CollectibleType.COLLECTIBLE_FLIP)
	local room = Game():GetRoom()
	local isMirror = room:IsMirrorWorld()
	local roomCenter = (room:GetTopLeftPos() + room:GetBottomRightPos()) / 2
	local validItems = {}

	-- 获取本房间中所有的拾取物里的“道具底座”(Collectible)
	local items = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)

	for _, item in ipairs(items) do
		local pData = item:ToPickup():GetData()
		local actualDuplicate = pData.BisaiPlus_IsDuplicateFlag or false
		ProcessRadarItem(item, roomCenter, validItems, hasFlip, isMirror, actualDuplicate)
	end

	return validItems
end

-- 专门渲染“虚影层道具”的方法（虚化、位移、无底座）
local function RenderGhostItem(data, sprite, drawPos, isMirror, itemConfig)
	local gfxParams = itemConfig:GetCollectible(data.DisplayType)
	if not gfxParams then
		return
	end

	-- 复用单个实例 tempSprite，加载一个标准的被动道具模板
	GhostSprite:Load("gfx/005.100_collectible.anm2", true)

	-- 图层 1 (道具本身材质): 盲目就替换成问号，非盲目就替换成该道具本身的 gfx 地址
	if data.IsBlind then
		GhostSprite:ReplaceSpritesheet(1, "gfx/items/collectibles/questionmark.png")
	else
		GhostSprite:ReplaceSpritesheet(1, gfxParams.GfxFileName)
	end
	GhostSprite:LoadGraphics()

	-- 对齐帧率与形态：实体在做什么动画，虚影就跟着做
	local anim = sprite:GetAnimation()
	if data.Item.SubType == 0 or anim == "" or anim == "Empty" then
		GhostSprite:SetFrame("Idle", 0)
	else
		GhostSprite:SetFrame(anim, sprite:GetFrame())
	end

	-- 创造一个左上角的微小偏移距，防止跟实像重叠死
	local ghostOffset = Vector(-7, -4)
	if isMirror then
		ghostOffset = Vector(-ghostOffset.X, ghostOffset.Y)
	end

	local oldFlipX = GhostSprite.FlipX
	if isMirror then
		GhostSprite.FlipX = not oldFlipX
	end

	-- 最终执行屏幕上的画图打印
	GhostSprite:Render(drawPos + ghostOffset, Vector.Zero, Vector.Zero)

	if isMirror then
		GhostSprite.FlipX = oldFlipX
	end
end

-- 对原有的现身道具的简单缩小渲染
local function RenderNormalItem(sprite, drawPos, isMirror)
	local oldScaleX, oldScaleY = sprite.Scale.X, sprite.Scale.Y
	local oldFlipX = sprite.FlipX

	sprite.Scale = Vector(0.5, 0.5)
	if isMirror then
		sprite.FlipX = not oldFlipX
	end

	-- 直接基于源实体自带的精灵动画渲染当前帧
	sprite:Render(drawPos, Vector.Zero, Vector.Zero)

	-- 用完恢复引擎默认属性，以免导致下一次渲染比例跑偏
	sprite.Scale = Vector(oldScaleX, oldScaleY)
	if isMirror then
		sprite.FlipX = oldFlipX
	end
end

-- 实际执行道具集合渲染器统筹
local function DrawRadarItems(validItems, radarCenterPos, isMirror, radarScale)
	-- 按照 Y 轴坐标从上往下排渲染顺序避免越级遮盖。在同一水平面上，让实效在上方，虚像渲染在下方
	table.sort(validItems, function(a, b)
		if math.abs(a.Item.Position.Y - b.Item.Position.Y) < 0.1 then
			return not a.IsGhost and b.IsGhost
		end
		return a.Item.Position.Y < b.Item.Position.Y
	end)

	local itemConfig = Isaac.GetItemConfig()
	for _, data in ipairs(validItems) do
		-- 根据其针对房间的向外发散距离应用缩放常数 radarScale
		local drawPos = radarCenterPos + (data.Offset * radarScale)
		local sprite = data.Item:GetSprite()

		-- 切流：如果是虚像表单数据，则用滤镜和剥离底座的方式渲染；如果是实物表单数据，则原始渲染
		if data.IsGhost then
			RenderGhostItem(data, sprite, drawPos, isMirror, itemConfig)
		else
			RenderNormalItem(sprite, drawPos, isMirror)
		end
	end
end

local DOOR_OUTWARD_DIRS = {
	[0] = Vector(-1, 0), -- 左侧门
	[1] = Vector(0, -1), -- 上方门
	[2] = Vector(1, 0), -- 右侧门
	[3] = Vector(0, 1), -- 下方门
}

-- 绘制单扇连接雷达微型房间的一扇门
local function DrawSingleRadarDoor(door, slot, roomCenter, radarCenterPos, isMirror, radarScale)
	if not door then
		return
	end

	-- 算出房间门向中心延申了多少
	local doorOffset = door.Position - roomCenter

	-- 根据 DoorSlot 枚举找出该房门朝向外面延申的空间方向
	local doorDir = DOOR_OUTWARD_DIRS[slot % 4] or Vector.Zero

	-- 镜子世界的横向对开转换
	if isMirror then
		doorOffset.X = -doorOffset.X
		doorDir = Vector(-doorDir.X, doorDir.Y)
	end

	-- extraPixels: 在门离房间中心的绝对比例偏置后，再外探多加这几颗像素让门脱离紧贴边缘
	local extraPixels = 12
	local drawPos = radarCenterPos + (doorOffset * radarScale) + (doorDir * extraPixels)

	local doorSprite = door:GetSprite()
	local oldScaleX, oldScaleY = doorSprite.Scale.X, doorSprite.Scale.Y
	local oldFlipX = doorSprite.FlipX

	-- 放缩 3.5 倍的参数来突出门的轮廓显示
	doorSprite.Scale = Vector(radarScale * 3.5, radarScale * 3.5)
	if isMirror then
		doorSprite.FlipX = not oldFlipX
	end

	doorSprite:Render(drawPos, Vector.Zero, Vector.Zero)

	doorSprite.Scale = Vector(oldScaleX, oldScaleY)
	if isMirror then
		doorSprite.FlipX = oldFlipX
	end
end

-- 绘制雷达上的门
local function DrawRadarDoors(radarCenterPos, isMirror, radarScale)
	local room = Game():GetRoom()
	local roomCenter = (room:GetTopLeftPos() + room:GetBottomRightPos()) / 2

	for i = 0, DoorSlot.NUM_DOOR_SLOTS - 1 do
		DrawSingleRadarDoor(room:GetDoor(i), i, roomCenter, radarCenterPos, isMirror, radarScale)
	end
end

local function OnRender()
	-- 如果未按住地图键，就不显示雷达
	if not Input.IsActionPressed(ButtonAction.ACTION_MAP, Game():GetPlayer(0).ControllerIndex) then
		return
	end

	local room = Game():GetRoom()
	local shape = room:GetRoomShape()

	-- 判定是否为大房间 (1x1=1, IH半房=2, IV半房=3。大于3说明尺寸必定大过1x1)
	local isLargeRoom = (shape > RoomShape.ROOMSHAPE_IV)
	local hasFlip = BISAI_PLUS.GameUtils.HasCollectible(CollectibleType.COLLECTIBLE_FLIP)
	-- 看不见地图诅咒 (Curse of the Lost) 检测
	local hasLostCurse = (Game():GetLevel():GetCurses() & LevelCurse.CURSE_OF_THE_LOST) > 0

	local showItemRadar = isLargeRoom or hasFlip
	local showDoorRadar = isLargeRoom and hasLostCurse

	-- 若没有任何需要显示的雷达项，直接退出
	if not showItemRadar and not showDoorRadar then
		return
	end

	-- 雷达的中心位置
	local radarCenterPos = Vector(120, 140)
	-- 是否是镜子
	local isMirror = room:IsMirrorWorld()
	-- 雷达缩放比例
	local radarScale = 0.125

	-- 渲染房间的门
	if showDoorRadar then
		DrawRadarDoors(radarCenterPos, isMirror, radarScale)
	end

	-- 渲染道具底座
	if showItemRadar then
		-- 在逻辑分离后，仅在渲染层开启时收集底座数据即可
		local validItems = GatherRadarItems()
		DrawRadarItems(validItems, radarCenterPos, isMirror, radarScale)
	end
end

local function OnNewRoom()
	FlipTransientState.RoomPedestalSeeds = {}
end

local function OnGameStarted(_, isContinued)
	if not isContinued then
		local data = API.GetSaveData() or {}
		data.Pedestals = {}
		API.SetSaveData(data)
	end
end

BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, OnNewRoom)
BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, OnGameStarted)
BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_UPDATE, OnUpdate)
BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_GET_COLLECTIBLE, OnGetCollectible)
BISAI_PLUS:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, OnPreUseFlip, CollectibleType.COLLECTIBLE_FLIP)
BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, OnCollectibleInit, PickupVariant.PICKUP_COLLECTIBLE)
BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_RENDER, OnRender)
