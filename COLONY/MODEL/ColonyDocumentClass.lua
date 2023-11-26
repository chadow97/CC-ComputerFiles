-- WorkOrderClass.lua
local DocumentClass = require("MODEL.DocumentClass")  -- Adjust the path if necessary
local InventoryManagerClass = require("COLONY.MODEL.InventoryManagerClass")
local BuilderManagerClass = require("COLONY.MODEL.BuilderManagerClass")
local ColonyManagerClass  = require("COLONY.MODEL.ColonyManagerClass")
local RequestManagerClass = require("COLONY.MODEL.RequestManagerClass")
local RequestItemManagerClass = require("COLONY.MODEL.RequestItemManagerClass")
local MeItemManagerClass      = require("COLONY.MODEL.MeItemManagerClass")

local ColonyDocumentClass = {}
ColonyDocumentClass.__index = ColonyDocumentClass

setmetatable(ColonyDocumentClass, { __index = DocumentClass })

-- Constructor for WorkOrderClass
function ColonyDocumentClass:new(colonyPeripheral)

    self = setmetatable(DocumentClass:new(), ColonyDocumentClass)

    self:registerManager(InventoryManagerClass:new(self))
    self:registerManager(BuilderManagerClass:new(colonyPeripheral, self))
    self:registerManager(ColonyManagerClass:new(colonyPeripheral, self))
    self:registerManager(RequestManagerClass:new(colonyPeripheral, self))
    self:registerManager(RequestItemManagerClass:new(colonyPeripheral, self))
    self:registerManager(MeItemManagerClass:new(self))


    return self
end

return ColonyDocumentClass