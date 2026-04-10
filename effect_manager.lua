local Shared = require("bisai+.shared")
local Messages = require("bisai+.messages")
local MessageBus = require("bisai+.message_bus")

---@class EffectManager
local EffectManager = {}

---@param payload { Goal: integer }
function EffectManager.OnGoalSet(payload)
	local goal = payload.Goal
	local goalInfo = Shared.GoalData[goal]
	if goalInfo and goalInfo.OnSelect then
		pcall(goalInfo.OnSelect)
	end
end

MessageBus:On(Messages.Event.RUN_STARTED, EffectManager.OnGoalSet)
MessageBus:On(Messages.Event.GOAL_SET, EffectManager.OnGoalSet)

return EffectManager
