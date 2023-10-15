-- WorkOrderClass.lua
local DocumentClass = require("MODEL.documentClass")  -- Adjust the path if necessary
local InventoryManagerClass = require("MODEL.inventoryManagerClass")

local ColonyDocumentClass = {}
ColonyDocumentClass.__index = ColonyDocumentClass
setmetatable(ColonyDocumentClass, { __index = DocumentClass })

-- Constructor for WorkOrderClass
function ColonyDocumentClass:new()

    self = setmetatable(DocumentClass:new(), ColonyDocumentClass)


    self:registerManager(InventoryManagerClass:new())

    return self
end

return ColonyDocumentClass