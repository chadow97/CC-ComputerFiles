-- InventoryManagerClass.lua
local ManagerClass = require("MODEL.ManagerClass")  -- Adjust the path if necessary
local PerTypes     = require("UTIL.perTypes")
local InventoryClass = require("COLONY.MODEL.InventoryClass")
local logger         = require("UTIL.logger")
local ChestWrapper   = require("UTIL.InventoryWrapperClass")


local InventoryManagerClass = {}
InventoryManagerClass.__index = InventoryManagerClass
setmetatable(InventoryManagerClass, { __index = ManagerClass })
InventoryManagerClass.HANDLED_TYPES = {PerTypes.chest, PerTypes.barrel}

InventoryManagerClass.TYPE = "Inventory"
-- Constructor for InventoryManagerClass
function InventoryManagerClass:new(document)
    local o = setmetatable(ManagerClass:new(document), InventoryManagerClass)
    o.type = InventoryManagerClass.TYPE
    o.inventories = {}
    o.requestInventoryHandler = TableFileHandlerClass:new(document.config:getRequestInventoryPath())
    return o
end

function InventoryManagerClass.isTypeHandled(type)
    for _, handledType in ipairs(InventoryManagerClass.HANDLED_TYPES) do
        if handledType == type then
            return true
        end
    end
    return false
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

function InventoryManagerClass:getRequestInventory()
    local currentInventoryKey = self.requestInventoryHandler:read()[1]
    if not currentInventoryKey then
        error("No inventory to consider for request!")
    end
    local inventoryOb = self:getOb(currentInventoryKey)
    if not inventoryOb then
        error("Couldnt find inventory for requests")
    end
    return inventoryOb
end

function InventoryManagerClass:_onRefreshObs()
    self.inventories = {}
---@diagnostic disable-next-line: param-type-mismatch
    local chests = {peripheral.find(PerTypes.chest)}
    if not chests then
        chests = {}
    end
---@diagnostic disable-next-line: param-type-mismatch
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