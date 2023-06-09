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
        containerNameToUse = peripheralWrapper:new(perTypes.chest).name
    end
    local countToUse = count
    if not countToUse then
        countToUse = 1
    end
    local exportTable = {name = itemName, count = countToUse}
    logger.log(exportTable)
    logger.log(containerNameToUse)
    return MePeripheral.exportItemToPeripheral(exportTable, containerNameToUse)
end


function MeUtils.craftItem(itemName, count)
    if not MePeripheral then
        return
    end
    local countToUse = count or 1
    local itemTable = {name = itemName, count = countToUse}
    return MePeripheral.craftItem(itemTable)
end



return MeUtils
