-- ObClass.lua
ObClass = {}
ObClass.__index = ObClass

-- Constructor for ObClass
function ObClass:new(uniqueKey)
    local self = setmetatable({}, ObClass)
    self.uniqueKey = uniqueKey  -- Storing the unique key
    return self
end

function ObClass:getUniqueKey()
    return self.uniqueKey
end


function ObClass:GetDisplayString()
    -- No implementation
end


function ObClass:GetKeyDisplayString()
    -- No implementation
end

function ObClass:copyFrom(ob)
    if ob == self then
        return
    end
    for key  in pairs(self) do
        self[key] = nil
    end
    for key, value in pairs(ob) do
        self[key] = value
    end
end

function ObClass:getObStyle()
    -- return elementBackColor, elementTextColor
    -- by default, nothing is overriden.
    return nil, nil
end

return ObClass