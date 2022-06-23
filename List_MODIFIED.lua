local Signal = loadstring(game:HttpGet("https://raw.githubusercontent.com/vozoid/utility/main/Signal.lua"))()

--[[
    Drawing api list stuff idk
]]

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

    return self
end

--[[
    Adds an object to a list
]]

function List:AddObject(object)
    if type(object) == "table" then
        object = rawget(object, "__OBJECT")
    end
    
    local size = get_render_property(object, "Size").Y

    local idx = #self._objects + 1
    local padding = #self._objects * self._padding
    local position = self.AbsoluteContentSize + padding

    set_render_property(object, "Position", self._position + vector2_new(0, position))

    self._objects[idx] = object
    self._objectPositions[object] = position
    self._objectIndexes[object] = idx
    self._objectSizes[object] = size

    self.AbsoluteContentSize += size
    self.Updated:Fire(self.AbsoluteContentSize)
end

--[[
    Removes an object from the list
]]

function List:RemoveObject(removed_object)
    local size = get_render_property(removed_object, "Size").Y + self._padding
    local idx = self._objectIndexes[removed_object]

    for i, object in next, self._objects do
        if i > idx then
            self._objectIndexes[object] -= 1
            set_render_property(object, "Position", get_render_property(object, "Position") - vector2_new(0, size))
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
    if type(updated_object) == "table" then
        updated_object = rawget(updated_object, "__OBJECT")
    end

    -- Gets the difference between the new size and the old size of the object
    local difference = get_render_property(updated_object, "Size").Y - self._objectSizes[updated_object]
    local idx = self._objectIndexes[updated_object]

    for i, object in next, self._objects do
        if i > idx then
            self._objectPositions[object] += difference
            set_render_property(object, "Position", get_render_property(object, "Position") + vector2_new(0, difference))
        end
    end

    self._objectSizes[updated_object] = get_render_property(updated_object, "Size").Y 

    self.AbsoluteContentSize += difference
    self.Updated:Fire(self.AbsoluteContentSize)
end

--[[
    Updates the position of the list
]]

function List:UpdatePosition(position)
    for i, object in next, self._objects do
        set_render_property(object, "Position", position + vector2_new(0, self._objectPositions[object]))
    end
    
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
            set_render_property(object, "Position", get_render_property(object, "Position") + vector2_new(0, added))
        end
    end

    self._padding = padding
end

return List
