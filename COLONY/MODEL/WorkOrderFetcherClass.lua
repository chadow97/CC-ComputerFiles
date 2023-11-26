-- WorkOrderFetcher.lua
local DataFetcherClass = require("MODEL.DataFetcherClass") 
local WorkOrderClass = require("COLONY.MODEL.WorkOrderClass")
local colIntUtil = require("UTIL.colonyIntegratorPerUtils")
local logger = require("UTIL.logger")




local WorkOrderFetcherClass = {}

WorkOrderFetcherClass.__index = WorkOrderFetcherClass
setmetatable(WorkOrderFetcherClass, { __index = DataFetcherClass })

function WorkOrderFetcherClass:new(colonyPeripheral)
    self = setmetatable(DataFetcherClass:new(), WorkOrderFetcherClass)
    self.colonyPeripheral = colonyPeripheral
    return self
end

function WorkOrderFetcherClass:getObs()
    local workOrderObList = {}
    for _, workOrderData in ipairs(self:getWorkOrders()) do
        local builderHutData = colIntUtil.getBuilderHutInfoFromWorkOrder(self.colonyPeripheral, workOrderData)
        table.insert(workOrderObList,WorkOrderClass.CreateWorkOrder(workOrderData, builderHutData))
    end

    return workOrderObList
end

function WorkOrderFetcherClass:getWorkOrders()
    local status, workOrders = pcall(colIntUtil.getWorkOrders, self.colonyPeripheral)
    if not status then
        workOrders = {}
    end
    return workOrders
end

return WorkOrderFetcherClass