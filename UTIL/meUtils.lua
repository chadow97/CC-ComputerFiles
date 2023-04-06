local MeUtils = {}

local perUtils = require("perUtils")

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


return MeUtils
