---@alias EventListener fun(...: any)
---@alias CommandHandler fun(...: any): any

---@class MessageBus
---@field On fun(self:MessageBus, event:Event, listener:EventListener)
---@field Handle fun(self:MessageBus, command:Command, handler:CommandHandler)
---@field Send fun(self:MessageBus, command:Command, ...:any):any
---@field Emit fun(self:MessageBus, event:Event, ...:any)
---@field Clear fun(self:MessageBus)

---@type table<Event, EventListener[]>
local event_listeners = {}
---@type table<Command, CommandHandler>
local command_handlers = {}

local MessageBus = {}

---@param event Event
---@param listener EventListener
function MessageBus:On(event, listener)
	if not event_listeners[event] then
		event_listeners[event] = {}
	end
	table.insert(event_listeners[event], listener)
end

---@param command Command
---@param handler CommandHandler
function MessageBus:Handle(command, handler)
	if command_handlers[command] then
		error("Handler for command '" .. tostring(command) .. "' is already registered.")
	end
	command_handlers[command] = handler
end

---@param command Command
---@param ... any
---@return any
function MessageBus:Send(command, ...)
	local handler = command_handlers[command]
	if handler then
		return handler(...)
	else
		error("No handler registered for command '" .. tostring(command) .. "'.")
	end
end

---@param event Event
---@param ... any
function MessageBus:Emit(event, ...)
	local listeners = event_listeners[event]
	if listeners then
		for _, listener in ipairs(listeners) do
			local success, err = pcall(listener, ...)
			if not success then
				print("[MessageBus] Error in event listener for '" .. tostring(event) .. "': " .. tostring(err))
			end
		end
	end
end

function MessageBus:Clear()
	event_listeners = {}
	command_handlers = {}
end

return MessageBus
