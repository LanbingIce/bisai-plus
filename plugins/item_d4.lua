local pendingRerollCount = 0
local pendingRemoveCount = 0

-- 检查道具是否可被重随
local function CanReroll(id, itemConfig)
	local config = itemConfig:GetCollectible(id)
	-- 排除空号
	if not config then
		return false
	end
	-- 排除主动
	if config.Type == ItemType.ITEM_ACTIVE then
		return false
	end
	-- 排除剧情道具
	if (config.Tags & ItemConfig.TAG_QUEST) == ItemConfig.TAG_QUEST then
		return false
	end

	-- 排除特定不可重随道具
	if
		id == CollectibleType.COLLECTIBLE_DAMOCLES_PASSIVE -- 被动达摩克利斯之剑
		or id == CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES -- 美德之书
		or id == CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL_PASSIVE -- 犹大长子权的被动恶魔书
		or id == CollectibleType.COLLECTIBLE_MISSING_NO -- 七巧板
	then
		return false
	end

	return true
end

-- 统计玩家持有的可重随道具数
local function CountRerollableItems(player)
	local count = 0
	local itemConfig = Isaac.GetItemConfig()
	---@diagnostic disable-next-line: undefined-field
	local maxID = itemConfig:GetCollectibles().Size - 1

	for id = 1, maxID do
		if CanReroll(id, itemConfig) then
			count = count + player:GetCollectibleNum(id, true)
		end
	end

	return count
end

local function OnUpdate()
	pendingRerollCount = 0
	pendingRemoveCount = 0
end

local function OnUseItem(_, item, rng, player, flags, slot, varData)
	if not BISAI_PLUS.GameUtils.IsRealPlayer(player) then
		return
	end

	if item ~= CollectibleType.COLLECTIBLE_D4 then
		return
	end

	-- 排除骰子房效果(一/六点)
	if flags & UseFlag.USE_REMOVEACTIVE == UseFlag.USE_REMOVEACTIVE then
		return
	end

	-- 排除里伊甸
	if player:GetPlayerType() == PlayerType.PLAYER_EDEN_B then
		return
	end

	-- 排除有七巧板的情况
	if player:HasCollectible(CollectibleType.COLLECTIBLE_MISSING_NO) then
		return
	end

	pendingRerollCount = CountRerollableItems(player)
	-- 删除最后八分之一的道具，向上取整
	pendingRemoveCount = math.ceil(pendingRerollCount / 8)

	-- 下一帧移除产生的临时占位道具(煤块)
	for _ = 1, pendingRemoveCount do
		BISAI_PLUS.Dispatcher:Dispatch(function()
			player:RemoveCollectible(CollectibleType.COLLECTIBLE_LUMP_OF_COAL)
		end)
	end
end

local function OnGetCollectible()
	if pendingRerollCount == 0 then
		return
	end

	-- 将最后生成的几个道具替换为煤块，用于后续删除（因为煤块是普通模式下绝不会被roll出来的道具，也不影响属性）
	if pendingRerollCount <= pendingRemoveCount then
		pendingRerollCount = pendingRerollCount - 1
		return CollectibleType.COLLECTIBLE_LUMP_OF_COAL
	end

	pendingRerollCount = pendingRerollCount - 1
end

BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_UPDATE, OnUpdate)
BISAI_PLUS:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, OnUseItem)
BISAI_PLUS:AddCallback(ModCallbacks.MC_PRE_GET_COLLECTIBLE, OnGetCollectible)
