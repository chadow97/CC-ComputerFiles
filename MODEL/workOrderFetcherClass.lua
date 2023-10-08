-- WorkOrderFetcher.lua
local DataFetcherClass = require("MODEL.dataFetcherClass") 
local WorkOrderClass = require("MODEL.workOrderClass")
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

function WorkOrderFetcherClass:getData()
    local WorkOrderObList = {}
    for _, WorkOrderData in ipairs(self:getWorkOrders()) do
        table.insert(WorkOrderObList,WorkOrderClass.CreateWorkOrder(WorkOrderData))
    end

    return WorkOrderObList
end

function WorkOrderFetcherClass:getWorkOrders()
    local status, workOrders = pcall(colIntUtil.getWorkOrders, self.colonyPeripheral)
    if not status then
        logger.log(workOrders)
        logger.log(debug.traceback())
        workOrders = {}
    end
    return workOrders
end

return WorkOrderFetcherClass