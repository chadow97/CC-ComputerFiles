-- WorkOrderFetcher.lua
local DataFetcherClass = require("MODEL.dataFetcherClass") 
local colIntUtil = require("UTIL.colonyIntegratorPerUtils")
local logger = require("UTIL.logger")
local BuilderClass = require("MODEL.builderClass")




local BuilderFetcherClass = {}

BuilderFetcherClass.__index = BuilderFetcherClass
setmetatable(BuilderFetcherClass, { __index = DataFetcherClass })

function BuilderFetcherClass:new(colonyPeripheral)
    self = setmetatable(DataFetcherClass:new(), BuilderFetcherClass)
    self.colonyPeripheral = colonyPeripheral
    return self
end

function BuilderFetcherClass:getData()
    local builderObList = {}
    for _, builderData in ipairs(self:getBuilders()) do
        local builderHutData = colIntUtil.getBuilderHutInfoFromWorkOrder(self.colonyPeripheral, builderData)
        table.insert(builderObList,BuilderClass:new(builderData))
    end

    return builderObList
end

function BuilderFetcherClass:getBuilders()
    local status, builders = pcall(colIntUtil.getBuilders, self.colonyPeripheral)
    if not status then
        builders = {}
    end
    return builders
end

return BuilderFetcherClass