-- WorkOrderFetcher.lua
local DataFetcherClass = require("MODEL.managerClass") 
local colIntUtil = require("UTIL.colonyIntegratorPerUtils")
local logger = require("UTIL.logger")
local BuilderClass = require("MODEL.builderClass")




local BuilderManagerClass = {}

BuilderManagerClass.TYPE = "BUILDER"

BuilderManagerClass.__index = BuilderManagerClass
setmetatable(BuilderManagerClass, { __index = ManagerClass })

function BuilderManagerClass:new(colonyPeripheral)
    self = setmetatable(ManagerClass:new(), BuilderManagerClass)
    self.colonyPeripheral = colonyPeripheral
    self.type = BuilderManagerClass.TYPE
    self.builders = {}
    self.shouldRefresh = true

    return self
end

function BuilderManagerClass:getData()

    self.shouldRefresh = true
    return ManagerClass.getData(self)
end


function BuilderManagerClass:getObs(type)
    if self.shouldRefresh then
        self:refreshObjects()
    end
    return self.builders
end

function BuilderManagerClass:clear()
    self.builders = {}
    self.shouldRefresh = true
end

function BuilderManagerClass:refreshObjects()
    self.builders = {}
    for _, builderData in ipairs(self:getBuilders()) do
        table.insert(self.builders, BuilderClass:new(builderData))
    end
    self.shouldRefresh = false
end

function BuilderManagerClass:getBuilders()
    local status, builders = pcall(colIntUtil.getBuilders, self.colonyPeripheral)
    if not status then
        builders = {}
    end
    return builders
end


return BuilderManagerClass