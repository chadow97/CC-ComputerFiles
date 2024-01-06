
local DocumentClass = require("MODEL.DocumentClass")  -- Adjust the path if necessary
local InventoryManagerClass = require("COMMON.MODEL.InventoryManagerClass")
local BuilderManagerClass = require("COLONY.MODEL.BuilderManagerClass")
local ColonyManagerClass  = require("COLONY.MODEL.ColonyManagerClass")
local RequestManagerClass = require("COLONY.MODEL.RequestManagerClass")
local RequestItemManagerClass = require("COLONY.MODEL.RequestItemManagerClass")
local MeItemManagerClass      = require("COLONY.MODEL.MeItemManagerClass")
local MeSystemManagerClass    = require("COLONY.MODEL.MeSystemManagerClass")
local ColonyConfigClass = require("COLONY.MODEL.ColonyConfigClass")
local logger                  = require("UTIL.logger")
local PeripheralManagerClass  = require("COMMON.MODEL.PeripheralManagerClass")
local ColonyStyleClass        = require("COLONY.MODEL.ColonyStyleClass")
local ColonyConnectionProviderClass = require("COLONY.MODEL.ColonyConnectionProviderClass")


---@class ColonyDocument:Document
local ColonyDocumentClass = {}
ColonyDocumentClass.__index = ColonyDocumentClass
setmetatable(ColonyDocumentClass, { __index = DocumentClass })

-- Constructor for WorkOrderClass
function ColonyDocumentClass:new()

    local o = setmetatable(DocumentClass:new(), ColonyDocumentClass)
    o:initializeDocument()

    -- register managers used in colony
    o:registerManager(InventoryManagerClass:new(o))
    -- make sure to initialize peripherals after inventory as it uses the mgr
    o:registerManager(PeripheralManagerClass:new(o, ColonyConnectionProviderClass:new(o)))

    o:registerManager(MeSystemManagerClass:new(o))
    o:registerManager(MeItemManagerClass:new(o))

    o:registerManager(ColonyManagerClass:new(o))
    o:registerManager(BuilderManagerClass:new(o))
    o:registerManager(RequestManagerClass:new( o))
    o:registerManager(RequestItemManagerClass:new(o))

    return o
end

function ColonyDocumentClass:initializeStyle()
    self.style = ColonyStyleClass:new(self.config:getStyles())
end

function ColonyDocumentClass:initializeConfig()
    self.config = ColonyConfigClass:new()
end

function ColonyDocumentClass:updateStyleFromConfig()
    self.style:updateStyle(self.config:getStyles())
end

return ColonyDocumentClass