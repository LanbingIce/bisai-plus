local Messages = require("bisai+.messages")
local MessageBus = require("bisai+.message_bus")

local function OnRunFinished(payload)
	if BISAI_PLUS.Shared.GoalData[BISAI_PLUS.Shared.Goal.BEAST].IsRoom() then
		Isaac.ExecuteCommand("stage 1")
	end
end

MessageBus:On(Messages.Event.RUN_FINISHED, OnRunFinished)
