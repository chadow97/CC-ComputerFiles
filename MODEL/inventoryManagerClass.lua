-- InventoryManagerClass.lua
local ManagerClass = require("MODEL.ManagerClass")  -- Adjust the path if necessary
local PerTypes     = require("UTIL.perTypes")
local InventoryClass = require("MODEL.inventoryClass")
local logger         = require("UTIL.logger")
local ChestWrapper   = require("UTIL.chestWrapper")


local InventoryManagerClass = {}
InventoryManagerClass.__index = InventoryManagerClass
setmetatable(InventoryManagerClass, { __index = ManagerClass })

InventoryManagerClass.TYPE = "Inventory"
-- Constructor for InventoryManagerClass
function InventoryManagerClass:new(document)
    self = setmetatable(ManagerClass:new(document), InventoryManagerClass)
    self.type = InventoryManagerClass.TYPE
    self.inventories = {}
    return self
end

function InventoryManagerClass:_getObsInternal()
    return self.inventories
end

function InventoryManagerClass:getFirstInventory()
    return self:getObs()[1]
end

function InventoryManagerClass:getDefaultInventory()
    return self:getFirstInventory()
end

function InventoryManagerClass:_onRefreshObs()
    self.inventories = {}
    local chests = {peripheral.find(PerTypes.chest)}
    if not chests then
        chests = {}
    end
    local barrels = {peripheral.find(PerTypes.barrel)}
    if not barrels then
        barrels = {}
    end
    for _, chest in pairs(chests) do
        local inventoryOb = InventoryClass:new(ChestWrapper:new(chest))
        table.insert(self.inventories, inventoryOb)
    end
    for _, barrel in pairs(barrels) do
        local inventoryOb = InventoryClass:new(ChestWrapper:new(barrel))
        table.insert(self.inventories, inventoryOb)
    end
end

return InventoryManagerClass