-- ObClass.lua
ObClass = {}
ObClass.__index = ObClass

-- Constructor for ObClass
function ObClass:new(uniqueKey)
    local self = setmetatable({}, ObClass)
    self.uniqueKey = uniqueKey  -- Storing the unique key
    return self
end


function ObClass:GetDisplayString()
    -- No implementation
end


function ObClass:GetKeyDisplayString()
    -- No implementation
end



function ObClass:getObStyle()
    -- return elementBackColor, elementTextColor
    -- by default, nothing is overriden.
    return nil, nil
end

return ObClass