local ActiveCooldowns = 0
local function OnInputAction(_, entity, inputHook, action)
	-- 进房间的第一帧，禁止使用主动，防止出现传送类主动卡住的bug
	if ActiveCooldowns == 0 then
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

local function OnNewRoom()
	ActiveCooldowns = 1
end

local function OnUpdate()
	if ActiveCooldowns > 0 then
		ActiveCooldowns = ActiveCooldowns - 1
	end
end

BISAI_PLUS:AddCallback(ModCallbacks.MC_INPUT_ACTION, OnInputAction)
BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, OnNewRoom)
BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_UPDATE, OnUpdate)
