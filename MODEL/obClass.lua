-- ObClass.lua
ObClass = {}
ObClass.__index = ObClass

-- Constructor for ObClass
function ObClass:new(uniqueKey)
    local self = setmetatable({}, ObClass)
    self.uniqueKey = uniqueKey  -- Storing the unique key
    return self
end

-- Method GetDisplayString with no implementation
function ObClass:GetDisplayString()
    -- No implementation
end

-- Method GetKeyDisplayString with no implementation
function ObClass:GetKeyDisplayString()
    -- No implementation
end

return ObClass