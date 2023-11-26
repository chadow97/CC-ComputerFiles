-- WorkOrderFetcher.lua
local colIntUtil = require("UTIL.colonyIntegratorPerUtils")
local logger = require("UTIL.logger")
local RequestManagerClass = require("MODEL.RequestManagerClass")
local RequestItemClass    = require("MODEL.RequestItemClass")

local RequestItemManagerClass = {}

RequestItemManagerClass.TYPE = "REQUEST_ITEM"

RequestItemManagerClass.__index = RequestItemManagerClass
setmetatable(RequestItemManagerClass, { __index = ManagerClass })

function RequestItemManagerClass:new(colonyPeripheral, document)
    local o = setmetatable(ManagerClass:new(document), RequestItemManagerClass)
    o.colonyPeripheral = colonyPeripheral
    o.type = RequestItemManagerClass.TYPE
    o.requestManager = document:getManagerForType(RequestManagerClass.TYPE)
    o.requestItems = {}

    return o
end

function RequestItemManagerClass:_getObsInternal()
    return self.requestItems
end

function RequestItemManagerClass:getItemsForRequest(requestId)

    local request = self.requestManager:getOb(requestId)
    return request:getItems()
end

function RequestItemManagerClass:_onRefreshObs()
    local requestObs = self.requestManager:getObs()
    for _, requestOb in ipairs(requestObs) do
        local itemsForRequest = {}
        for _, requestItemData in ipairs(requestOb.items) do
            local potentialOb = RequestItemClass:new(requestItemData, requestOb, self)

            local currentOb = self:getOb(potentialOb:getUniqueKey())
            if not currentOb then
                table.insert(self.requestItems, potentialOb)
                table.insert(itemsForRequest, potentialOb)        
            else
                currentOb:copyFrom(potentialOb)
                table.insert(itemsForRequest, currentOb) 
            end   
        end

        requestOb:setItems(itemsForRequest)

    end
end

return RequestItemManagerClass