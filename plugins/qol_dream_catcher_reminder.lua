local dreamSprite = Sprite()
dreamSprite:Load("gfx/005.100_collectible.anm2", true)
local cfg = Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_DREAM_CATCHER)
if cfg then
	dreamSprite:ReplaceSpritesheet(1, cfg.GfxFileName)
end
dreamSprite:LoadGraphics()
dreamSprite:SetFrame("Idle", 0)

local renderData = {}
local function GetExits()
	local exits = {}
	local room = Game():GetRoom()

	-- 使用 GameUtils 寻找活板门
	local trapdoors = BISAI_PLUS.GameUtils.FindTrapdoor(room)
	for i = 1, #trapdoors do
		local grid = trapdoors[i]
		if grid.State == 1 then -- 1表示活板门已打开
			table.insert(exits, grid.Position)
		end
	end

	-- 寻找上天堂的光柱
	local heavenDoors = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.HEAVEN_LIGHT_DOOR, 0)
	for _, door in ipairs(heavenDoors) do
		table.insert(exits, door.Position)
	end

	return exits
end

local function OnUpdate()
	renderData = {}

	if not BISAI_PLUS.GameUtils.HasCollectible(CollectibleType.COLLECTIBLE_DREAM_CATCHER) then
		return
	end

	local exits = GetExits()
	if #exits == 0 then
		return
	end

	local maxDist = 160

	for i = 0, Game():GetNumPlayers() - 1 do
		local p = Game():GetPlayer(i)
		local minDist = 999999
		for _, exPos in ipairs(exits) do
			local dist = p.Position:Distance(exPos)
			if dist < minDist then
				minDist = dist
			end
		end

		if minDist < maxDist then
			table.insert(renderData, {
				PlayerIndex = i,
				Alpha = 1.0 - (minDist / maxDist),
			})
		end
	end
end

local function OnRender()
	if #renderData == 0 then
		return
	end

	for _, data in ipairs(renderData) do
		local p = Game():GetPlayer(data.PlayerIndex)
		if p then
			local renderPos = Isaac.WorldToScreen(p.Position)
			-- 如果在镜子世界中，渲染画面会沿屏幕中心发生水平翻转（但WorldToScreen没有处理这个），需要手动修正X轴
			if Game():GetRoom():IsMirrorWorld() then
				renderPos.X = Isaac.GetScreenWidth() - renderPos.X
			end

			local room = Game():GetRoom()
			-- 以撒中每个地块的大小为40，TopLeftPos 是左上角那块地的中心点
			local topRowY = room:GetTopLeftPos().Y + 40

			if p.Position.Y < topRowY then
				-- 玩家在最上面一行格子附近，显示在角色下方
				renderPos = renderPos + Vector(0, 40)
			else
				-- 玩家在其他部分，显示在角色上方
				renderPos = renderPos + Vector(0, -40)
			end

			-- 渲染捕梦网图标
			dreamSprite.Color = Color(1, 1, 1, data.Alpha, 0, 0, 0)
			dreamSprite.Scale = Vector(1, 1)
			dreamSprite:Render(renderPos, Vector.Zero, Vector.Zero)
		end
	end
end

local function OnNewRoom()
	renderData = {}
end

BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, OnNewRoom)
BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_UPDATE, OnUpdate)
BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_RENDER, OnRender)
