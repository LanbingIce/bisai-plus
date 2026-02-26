---@class Dispatcher
---@field public Dispatch fun(self: Dispatcher, task: function, frames?: integer)
---@field public Run fun(self: Dispatcher)
---@field public Clear fun(self: Dispatcher)

local Dispatcher = {}

---@class DispatcherTask
---@field frames integer
---@field task function

---@type DispatcherTask[]
local tasks = {}

---@param task function
---@param frames? integer
function Dispatcher:Dispatch(task, frames)
	table.insert(tasks, { frames = frames or 0, task = task })
end

function Dispatcher:Run()
	local currentTasks = tasks
	tasks = {} -- 重置主任务表，执行期间新加的任务会因 Dispatch 进入这里

	for i = 1, #currentTasks do
		local dTask = currentTasks[i]
		if dTask.frames <= 0 then
			local success, err = pcall(dTask.task)
			if not success then
				print("Dispatcher Task Error: " .. tostring(err))
			end
		else
			dTask.frames = dTask.frames - 1
			table.insert(tasks, dTask)
		end
	end
end

function Dispatcher:Clear()
	tasks = {}
end

return Dispatcher
