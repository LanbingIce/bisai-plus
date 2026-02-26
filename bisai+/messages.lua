---@enum Command
local Command = {
	UPDATE_CONFIG = "cmd.config.update",
	START_RUN = "cmd.run.start",
	PAUSE_RUN = "cmd.run.pause",
	RESUME_RUN = "cmd.run.resume",
	CREATE_RUN = "cmd.run.create",
	SELECT_CHARACTER = "cmd.character.select",
	SET_SEED = "cmd.seed.set",
	SET_GOAL = "cmd.goal.set",
}

---@enum Event
local Event = {
	CONFIG_UPDATED = "event.config.updated",
	RUN_STARTED = "event.run.started",
	RUN_PAUSED = "event.run.paused",
	RUN_RESUMED = "event.run.resumed",
	RUN_CREATED = "event.run.created",
	RUN_RESTORED = "event.run.restored",
	RUN_FINISHED = "event.run.finished",
	RECORD_UPDATED = "event.record.updated",
}

local Messages = {
	Command = Command,
	Event = Event,
}

return Messages
