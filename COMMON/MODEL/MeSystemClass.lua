-- MeSystemClass.lua
local ObClass = require("MODEL.ObClass")  -- Adjust the path if necessary
local stringUtils = require("UTIL.stringUtils")
local PeripheralClass = require("COMMON.MODEL.PeripheralClass")
local logger          = require("UTIL.logger")


local MeSystemClass = {}
MeSystemClass.__index = MeSystemClass
setmetatable(MeSystemClass, { __index = PeripheralClass })

-- Constructor for MeSystemClass
function MeSystemClass:new(mePeripheral)
    local o = setmetatable(PeripheralClass:new(mePeripheral), MeSystemClass)

    o.name = o.uniqueKey

    o.availableItemStorage = 0
    o.usedItemStorage = 0
    o.totalItemStorage = 0
    o.cells = {}
    o.craftingCpus = {}
    o.energyStorage = 0
    o.maxEnergyStorage = 0
    o.energyUsage = 0
    
    o:updateData()

    return o
end

function MeSystemClass:__tostring()
    return stringUtils.UFormat("[Me system %s]", self.name)
end

-- Overriding GetKeyDisplayString method
function MeSystemClass:GetKeyDisplayString()
    return self.uniqueKey
end

-- Overriding GetDisplayString method
function MeSystemClass:GetDisplayString()
    local displayString = string.format(self.uniqueKey)
    return displayString
end


function MeSystemClass:__index(key)
    if MeSystemClass[key] then
        return MeSystemClass[key]
    elseif PeripheralClass[key] then
        return PeripheralClass[key]
    elseif ObClass[key] then
        return ObClass[key]
    else
        return self.per[key]
    end
end

function MeSystemClass:getItemList()
    local items = self.per.listItems()
    return items
end

local function getNamesFromList(_list)
    local itemNames = {}

    for key, item in pairs(_list) do
        table.insert(itemNames, item["name"])
    end

    return itemNames

end

function MeSystemClass:getItemNames()
    local items = self:getItemList()

    return getNamesFromList(items)
end


function MeSystemClass:getCraftableItems()
    return self.per.listCraftableItems()
end

function MeSystemClass:getCraftableItemNames()
    local items = self:getCraftableItems()
    return getNamesFromList(items)
end

function MeSystemClass:exportItem(itemName, count, containerName)


    local containerNameToUse = containerName
    if not containerNameToUse then
        containerNameToUse = peripheralWrapper:new(perTypes.barrel).name
    end
    local countToUse = count
    if not countToUse then
        countToUse = 1
    end
    local exportTable = {name = itemName, count = countToUse}

    return self.per.exportItemToPeripheral(exportTable, containerNameToUse)
end

function MeSystemClass:getFreeCpu()
    local cpus = self.per.getCraftingCPUs()
    for key, cpu in pairs(cpus) do
       if not cpu.isBusy then
            cpu.name = key
            return cpu
       end
    end
end

function MeSystemClass:getAllFreeCpus()
    local cpus = self.per.getCraftingCPUs()
    local freeCpus = {}
    for key, cpu in pairs(cpus) do
        if not cpu.isBusy then
            cpu.name = key
            table.insert(freeCpus, cpu)
        end
     end
    return freeCpus
end

function MeSystemClass:isItemBeingCrafted(itemName)
    local itemTable = {name = itemName}
    return self.per.isItemCrafting(itemTable)
end


function MeSystemClass:craftItem(itemName, count)
    local countToUse = count or 1
    local itemTable = {name = itemName, count = countToUse}
    return self.per.craftItem(itemTable)
end

function MeSystemClass:updateData()
    self.availableItemStorage = self.per.getAvailableItemStorage()
    self.usedItemStorage = self.per.getUsedItemStorage()
    self.totalItemStorage = self.per.getTotalItemStorage()
    self.cells = self.per.listCells()
    self.craftingCpus = self.per.getCraftingCPUs()
    self.energyStorage = self.per.getEnergyStorage()
    self.maxEnergyStorage = self.per.getMaxEnergyStorage()
    self.energyUsage = self.per.getEnergyUsage()
end

function MeSystemClass:getUsedPercentage()
    return math.floor((self.usedItemStorage / self.totalItemStorage)*100)
end

function MeSystemClass:getFreePercentage()
    return 100 - self:getUsedPercentage()
end

function MeSystemClass:getEnergyPercentage()
    return math.floor((self.energyStorage / self.maxEnergyStorage)*100)
end

function MeSystemClass:getNumberOfCraftingCells()
    return #self.cells
end



return MeSystemClass