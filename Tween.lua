--[[
    Linear tween, usually gets time off by around 0.015 seconds
    Works with drawing objects
]]

local Signal = loadstring(game:HttpGet("https://raw.githubusercontent.com/vozoid/utility/main/Signal.lua"))()
local Tween = {}

do
    -- localization
    local render_stepped = game:GetService("RunService").RenderStepped
    local tick = tick
    local math_min = math.min
    local task_spawn = task.spawn
    local task_wait = task.wait
    local next = next

    Tween.__index =  Tween

    --[[
        Creates a new tween
        @return Tween (table)
    ]]

    function Tween.new(object, time, values)
        local self = setmetatable({}, Tween)

        self.Completed = Signal.new()
        self._object = object
        self._values = values
        self._time = time

        return self
    end

    --[[
        Plays the tween
    ]]

    function Tween:Play()
        local loops = {}

        -- Loop through every property to edit
        for property, value in next, self._values do
            local start_time = tick()
            local start_value = self._object[property]

            -- Creates loop and adds it to the loop table (No table.insert, its slower)
            loops[#loops + 1] = render_stepped:Connect(function()
                task_spawn(function()
                    -- Changes the objects property with lerp(value, delta / time)
                    self._object[property] = start_value:lerp(value, (tick() - start_time) / self._time)
                end)
            end)
        end

        task_spawn(function()
            task_wait(self._time)
            self.Completed:Fire()

            -- Disconnects every loop
            for _, connection in next, loops do
                connection:Disconnect()
            end
        end)
    end
end

return Tween
