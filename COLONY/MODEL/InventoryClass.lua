-- InventoryClass.lua
local ObClass = require("MODEL.ObClass")  -- Adjust the path if necessary
local stringUtils = require("UTIL.stringUtils")
local PeripheralClass = require("COLONY.MODEL.PeripheralClass")
local logger          = require("UTIL.logger")


local InventoryClass = {}
InventoryClass.__index = InventoryClass
setmetatable(InventoryClass, { __index = PeripheralClass })

-- Constructor for InventoryClass
function InventoryClass:new(inventoryWrapper)
    local uniqueKey = inventoryWrapper:getName()
    local o = setmetatable(PeripheralClass:new(inventoryWrapper.per), InventoryClass)
    o.name = uniqueKey
    o.InventoryWrapper = inventoryWrapper

    return o
end

function InventoryClass:__tostring()
    return stringUtils.UFormat("[Inventory object %s]", self.name)
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

function InventoryClass:getAllItems()
    return self.InventoryWrapper:getAllItems()
end

function InventoryClass:getItemAmount(uniqueKey)
    local itemMap = self.InventoryWrapper:getAllItems()
    local amount = itemMap[uniqueKey]
    if not amount then
        amount = 0
    end
    return amount
end

function InventoryClass:__index(key)
    if InventoryClass[key] then
        return InventoryClass[key]
    elseif PeripheralClass[key] then
        return PeripheralClass[key]
    elseif ObClass[key] then
        return ObClass[key]
    else
        return self.inventoryWrapper.per[key]
    end
end



return InventoryClass