local function OnPlayerUpdate(_, player)
	local state = BISAI_PLUS.Data.Save.State
	-- 准备阶段和暂停状态禁止任何角色操作
	-- 丢弃键并不会因此而失效，需要使用按键回调单独禁用
	local isPaused = state == BISAI_PLUS.Shared.State.PAUSED or state == BISAI_PLUS.Shared.State.READY
	if not isPaused then
		return
	end
	player:AddControlsCooldown(1)
end

local function OnInputAction(_, entity, inputHook, action)
	-- 准备阶段禁用丢弃键，禁止丢弃饰品卡牌以及表骨哥切换角色的操作
	if BISAI_PLUS.Data.Save.State ~= BISAI_PLUS.Shared.State.READY then
		return
	end

	if not entity then
		return
	end

	-- 确保是玩家实体
	local player = entity:ToPlayer()
	if not player then
		return
	end

	-- 确保是丢弃键
	if action ~= ButtonAction.ACTION_DROP then
		return
	end

	return false
end

BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, OnPlayerUpdate)
BISAI_PLUS:AddCallback(ModCallbacks.MC_INPUT_ACTION, OnInputAction)
