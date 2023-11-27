
local DocumentClass = require("MODEL.DocumentClass")  -- Adjust the path if necessary
local InventoryManagerClass = require("COLONY.MODEL.InventoryManagerClass")
local BuilderManagerClass = require("COLONY.MODEL.BuilderManagerClass")
local ColonyManagerClass  = require("COLONY.MODEL.ColonyManagerClass")
local RequestManagerClass = require("COLONY.MODEL.RequestManagerClass")
local RequestItemManagerClass = require("COLONY.MODEL.RequestItemManagerClass")
local MeItemManagerClass      = require("COLONY.MODEL.MeItemManagerClass")
local MeSystemManagerClass    = require("COLONY.MODEL.MeSystemManagerClass")
local ColonyConfigClass = require("COLONY.MODEL.ColonyConfigClass")
local logger                  = require("UTIL.logger")


local ColonyDocumentClass = {}
ColonyDocumentClass.__index = ColonyDocumentClass
setmetatable(ColonyDocumentClass, { __index = DocumentClass })

-- Constructor for WorkOrderClass
function ColonyDocumentClass:new(colonyPeripheral)

    local colonyConfig = ColonyConfigClass:new()
    local o = setmetatable(DocumentClass:new(colonyConfig), ColonyDocumentClass)

    -- register managers used in colony
    o:registerManager(InventoryManagerClass:new(o))
    o:registerManager(BuilderManagerClass:new(colonyPeripheral, o))
    o:registerManager(ColonyManagerClass:new(colonyPeripheral, o))
    o:registerManager(RequestManagerClass:new(colonyPeripheral, o))
    o:registerManager(RequestItemManagerClass:new(colonyPeripheral, o))
    o:registerManager(MeSystemManagerClass:new(o))
    o:registerManager(MeItemManagerClass:new(o))

    return o
end

return ColonyDocumentClass