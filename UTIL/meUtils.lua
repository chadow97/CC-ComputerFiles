local MeUtils = {}

local perUtils = require("UTIL.perUtils")
local peripheralWrapper = require("UTIL.peripheralWrapper")
local perTypes          = require("UTIL.perTypes")
local logger = require("UTIL.logger")

local MePeripheral = perUtils.getPerFromName("meBridge")

function MeUtils.getItemList()
    if not MePeripheral then
        return {}
    end
    local items = MePeripheral.listItems()
    return items
end

local function getNamesFromList(_list)
    local itemNames = {}

    for key, item in pairs(_list) do
        table.insert(itemNames, item["name"])
    end

    return itemNames

end

function MeUtils.getItemNames()
    local items = MeUtils.getItemList()

    return getNamesFromList(items)
end


function MeUtils.getCraftableItems()
    if not MePeripheral then
        return {}
    end
    return MePeripheral.listCraftableItems()
end

function MeUtils.getCraftableItemNames()
    local items = MeUtils.getCraftableItems()
    return getNamesFromList(items)
end

function MeUtils.exportItem(itemName, count, containerName)
    if  not MePeripheral then
        return 0
    end
    local containerNameToUse = containerName
    if not containerNameToUse then
        containerNameToUse = peripheralWrapper:new(perTypes.barrel).name
    end
    local countToUse = count
    if not countToUse then
        countToUse = 1
    end
    local exportTable = {name = itemName, count = countToUse}
    return MePeripheral.exportItemToPeripheral(exportTable, containerNameToUse)
end

function MeUtils.getFreeCpu()
    if not MePeripheral then
        return 
    end

    local cpus = MePeripheral.getCraftingCPUs()
    for key, cpu in pairs(cpus) do
       if not cpu.isBusy then
            cpu.name = key
            return cpu
       end
    end
end

function MeUtils.getAllFreeCpus()
    if not MePeripheral then
        logger.log("Missing Me Peripheral")
        return
    end
    local cpus = MePeripheral.getCraftingCPUs()
    local freeCpus = {}
    for key, cpu in pairs(cpus) do
        if not cpu.isBusy then
            cpu.name = key
            table.insert(freeCpus, cpu)
        end
     end
    return freeCpus
end

function MeUtils.isItemBeingCrafted(itemName)
    if not MePeripheral then
        logger.log("Missing Me Peripheral")
        return
    end
    local itemTable = {name = itemName}
    return MePeripheral.isItemCrafting(itemTable)
end


function MeUtils.craftItem(itemName, count)
    if not MePeripheral then
        logger.log("Missing Me Peripheral")
        return
    end
    local countToUse = count or 1
    local itemTable = {name = itemName, count = countToUse}
    return MePeripheral.craftItem(itemTable)
end





return MeUtils
