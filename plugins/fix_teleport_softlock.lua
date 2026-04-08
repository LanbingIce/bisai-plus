local function OnInputAction(_, entity, inputHook, action)
	-- 进房间的第一帧，禁止使用主动，防止出现传送类主动卡住的bug
	local roomFrameCount = Game():GetRoom():GetFrameCount()
	-- 不是第一帧的话，就放行
	if roomFrameCount > 1 then
		return
	end
	if not entity then
		return
	end

	local player = entity:ToPlayer()
	if not player then
		return
	end

	if inputHook ~= InputHook.IS_ACTION_TRIGGERED then
		return
	end

	if action ~= ButtonAction.ACTION_ITEM then
		return
	end

	return false
end

BISAI_PLUS:AddCallback(ModCallbacks.MC_INPUT_ACTION, OnInputAction)
