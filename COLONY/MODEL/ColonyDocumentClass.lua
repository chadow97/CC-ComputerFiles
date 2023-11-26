-- WorkOrderClass.lua
local DocumentClass = require("MODEL.DocumentClass")  -- Adjust the path if necessary
local InventoryManagerClass = require("MODEL.InventoryManagerClass")
local BuilderManagerClass = require("MODEL.BuilderManagerClass")
local ColonyManagerClass  = require("MODEL.ColonyManagerClass")
local RequestManagerClass = require("MODEL.RequestManagerClass")
local RequestItemManagerClass = require("MODEL.RequestItemManagerClass")

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



    return self
end

return ColonyDocumentClass