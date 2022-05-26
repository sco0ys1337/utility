-- made by vozoid B)

local Signal = {}

do
    local instance_new = Instance.new
    local coroutine_wrap = coroutine.wrap
    local table_clear = table.clear
    local setmetatable = setmetatable

    Signal.__index = Signal

    function Signal.new()
        local self = setmetatable({}, Signal)

        self._bindable_event = instance_new("BindableEvent")
        self._event = self._bindable_event.Event
        self._connections = {}

        return self
    end

    function Signal:Fire(...)
        return self._bindable_event:Fire(...)
    end

    function Signal:Connect(callback)
        local connection = self._event:Connect(callback)
        self._connections[connection] = true

        return connection
    end

    function Signal:Wait()
        return self._event:Wait()
    end

    function Signal:DisconnectAll()
        for connection, _ in next, self._connections do
            if connection.Connected then
                connection:Disconnect()
            end
        end

        self._connections = {}
    end

    function Signal:Destroy()
        if self._bindable_event then
            self._bindable_event:Destroy()
            self._bindable_event = nil
            self._event = nil
        end

        self:DisconnectAll()
        setmetatable(self, nil)

        table_clear(self)
    end
end

return Signal
