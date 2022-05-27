-- made by vozoid B)

local Signal = {}

do
    -- genv cache, makes everything slightly faster
    local instance_new = Instance.new
    local coroutine_wrap = coroutine.wrap
    local table_clear = table.clear
    local setmetatable = setmetatable

    Signal.__index = Signal

    --[[
        Creates a new signal
        @return Signal (table)
    ]]

    function Signal.new()
        local self = setmetatable({}, Signal)

        self._bindable_event = instance_new("BindableEvent")
        self._event = self._bindable_event.Event
        self._connections = {}

        return self
    end

    --[[
        Fires the connections with the argument ...
    ]]

    function Signal:Fire(...)
         self._bindable_event:Fire(...)
    end

    --[[
        Create a new connection. Returns a connection which can be disconnected. Callback called when :Fire(...) is called
        @return RBXScriptConnection
    ]]

    function Signal:Connect(callback)
        local connection = self._event:Connect(callback)

        -- Add connection to the connections table
        self._connections[connection] = true

        return connection
    end

    --[[
        Yields the thread until :Fire(...) is called. Returns the arguments that :Fire(...) provided.
    ]]

    function Signal:Wait()
        return self._event:Wait()
    end

    --[[
        Disconnects all connections to the signal. The signal is still useable after calling this.
    ]]

    function Signal:DisconnectAll()
        for connection, _ in next, self._connections do
            -- Check if connection hasnt been disconnected
            if connection.Connected then
                -- Disconnects connection
                connection:Disconnect()
            end
        end

        -- Clears all connections
        self._connections = {}
    end

     --[[
        Destroys the BindableEvent and disconnects all connections to the signal. The signal is still unusable after calling this.
        Clears the table and sets the metatable to nil.
    ]]

    function Signal:Destroy()
        if self._bindable_event then
            -- Destroys the BindableEvent and sets the BindableEvent and Event to nil
            self._bindable_event:Destroy()
            self._bindable_event = nil
            self._event = nil
        end

        -- Disconnects all connections
        self:DisconnectAll()

        -- Makes the signal unusable
        setmetatable(self, nil)
        table_clear(self)
    end
end

return Signal
