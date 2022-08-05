-- custom UIListLayout

local remove = table.remove
local setmetatable = setmetatable
local newUDim2 = UDim2.new

local List = {}
List.__index = List

function List.new(object, padding)
    return setmetatable({
        _contentSize = 0,
        _padding = padding,
        _positions = {},
        _object = object,
        _objects = {},
        _indexes = {},
        _sizes = {}
    }, List)
end

function List:GetAbsoluteContentSize()
    return self._contentSize
end

List.GetContentSize = List.GetAbsoluteContentSize

function List:AddObject(object)
    local size = object.AbsoluteSize.Y
    local idx = #self._objects + 1
    local padding = #self._objects * self._padding
    local position = self._contentSize + padding

    if object.Parent ~= self._object then
        object.Parent = self._object
    end

    object.Position = newUDim2(0, 0, 0, position)

    self._objects[idx] = object
    self._positions[object] = position
    self._indexes[object] = idx
    self._sizes[object] = size

    self._contentSize += size
end

function List:RemoveObject(object)
    local size = self._sizes[object] + self._padding
    local idx = self._indexes[object]

    for i, obj in next, self._objects do
        if i > idx then
            self._indexes[obj] -= 1
            obj.Position = newUDim2(0, 0, 0, self._positions[obj] - size)
        end
    end

    remove(self._objects, idx)
    self._contentSize -= size
end

function List:UpdateObject(object)
    local diff = object.AbsoluteSize.Y - self._sizes[object]
    local idx = self._indexes[object]

    for i, obj in next, self._objects do
        if i > idx then
            self._positions[obj] += diff
            obj.Position = newUDim2(0, 0, 0, self._positions[obj] + size)
        end
    end

    self._sizes[object] += diff
    self._contentSize += difference
end
