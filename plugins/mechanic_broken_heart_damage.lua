local function OnEvaluateCache(_, player, cacheFlag)
	if not BISAI_PLUS.GameUtils.IsRealPlayer(player) then
		return
	end

	local data = player:GetData()
	if cacheFlag == CacheFlag.CACHE_DAMAGE and data.BisaiPlus_TargetBrokenHearts then
		local currentBrokenHearts = player:GetBrokenHearts()

		-- 骨哥需要把本体和灵魂的碎心加起来
		local subPlayer = player:GetSubPlayer()
		if subPlayer then
			currentBrokenHearts = currentBrokenHearts + subPlayer:GetBrokenHearts()
		end
		player.Damage = player.Damage * (1 + currentBrokenHearts / 10)
	end
end

BISAI_PLUS:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, OnEvaluateCache)
