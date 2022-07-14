--[[
    Drawing api list stuff idk
]]

local Signal = loadstring(game:HttpGet("https://raw.githubusercontent.com/vozoid/utility/main/Signal.lua"))()

local List = {}
List.__index = List

-- Localization
local typeof = typeof
local table_remove = table.remove
local vector2_new = Vector2.new
local rawget = rawget
local rawset = rawset

local set_render_property = islclosure(Drawing.new) and getupvalue(getupvalue(Drawing.new, 4).__newindex, 4) or setrenderproperty or function(object, property, value)
    object[property] = value
end

local get_render_property = islclosure(Drawing.new) and getupvalue(getupvalue(Drawing.new, 4).__index, 4) or getrenderproperty or function(object, property)
    return object[property]
end

--[[
    Creates a new list
    @return List (table)
]]

function List.new(position, padding)
    local self = setmetatable({}, List)

    self.Updated = Signal.new()
    self.AbsoluteContentSize = 0
    self._padding = padding
    self._position = position
    self._objectPositions = {}
    self._objects = {}
    self._objectIndexes = {}
    self._objectSizes = {}
    self._objectQueues = {}

    return self
end

--[[
    Adds an object to a list
]]

function List:AddObject(object)
    if object._class == "Square" or object._class == "Image" then        
        local size = object.AbsoluteSize.Y

        local idx = #self._objects + 1
        local position = self.AbsoluteContentSize

        local new_position = self._position + vector2_new(0, position)
        object._properties.AbsolutePosition = new_position

        if object.AbsoluteVisible then
            set_render_property(object._render, "Position", new_position)

            if object._outline then
                set_render_property(object._outline, "Position", object.AbsolutePosition - vector2_new(1, 1))
            end
        else
            object._queue.Position = new_position
        end

        self._objects[idx] = object
        self._objectPositions[object] = position
        self._objectIndexes[object] = idx
        self._objectSizes[object] = size
        self._objectQueues[object] = {}

        self.AbsoluteContentSize += size + self._padding
        self.Updated:Fire(self.AbsoluteContentSize)
    end
end

--[[
    Removes an object from the list
]]

function List:RemoveObject(removed_object)
    local size = removed_object.AbsoluteSize.Y
    local idx = self._objectIndexes[removed_object]

    for i, object in next, self._objects do
        if i > idx then
            self._objectIndexes[object] -= 1
            self._objectPositions[object] -= (size + self._padding)

            local new_position = self._position + vector2_new(0, self._objectPositions[object])
            if object.AbsoluteVisible then
                set_render_property(object._render, "Position", new_position)
            else
                object._queue.Position = new_position
            end
        end
    end

    table_remove(self._objects, idx)

    self.AbsoluteContentSize -= size
    self.Updated:Fire(self.AbsoluteContentSize)
end

--[[
    Updates the list based on the selected objects size
]]

function List:UpdateObject(updated_object)
    -- Gets the difference between the new size and the old size of the object
    local difference = updated_object.AbsoluteSize.Y - self._objectSizes[updated_object]
    local idx = self._objectIndexes[updated_object]

    for i, object in next, self._objects do
        if i > idx then
            self._objectPositions[object] += difference
            local new_position = self._position + vector2_new(0, self._objectPositions[object])
            object._properties.AbsolutePosition = new_position

            if object.AbsoluteVisible then
                set_render_property(object, "Position", new_position)

                if object._outline then
                    set_render_property(object._outline, "Position", object.AbsolutePosition - vector2_new(1, 1))
                end
            else
                object._queue.Position = new_position
            end
        end
    end

    self._objectSizes[updated_object] = updated_object.AbsoluteSize.Y 

    self.AbsoluteContentSize += difference
    self.Updated:Fire(self.AbsoluteContentSize)
end

--[[
    Updates the position of the list
]]

function List:UpdatePosition(position)
    for _, object in next, self._objects do
        local new_position = position + vector2_new(0, self._objectPositions[object])
        object._properties.AbsolutePosition = new_position

        if object.AbsoluteVisible then
            set_render_property(object._render, "Position", new_position)

            if object._outline then
                set_render_property(object._outline, "Position", object.AbsolutePosition - vector2_new(1, 1))
            end
        else
            object._queue.Position = new_position
        end
    end
    
    self.Updated:Fire(self.AbsoluteContentSize)
    self._position = position
end

--[[
    Updates the padding of the list
]]

function List:UpdatePadding(padding)
    -- Gets the difference between the new padding and the old padding of the list
    local difference = padding - self._padding

    for i, object in next, self._objects do
        if i > 1 then
            local added = (i - 1) * difference
            self._objectPositions[object] += added
            local new_position = object.AbsolutePosition + vector2_new(0, added)
            if object.AbsoluteVisible then
                set_render_property(object, "Position", new_position)
            else
                object._queue = new_position
            end
        end
    end

    self.Updated:Fire(self.AbsoluteContentSize)
    self._padding = padding
end

return List
