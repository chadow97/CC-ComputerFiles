-- WorkOrderFetcher.lua
local colIntUtil = require("UTIL.colonyIntegratorPerUtils")
local logger = require("UTIL.logger")
local BuilderClass = require("COLONY.MODEL.builderClass")
local TableFileHandlerClass = require("UTIL.tableFileHandlerClass")
local InventoryManagerClass = require("COLONY.MODEL.InventoryManagerClass")
local ColonyClass           = require("COLONY.MODEL.ColonyClass")

local DEFAULT_FILE_PATH = "./DATA/associations.txt"

local ColonyManagerClass = {}

ColonyManagerClass.TYPE = "COLONY"

ColonyManagerClass.__index = ColonyManagerClass
setmetatable(ColonyManagerClass, { __index = ManagerClass })

function ColonyManagerClass:new(colonyPeripheral, document)
    local o = setmetatable(ManagerClass:new(document), ColonyManagerClass)
    o.colonyPeripheral = colonyPeripheral
    o.type = ColonyManagerClass.TYPE
    o.colony = nil

    return o
end

function ColonyManagerClass:_getObsInternal()
    return {self.colony}
end

function ColonyManagerClass:getColony()
    self:getObs() -- refresh if needed.
    return self.colony
end

function ColonyManagerClass:clear()
    self.colony = nil
    ManagerClass.clear(self)
end

function ColonyManagerClass:_onRefreshObs()
    self.colony = ColonyClass:new(self:getColonyData())
end


function ColonyManagerClass:getColonyData()
    local status, colonyData = pcall(colIntUtil.getColony, self.colonyPeripheral)
    if not status then
        colonyData = {}
    end
    return colonyData
end


return ColonyManagerClass