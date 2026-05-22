local MessageBus = require("bisai+.message_bus")
local Messages = require("bisai+.messages")

local function OnGameEnd(_, isGameOver)
	if isGameOver then
		MessageBus:Send(Messages.Command.PAUSE_RUN)
	end
end

BISAI_PLUS:AddCallback(ModCallbacks.MC_POST_GAME_END, OnGameEnd)
