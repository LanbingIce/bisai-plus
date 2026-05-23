-- 记录首次使用铁索的逻辑帧
local function OnUseAnimaSola(_, itemID, rng, player, useFlags, activeSlot, customVarData)
	if itemID ~= CollectibleType.COLLECTIBLE_ANIMA_SOLA then
		return
	end

	-- 角色需要是堕化雅各
	local pType = player:GetPlayerType()
	if pType ~= PlayerType.PLAYER_JACOB_B and pType ~= PlayerType.PLAYER_JACOB2_B then
		return
	end

	-- 插槽需要是口袋主动（副手主动）
	if activeSlot ~= ActiveSlot.SLOT_POCKET then
		return
	end

	local data = player:GetData()
	data.BisaiPlus_LastAnimaSolaFrame = Game():GetFrameCount()
end

-- 直接从物理按键层面上拦截短时间内的二次使用（释放）
local function OnInputAction(_, entity, inputHook, action)
	if action ~= ButtonAction.ACTION_PILLCARD then
		return
	end

	if not entity then
		return
	end

	local player = entity:ToPlayer()
	if not player then
		return
	end

	local data = player:GetData()
	local lastUseFrame = data.BisaiPlus_LastAnimaSolaFrame
	if not lastUseFrame then
		return
	end

	local currentFrame = Game():GetFrameCount()
	local framesSinceLastUse = currentFrame - lastUseFrame

	-- 如果已经经过了6帧，或者帧数倒流（例如重开游戏），则清除标记
	if framesSinceLastUse >= 6 or framesSinceLastUse < 0 then
		data.BisaiPlus_LastAnimaSolaFrame = nil
		return
	end

	-- 6帧内禁止再次按下副手主动
	if framesSinceLastUse > 0 and framesSinceLastUse < 6 then
		if inputHook == InputHook.IS_ACTION_TRIGGERED then
			return false
		end
	end
end

BISAI_PLUS:AddCallback(ModCallbacks.MC_USE_ITEM, OnUseAnimaSola, CollectibleType.COLLECTIBLE_ANIMA_SOLA)
BISAI_PLUS:AddCallback(ModCallbacks.MC_INPUT_ACTION, OnInputAction)
