-- WorkOrderFetcher.lua
local DataFetcherClass = require("MODEL.DataFetcherClass") 
local logger = require("UTIL.logger")
local MeUtils= require("UTIL.meUtils")
local RessourceClass = require("MODEL.RessourceClass")




local RessourceFetcherClass = {}

RessourceFetcherClass.__index = RessourceFetcherClass
setmetatable(RessourceFetcherClass, { __index = DataFetcherClass })

function RessourceFetcherClass:new(colonyPeripheral, workOrderId, externalChest)

    self = setmetatable(DataFetcherClass:new(), RessourceFetcherClass)
    self.colonyPeripheral = colonyPeripheral
    self.workOrderId = workOrderId
    self.externalChest = externalChest
    self.ressourceList = nil
    return self
end

function RessourceFetcherClass:getMeDataPerItemMap()
    local items = {}

    local CraftableItems = MeUtils.getCraftableItems()
    for _, value in pairs(CraftableItems) do
        items[value.name] = value
    end
    local CurrentMeItems = MeUtils.getItemList()
    for _, value in pairs(CurrentMeItems) do
        items[value.name] = value
    end
    return items
end

function RessourceFetcherClass:getExternalInventoryItems()
    local externalInventoryItemMap = {}
    if not self.externalChest then
        logger.log("No external chest found!")
    else
        externalInventoryItemMap = self.externalChest:getAllItems()
    end
    return externalInventoryItemMap
end

function RessourceFetcherClass:getRessourceRequirementsFromColony()

    local ressourceRequirementFromColony = self.colonyPeripheral:getWorkOrderResources(self.workOrderId)[1]
    if not ressourceRequirementFromColony then
        ressourceRequirementFromColony = {}
        logger.log("Colony Peripheral did not answer!")
    end
    return ressourceRequirementFromColony
end

function RessourceFetcherClass:getObs()
    local ressourceObList = {}

    local ressourceRequirementFromColony = self:getRessourceRequirementsFromColony()
    local meDataPerItemMap = self:getMeDataPerItemMap()
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