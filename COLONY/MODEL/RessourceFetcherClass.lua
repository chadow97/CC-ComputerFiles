-- WorkOrderFetcher.lua
local DataFetcherClass = require("MODEL.DataFetcherClass") 
local logger = require("UTIL.logger")
local MeSystemManagerClass  = require "COMMON.MODEL.MeSystemManagerClass"
local RessourceClass = require("COLONY.MODEL.RessourceClass")
local MeItemManagerClass   = require("COLONY.MODEL.MeItemManagerClass")




local RessourceFetcherClass = {}

RessourceFetcherClass.__index = RessourceFetcherClass
setmetatable(RessourceFetcherClass, { __index = DataFetcherClass })

function RessourceFetcherClass:new(colonyPeripheral, workOrderId, externalChest, document)

    self = setmetatable(DataFetcherClass:new(), RessourceFetcherClass)
    self.colonyPeripheral = colonyPeripheral
    self.workOrderId = workOrderId
    self.externalChest = externalChest
    self.ressourceList = nil
    self.document = document
    self.meItemManager = document:getManagerForType(MeItemManagerClass.TYPE)
    self.meSystemManager = self.document:getManagerForType(MeSystemManagerClass.TYPE)
    return self
end

function RessourceFetcherClass:getMeDataPerItemMap()
    local items = {}
    local meSystem = self.meSystemManager:getDefaultMeSystem()
    if not meSystem then
        logger.log("No me system, cannot fetch ressources!", logger.LOGGING_LEVEL.WARNING)
        return
    end

    local CraftableItems = meSystem.getCraftableItems()
    for _, value in pairs(CraftableItems) do
        items[value.name] = value
    end
    local CurrentMeItems = meSystem.getItemList()
    for _, value in pairs(CurrentMeItems) do
        items[value.name] = value
    end
    return items
end

function RessourceFetcherClass:getExternalInventoryItems()
    local externalInventoryItemMap = {}
    if not self.externalChest then
        logger.log("No external chest found!", logger.LOGGING_LEVEL.ERROR)
    else
        externalInventoryItemMap = self.externalChest:getAllItems()
    end
    return externalInventoryItemMap
end

function RessourceFetcherClass:getRessourceRequirementsFromColony()
    logger.db(self.workOrderId)

    local ressourceRequirementFromColony = self.colonyPeripheral:getWorkOrderResources(self.workOrderId)
    if not ressourceRequirementFromColony then
        ressourceRequirementFromColony = {}
        logger.log("Colony Peripheral did not answer!", logger.LOGGING_LEVEL.ERROR)
    end
    return ressourceRequirementFromColony
end

function RessourceFetcherClass:getObs()
    local ressourceObList = {}

    local ressourceRequirementFromColony = self:getRessourceRequirementsFromColony()
    local meDataPerItemMap = self.meItemManager:getItemMap()
    local externalInventoryItemMap = self:getExternalInventoryItems()

    for _, ressourceRequirement in pairs(ressourceRequirementFromColony) do

        -- CreateDefaultValues if no items in external invertory or me system
        local amountInExternalInventory = externalInventoryItemMap[ressourceRequirement.item]
        if not amountInExternalInventory then
            amountInExternalInventory = 0
        end

        local meDataForRessource = meDataPerItemMap[ressourceRequirement.item]
        if not meDataForRessource then
            meDataForRessource = {amount = 0, isCraftable = false}
        end

        local ressourceOb = RessourceClass.CreateRessource(ressourceRequirement, meDataForRessource, amountInExternalInventory)
        table.insert(ressourceObList, ressourceOb)
    end

    table.sort(ressourceObList, RessourceClass.SortByStatusFunction)
    self.ressourceList = ressourceObList

    return ressourceObList
end

function RessourceFetcherClass:getAllRessourcesWithoutRefreshing()
    if not self.ressourceList then
        error("Trying to get uninitialized ressource list!")
    end
    return self.ressourceList
end




return RessourceFetcherClass