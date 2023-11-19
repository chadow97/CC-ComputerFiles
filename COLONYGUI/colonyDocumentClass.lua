-- WorkOrderClass.lua
local DocumentClass = require("MODEL.documentClass")  -- Adjust the path if necessary
local InventoryManagerClass = require("MODEL.inventoryManagerClass")
local BuilderManagerClass = require("MODEL.builderManagerClass")

local ColonyDocumentClass = {}
ColonyDocumentClass.__index = ColonyDocumentClass
setmetatable(ColonyDocumentClass, { __index = DocumentClass })

-- Constructor for WorkOrderClass
function ColonyDocumentClass:new(colonyPeripheral)

    self = setmetatable(DocumentClass:new(), ColonyDocumentClass)


    self:registerManager(InventoryManagerClass:new())
    self:registerManager(BuilderManagerClass:new(colonyPeripheral))

    return self
end

return ColonyDocumentClass