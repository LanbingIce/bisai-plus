-- 记录上一帧的右键状态
local WasRightMousePressed = false
-- 记录当前帧的右键状态，减少 Input.IsMouseBtnPressed 的调用次数
local IsRightMousePressedNow = false

local function OnUpdate()
	if not Options.MouseControl then
		return
	end
	-- 更新上一帧状态为当前帧状态
	WasRightMousePressed = IsRightMousePressedNow
	-- 获取并缓存新的当前帧状态，供 InputAction 使用
	IsRightMousePressedNow = Input.IsMouseBtnPressed(Mouse.MOUSE_BUTTON_2)
end

local function OnInputAction(_, entity, inputHook, action)
	-- 将消耗最低的检查放在最前面，尽早 return
	if not Options.MouseControl or action ~= ButtonAction.ACTION_DROP then
		return
	end

	if not entity then
		return
	end
	local player = entity:ToPlayer()
	if not player or not BISAI_PLUS.GameUtils.IsRealPlayer(player) then
		return
	end

	-- 直接使用在 OnUpdate 中缓存的鼠标状态，避免频繁调用 C++ API
	if inputHook == InputHook.IS_ACTION_PRESSED then
		if IsRightMousePressedNow then
			return true
		end
	elseif inputHook == InputHook.IS_ACTION_TRIGGERED then
		if IsRightMousePressedNow and not WasRightMousePressed then
			return true
		end
	end
end

BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_UPDATE, OnUpdate)
BISAI_PLUS:AddCallback(ModCallbacks.MC_INPUT_ACTION, OnInputAction)
