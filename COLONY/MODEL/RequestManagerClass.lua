-- WorkOrderFetcher.lua
local colIntUtil = require("UTIL.colonyIntegratorPerUtils")
local logger = require("UTIL.logger")
local RequestClass = require("MODEL.RequestClass")

local RequestManagerClass = {}

RequestManagerClass.TYPE = "REQUEST"

RequestManagerClass.__index = RequestManagerClass
setmetatable(RequestManagerClass, { __index = ManagerClass })

function RequestManagerClass:new(colonyPeripheral, document)
    local o = setmetatable(ManagerClass:new(document), RequestManagerClass)
    o.colonyPeripheral = colonyPeripheral
    o.type = RequestManagerClass.TYPE
    o.requests = {}

    return o
end

function RequestManagerClass:_getObsInternal()
    return self.requests
end

function RequestManagerClass:_onRefreshObs()
    for index, requestData in ipairs(self:getRequests()) do

        local potentialOb = RequestClass:new(requestData, self)

        local currentOb = self:getOb(potentialOb:getUniqueKey())
        if not currentOb then
            table.insert(self.requests, potentialOb)         
        else
            currentOb:copyFrom(potentialOb)
        end

    end
end

function RequestManagerClass:getRequests()
    local status, requests = pcall(colIntUtil.getRequests, self.colonyPeripheral)
    if not status then
        requests = {}
    end
    return requests
end


return RequestManagerClass