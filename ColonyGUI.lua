
local ButtonClass = require("GUI.buttonClass")
local ToggleableButtonClass = require("GUI.toggleableButtonClass")
local PageClass = require("GUI.pageClass")
local TableClass = require("GUI.tableClass")
local MonUtils = require("UTIL.monUtils")
local MeUtils = require("UTIL.meUtils")
local logger = require("UTIL.logger")
local PageStackClass = require("GUI.pageStackClass")
local colIntUtil = require("UTIL.colonyIntegratorPerUtils")
local peripheralProxyClass = require("UTIL.peripheralProxy")
local MeUtils = require("UTIL.meUtils")
local PerTypes = require("UTIL.perTypes")
local PerWrapper = require("UTIL.peripheralWrapper")

local monitor = peripheral.find("monitor")

local terminal = term.current()
logger.init(terminal, "buttonTest", true)

local refreshDelay = 5
-- define colors
local backgroundColor = colors.yellow
local elementBackColor = colors.red
local innerElementBackColor = colors.yellow
local textColor = colors.lime


local isRunning = true

local buttonList = {}

local function endProgram()
    isRunning = false
end

local page = PageClass.new(monitor)
page:setBackColor(backgroundColor)



local monX, monY =monitor.getSize()


local ExitButton = ButtonClass:new(monX - 1, monY -1, "X")
ExitButton:setFunction(endProgram)
ExitButton:changeStyle(nil, elementBackColor)
table.insert(buttonList, ExitButton)

local channel = 1

local colIntPer = peripheralProxyClass:new(channel, "colonyIntegrator" )

local status, workOrders = pcall(colIntUtil.getWorkOrders,colIntPer)
if not status then
    logger.log(workOrders)
    logger.log(debug.traceback())
    return
end

local tableToShow = {}

for workOrderKey, value in pairs(workOrders) do
    local valueToShow = "Pending work order " .. value.id .. ". \nBuilding " .. value.buildingName
    tableToShow[workOrderKey] = valueToShow

end
local pageStack1, internalTable = TableClass.createTableStack(monitor, 5, 5, 40, 30, tableToShow, "Item List")
internalTable:setDisplayKey(false)
internalTable.title = nil
internalTable:setRowHeight(4)
internalTable:changeStyle(elementBackColor, innerElementBackColor, textColor)
pageStack1:changeStyle(nil, elementBackColor)

local getMeItems = function ()
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





local currentRessources = nil
local itemsMap = nil

local getRessourcesAndRessourcesToShow = function (workOrderKey, workOrders)
    local workOrder = workOrders[workOrderKey]
    local ressources = colIntPer:getWorkOrderResources(workOrder.id)[1]
    itemsMap = getMeItems()

    local ressourceTableToShow = {}

    for ressourceKey, ressource in pairs(ressources) do
        local missing = ressource.needed - ressource.available - ressource.delivering
        local valueToShow = ressource.item .. "\nMissing:" .. missing .. "\n"
        local itemMeData = itemsMap[ressource.item]
        if missing > 0 and itemMeData then
            if itemMeData.amount >= missing then
                valueToShow = valueToShow .. "Me system has:" .. itemMeData.amount .. "\n(Press to send to colony)"
            elseif itemMeData.isCraftable then
                valueToShow = valueToShow .. "Me system has:" .. itemMeData.amount .. ",need " .. missing - itemMeData.amount .. " more.\n(Press to craft and send!)"
            else
                valueToShow = valueToShow .. "Me system has:" .. itemMeData.amount .. ",need " .. missing - itemMeData.amount .. " more.\n(Not craftable!!!)"
            end
        else    
            valueToShow = valueToShow .. "Me system has: 0, need " .. missing .." more.\n(Not craftable!!!)"
        end
        ressourceTableToShow[ressourceKey] = valueToShow

    end

    return ressources, ressourceTableToShow
end

local onPressFunc = 
    function (_, isWorkOrderKey, workOrderKey, _)
        if isWorkOrderKey then
            return
        end
        -- get workorder data represented by pressed button
        local ressourceTableToShow
        currentRessources, ressourceTableToShow = getRessourcesAndRessourcesToShow(workOrderKey, workOrders)

        local onPressRessourceFunc = 
            function (_, isKey, key, _)
                if isKey then
                    return
                end
                -- get ressource data.
                local ressource = currentRessources[key]
                local itemMeData = itemsMap[ressource.item]
                local missing = ressource.needed - ressource.available - ressource.delivering
                if missing < 0 or not itemMeData then
                    return
                end
                if itemMeData.amount >= missing then
                    MeUtils.exportItem(ressource.item, missing)
                    return
                end
                if itemMeData.isCraftable then
                    MeUtils.craftItem(ressource.item,  missing - itemMeData.amount)
                end


            end

        local ressourceTable = TableClass:new(monitor, 5, 5, "ressources")
        ressourceTable:setDisplayKey(false)
        ressourceTable:setInternalTable(ressourceTableToShow)
        ressourceTable:setRowHeight(6)
        ressourceTable:changeStyle(elementBackColor, innerElementBackColor, textColor)
        ressourceTable:setOnPressFunc(onPressRessourceFunc)


        local onDrawFunc =
            function (_, isKey, key, _, button)
                if isKey then
                    return
                end
                local ressource = currentRessources[key]
                local missing = ressource.needed - ressource.available - ressource.delivering
                local color =colors.green
                if missing > 0 then
                    -- missing some item, look in me system!
                    local itemMeData = itemsMap[ressource.item]
                    if  itemMeData then
                        if itemMeData.amount >= missing then
                            color = colors.yellow
                        elseif itemMeData.isCraftable then
                            color = colors.orange
                        else
                            color = colors.red
                        end
                    else
                        -- items     
                        color = colors.red
                    end
                end

                button:setTextColor(color)
            end

        local onAskForNewData =
            function ()
                local newTableToShow
                currentRessources, newTableToShow = getRessourcesAndRessourcesToShow(workOrderKey, workOrders)
                return newTableToShow
            end



        ressourceTable:setOnDrawButton(onDrawFunc)
        ressourceTable:setOnAskForNewData(onAskForNewData)
        pageStack1:pushPage(ressourceTable)


        


    end

internalTable:setOnPressFunc(onPressFunc)
table.insert(buttonList, pageStack1)

page:addButtons(buttonList)

page:draw()


local refreshTimerID = nil
while isRunning do
    if not refreshTimerID then
        ---@diagnostic disable-next-line: undefined-field
        refreshTimerID = os.startTimer(refreshDelay)
    end
    ---@diagnostic disable-next-line: undefined-field
    local eventData = {os.pullEvent()}
    local eventName = eventData[1]
    if eventName == "timer" and eventData[2] == refreshTimerID then
        logger.log("asking to refresh data!")
        eventData = {"refresh_data"}
       refreshTimerID = nil
    end
    page:handleEvent(unpack(eventData))
end

