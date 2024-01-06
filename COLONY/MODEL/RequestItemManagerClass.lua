-- WorkOrderFetcher.lua
local logger = require("UTIL.logger")
local RequestManagerClass = require("COLONY.MODEL.RequestManagerClass")
local RequestItemClass    = require("COLONY.MODEL.RequestItemClass")
local MeItemManagerClass  = require("COLONY.MODEL.MeItemManagerClass")
local InventoryManagerClass = require("COMMON.MODEL.InventoryManagerClass")
local PeripheralManagerClass= require("COMMON.MODEL.PeripheralManagerClass")

---@class RequestItemManager: Manager
local RequestItemManagerClass = {}

RequestItemManagerClass.TYPE = "REQUEST_ITEM"

RequestItemManagerClass.__index = RequestItemManagerClass
setmetatable(RequestItemManagerClass, { __index = ManagerClass })

function RequestItemManagerClass:new(document)
    ---@class RequestItemManager: Manager
    local o = setmetatable(ManagerClass:new(document), RequestItemManagerClass)
    o.colonyPeripheral = document:getManagerForType(PeripheralManagerClass.TYPE):getMainColonyPeripheral()
    o.type = RequestItemManagerClass.TYPE
    o.requestManager = document:getManagerForType(RequestManagerClass.TYPE)
    o.meItemManager = document:getManagerForType(MeItemManagerClass.TYPE)
    o.inventoryManager = document:getManagerForType(InventoryManagerClass.TYPE)
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
    local requestInventory = self.inventoryManager:getRequestInventory()
    for _, requestOb in ipairs(requestObs) do
        local itemsForRequest = {}
        for _, requestItemData in ipairs(requestOb.items) do
            local meItemInfo = self.meItemManager:getObEvenIfMissing(requestItemData.name)
            assert(meItemInfo, "didnt return object!")
            local amountInExternalInventory = requestInventory:getItemAmount(requestItemData.name)
            local potentialOb = RequestItemClass:new(requestItemData, meItemInfo, amountInExternalInventory, requestOb, self)

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