-- WorkOrderFetcher.lua
local logger = require("UTIL.logger")
local MeItemClass = require("COLONY.MODEL.MeItemClass")
local ManagerClass = require("MODEL.ManagerClass")
local MeSystemManagerClass  = require "COMMON.MODEL.MeSystemManagerClass"

local MeItemManagerClass = {}

MeItemManagerClass.TYPE = "ME_ITEM"

MeItemManagerClass.__index = MeItemManagerClass
setmetatable(MeItemManagerClass, { __index = ManagerClass })

function MeItemManagerClass:new(document)
    local o = setmetatable(ManagerClass:new(document), MeItemManagerClass)
    o.type = MeItemManagerClass.TYPE
    o.itemByIdMap = {}
    o.meSystemManager = o.document:getManagerForType(MeSystemManagerClass.TYPE)

    return o
end

function MeItemManagerClass:getOb(uniqueKey)
    self:_refreshIfNeeded()
    return self.itemByIdMap[uniqueKey]

end

function MeItemManagerClass:getObEvenIfMissing(uniqueKey)
    local ob = self:getOb(uniqueKey)
    if ob then
        return ob
    end
    return MeItemClass:createMissingItem(uniqueKey)
end

function MeItemManagerClass:getObs()
    -- override get obs because we want to return a vector and not a map
    self:_refreshIfNeeded()
    local obs = {}
    for _, ob in pairs(self:_getObsInternal()) do
        table.insert(obs,ob)
    end
    return obs
end

function MeItemManagerClass:getItemMap()
self:_refreshIfNeeded()
return self.itemByIdMap
end

function MeItemManagerClass:_getObsInternal()
    return self.itemByIdMap
end

function MeItemManagerClass:_onRefreshObs()
    local processedItemsIDs = {}
    for _, meItemData in ipairs(self:getMeItems()) do

        local potentialOb = MeItemClass:new(meItemData)

        local currentOb = self:getOb(potentialOb:getUniqueKey())
        if not currentOb then
            self.itemByIdMap[potentialOb:getUniqueKey()] = potentialOb 
        else
            currentOb:copyFrom(potentialOb)
        end
        processedItemsIDs[potentialOb:getUniqueKey()] = true
    end

    for key, _ in pairs(self.itemByIdMap) do
        if not processedItemsIDs[key] then
            self.itemByIdMap[key] = nil
        end
    end

    
end

function MeItemManagerClass:getMeItems()
    local meItems = {}
    local meSystem = self.meSystemManager:getDefaultMeSystem()
    if not meSystem then
        logger.log("No me system, cannot sent all!", logger.LOGGING_LEVEL.WARNING)
        return meItems
    end

    local CraftableItems = meSystem.getCraftableItems()
    for _, value in pairs(CraftableItems) do
        table.insert(meItems,value)
    end
    local CurrentMeItems = meSystem.getItemList()
    for _, value in pairs(CurrentMeItems) do
        table.insert(meItems,value)
    end
    return meItems 
end


return MeItemManagerClass