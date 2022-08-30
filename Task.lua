-- custom task library

local create, resume, wrap, running, yield, cancel = coroutine.create, coroutine.resume, coroutine.wrap, coroutine.running, coroutine.yield, coroutine.cancel
local unpack = table.unpack
local type = type
local clock = os.clock
local run_service = game:GetService("RunService")
local render_stepped, heartbeat, stepped = run_service.RenderStepped, run_service.Heartbeat, run_service.Stepped

local Task = {}

function wait_for_resumption()
    local finished = false
    local thread = running()

    local render_connection, heartbeat_connection, stepped_connection
    
    local function resume_thread()
        if finished then
            return
        end

        finished = true
        resume(thread)

        render_connection:Disconnect(); heartbeat_connection:Disconnect(); stepped_connection:Disconnect()
    end
    
    render_connection = render_stepped:Connect(resume_thread)
    heartbeat_connection = heartbeat:Connect(resume_thread)
    stepped_connection = stepped:Connect(resume_thread)

    yield()
end

function Task.spawn(f, ...)
    if type(f) == "function" then
        local thread = create(f)
        resume(thread, ...)

        return thread
    end

    resume(f, ...)
    return f
end

-- slower than normal defer, wouldnt use
function Task.defer(f, ...)
    return Task.spawn(function(...)
        wait_for_resumption()
        f(...)
    end, ...)
end

-- more accurate than task.wait
function Task.wait(duration)
    duration = duration or 0
    local start = clock()

    repeat 
        wait_for_resumption()
    until 
        clock() - start >= duration

    return clock() - start
end

function Task.delay(duration, f, ...)
    Task.spawn(function(...)
        Task.wait(duration)

        if type(f) == "function" then
            f(...)
        else
            resume(f, ...)
        end
    end, ...)
end

function Task.cancel(thread)
    cancel(thread)
end

return Task
