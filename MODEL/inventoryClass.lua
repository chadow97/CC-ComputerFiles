-- InventoryClass.lua
local ObClass = require("MODEL.obClass")  -- Adjust the path if necessary


local InventoryClass = {}
InventoryClass.__index = InventoryClass
setmetatable(InventoryClass, { __index = ObClass })

-- Constructor for InventoryClass
function InventoryClass:new(inventoryWrapper)
    local uniqueKey = inventoryWrapper:getName()
    self = setmetatable(ObClass:new(uniqueKey), InventoryClass)
    self.name = uniqueKey
    self.InventoryWrapper = inventoryWrapper

    return self
end

-- Overriding GetKeyDisplayString method
function InventoryClass:GetKeyDisplayString()
    return self.uniqueKey
end

-- Overriding GetDisplayString method
function InventoryClass:GetDisplayString()
    local displayString = string.format(self.uniqueKey)
    return displayString
end



return InventoryClass