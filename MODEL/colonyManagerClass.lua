-- WorkOrderFetcher.lua
local colIntUtil = require("UTIL.colonyIntegratorPerUtils")
local logger = require("UTIL.logger")
local BuilderClass = require("MODEL.builderClass")
local TableFileHandlerClass = require("UTIL.tableFileHandlerClass")
local InventoryManagerClass = require("MODEL.inventoryManagerClass")
local ColonyClass           = require("MODEL.colonyClass")

local DEFAULT_FILE_PATH = "./DATA/associations.txt"

local ColonyManagerClass = {}

ColonyManagerClass.TYPE = "COLONY"

ColonyManagerClass.__index = ColonyManagerClass
setmetatable(ColonyManagerClass, { __index = ManagerClass })

function ColonyManagerClass:new(colonyPeripheral, document)
    local o = setmetatable(ManagerClass:new(), ColonyManagerClass)
    o.colonyPeripheral = colonyPeripheral
    o.type = ColonyManagerClass.TYPE
    o.colony = nil
    o.shouldRefresh = true
    o.document = document

    return o
end

function ColonyManagerClass:getData()
    self.shouldRefresh = true
    return ManagerClass.getData(self)
end


function ColonyManagerClass:getObs()
    if self.shouldRefresh then
        self:refreshObjects()
    end
    return {self.colony}
end

function ColonyManagerClass:getColony()
    self:getObs() -- refresh if needed.
    return self.colony
end

function ColonyManagerClass:clear()
    self.colony = nil
    self.shouldRefresh = true
end

function ColonyManagerClass:refreshObjects()
    self.shouldRefresh = false

    self.colony = ColonyClass:new(self:getColonyData())

end


function ColonyManagerClass:getColonyData()
    local colonyData = {}

    local status, colonyData = pcall(colIntUtil.getColony, self.colonyPeripheral)
    if not status then
        colonyData = {}
    end
    return colonyData
end


return ColonyManagerClass