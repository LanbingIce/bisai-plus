local IsRerolling = false

-- 野生道具权重表，代表道具在野生生成的情况下被保留的概率，没列出的道具默认是1
local NaturalItemPoolWeights = {
	-- 隐藏房道具池
	[ItemPoolType.POOL_SECRET] = {
		[CollectibleType.COLLECTIBLE_WE_NEED_TO_GO_DEEPER] = 0, -- 我们需要深入挖掘！
		[CollectibleType.COLLECTIBLE_EPIC_FETUS] = 0, -- 史诗胎儿博士
		[CollectibleType.COLLECTIBLE_PYRO] = 0, -- 烟火盛宴
		[CollectibleType.COLLECTIBLE_D_INFINITY] = 0, -- 无限面骰
		[CollectibleType.COLLECTIBLE_ROCK_BOTTOM] = 0, -- 谷底石
		[CollectibleType.COLLECTIBLE_MEGA_MUSH] = 0, -- 超级蘑菇
		[CollectibleType.COLLECTIBLE_DEATH_CERTIFICATE] = 0, -- 死亡证明
		[CollectibleType.COLLECTIBLE_BINGE_EATER] = 0, -- 大胃王
		[CollectibleType.COLLECTIBLE_GLITCHED_CROWN] = 0, -- 错误王冠
		[CollectibleType.COLLECTIBLE_SACRED_ORB] = 0, -- 十字圣球
		[CollectibleType.COLLECTIBLE_FLIP] = 0, -- 生死逆转
		[CollectibleType.COLLECTIBLE_SPINDOWN_DICE] = 0, -- 计数二十面骰
	},
}

-- 检查指定种子下生成的道具是否应该被保留
local function ShouldKeepItem(poolType, seed)
	local pool = Game():GetItemPool()

	-- 偷看一下这个是什么道具，不实际影响道具池
	local itemId = pool:GetCollectible(poolType, false, seed)

	-- 取这个道具在野生权重表里的权重，如果没有配置这个道具的权重，默认就是1（完全保留）
	local targetWeights = NaturalItemPoolWeights[poolType]
	local itemWeight = targetWeights and targetWeights[itemId] or 1

	-- 初始化一个随机数生成器，用这个种子来初始化
	local weightRng = RNG()
	weightRng:SetSeed(seed, 0)

	-- 产生一个随机数，如果这个随机数小于道具的权重，就保留这个道具
	return weightRng:RandomFloat() < itemWeight
end

local function OnPreGetCollectible(_, poolType, decrease, seed)
	-- 如果正在进行重Roll，直接放行，防止死循环
	if IsRerolling then
		return
	end

	-- 在表里检索当前正在触发生成的道具池，如果没有配置该道具池的降权规则，直接放行
	if not NaturalItemPoolWeights[poolType] then
		return
	end

	local room = Game():GetRoom()

	-- 这是回溯途中触发了七巧板，直接放行
	if room:GetType() == RoomType.ROOM_BOSS then
		return
	end

	local level = Game():GetLevel()

	-- 这是其他情况下触发了七巧板，直接放行
	if level:GetCurrentRoomIndex() == level:GetStartingRoomIndex() then
		return
	end

	-- 如果不是进入房间的第一帧，直接放行
	if room:GetFrameCount() > 1 then
		return
	end

	-- 进入重Roll状态
	IsRerolling = true

	-- 记录最终要生成的道具ID
	local finalItemId

	-- 首次判定：原来的道具是否需要保留
	if not ShouldKeepItem(poolType, seed) then
		-- 创建一个随机数生成器用于生成道具，用这个原先的种子来初始化
		local rng = RNG()
		rng:SetSeed(seed, 35)

		-- 记录最终要生成的道具的种子
		local successSeed = nil

		-- 尝试生成一个合法的道具，最多尝试1000次，如果可以成功生成，记录下成功的种子
		for _ = 1, 1000 do
			local nextSeed = rng:Next()
			if ShouldKeepItem(poolType, nextSeed) then
				successSeed = nextSeed
				break
			end
		end

		if successSeed then
			local pool = Game():GetItemPool()
			-- 用成功的种子进行一次真正的道具生成，得到其ID，这次生成会在道具池中降权
			finalItemId = pool:GetCollectible(poolType, decrease, successSeed)
		end
	end

	-- 统一的出口，退出重Roll状态
	IsRerolling = false
	-- 如果成功找到了一个合法的道具，返回这个道具ID，否则返回的是nil,代表放行
	return finalItemId
end

BISAI_PLUS:AddCallback(ModCallbacks.MC_PRE_GET_COLLECTIBLE, OnPreGetCollectible)
