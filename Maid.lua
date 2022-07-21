local setmetatable = setmetatable
local typeof = typeof
local next = next

local Maid = {}

function Maid.new()
	return setmetatable({
		_tasks = {}
	}, Maid)
end

function Maid:GiveTask(task)
	local class = typeof(task)

	if class ~= "Instance" and class ~= "RBXScriptConnection" and (class ~= "table" or not class.Disconnect) then
		return
	end

    self._tasks[task] = true
end

function Maid:RemoveTask(task)
	self._tasks[task] = nil
end

function Maid:Destroy()
	local task, _ = next(self._tasks)
	
	while task do
		self._tasks[task] = nil

		if typeof(task) == "Instance" then
			task:Destroy()
		else
			task:Disconnect()
		end

		task, _ = next(self._tasks)
	end
end

Maid.DoCleaning = Maid.Destroy
Maid.Disconnect = Maid.Destroy
Maid.CleanUp = Maid.Destroy

return Maid
