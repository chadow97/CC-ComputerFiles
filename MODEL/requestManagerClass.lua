-- WorkOrderFetcher.lua
local colIntUtil = require("UTIL.colonyIntegratorPerUtils")
local logger = require("UTIL.logger")
local RequestClass = require("MODEL.requestClass")
local TableFileHandlerClass = require("UTIL.tableFileHandlerClass")
local InventoryManagerClass = require("MODEL.inventoryManagerClass")

local DEFAULT_FILE_PATH = "./DATA/associations.txt"

local RequestManagerClass = {}

RequestManagerClass.TYPE = "REQUEST"

RequestManagerClass.__index = RequestManagerClass
setmetatable(RequestManagerClass, { __index = ManagerClass })

function RequestManagerClass:new(colonyPeripheral, document)
    local o = setmetatable(ManagerClass:new(), RequestManagerClass)
    o.colonyPeripheral = colonyPeripheral
    o.type = RequestManagerClass.TYPE
    o.requests = {}
    o.shouldRefresh = true
    o.document = document

    return o
end

function RequestManagerClass:getData()

    self.shouldRefresh = true
    return ManagerClass.getData(self)
end


function RequestManagerClass:getObs()
    if self.shouldRefresh then
        self:refreshObjects()
    end
    return self.requests
end

function RequestManagerClass:clear()
    self.requests = {}
    self.shouldRefresh = true
end

function RequestManagerClass:refreshObjects()
    self.shouldRefresh = false
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