
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
local ChestWrapper = require("UTIL.chestWrapper")
local GuiHandlerClass = require("GUI.guiHandlerClass")


local monitor = peripheral.find("monitor")

local terminal = term.current()
logger.init(terminal, "buttonTest", true)

MonUtils.resetMonitor(monitor)

local refreshDelay = 1
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

local chest = ChestWrapper:new()

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
local pageStack1, internalTable = TableClass.createTableStack(monitor, 2, 2, 40, 50, tableToShow, "Item List")
--redu
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
local ressourceStatuses = {
                            all_in_external_inv = {action ="Nothing to do.", color=colors.green, id =1},
                            all_in_me_or_ex = {action = "Press to send to external inv.", color= colors.yellow, id = 2},
                            no_missing = {action = "Nothing to do.", color = colors.green, id = 3},
                            missing_not_craftable = {action = "Cannot be crafted!", color = colors.red, id = 4},
                            craftable = {action = "Press to craft!", color=colors.orange, id = 5}




                          }
local getRessourceStatus =
    function(colRessource, itemMeDataIn, externalInvAmountIn)

        local itemMeData = itemMeDataIn
        if not itemMeData then
            itemMeData = {amount = 0, isCraftable = false}
        end
        local externalInvData = externalInvAmountIn
        if not externalInvData then
            externalInvData = 0
        end
        local missing = colRessource.needed - colRessource.available - colRessource.delivering
        local missingWithExternalInv = missing - externalInvData
        local missingWithExternalInvAndMe = missingWithExternalInv - itemMeData.amount

        local stats = {missing = missing, me = itemMeData.amount, extInv = externalInvData , missingWithExternalInv = missingWithExternalInv, missingWithExternalInvAndMe = missingWithExternalInv}

        if missing <= 0 then
            return ressourceStatuses.no_missing, stats
        end
        
        if missingWithExternalInv <= 0 then
            return ressourceStatuses.all_in_external_inv, stats
        end
        
        if missingWithExternalInvAndMe <= 0 then
            return ressourceStatuses.all_in_me_or_ex, stats
        end
        if itemMeData.isCraftable then
            return ressourceStatuses.craftable, stats
        end
        return ressourceStatuses.missing_not_craftable, stats

    end



local currentRessources = nil
local itemsMap = nil
local extChestItemMap = nil

local getRessourcesAndRessourcesToShow = function (workOrderKey, workOrders)
    local workOrder = workOrders[workOrderKey]
    local ressources = colIntPer:getWorkOrderResources(workOrder.id)[1]
    itemsMap = getMeItems()
    if not chest then
        extChestItemMap = {}
    else
        extChestItemMap = chest:getAllItems()
    end

    local ressourceTableToShow = {}

    for ressourceKey, ressource in pairs(ressources) do
        local itemMeData = itemsMap[ressource.item]
        local extItemData = extChestItemMap[ressource.item]
        local ressourceStatus, stats = getRessourceStatus(ressource, itemMeData, extItemData)
        -- stat is (missing, me, extInv)


        local valueToShow = ressource.item .. "\nNeeded for colony: " .. stats.missing .. "\n"

        valueToShow  = valueToShow .. "Amount in me system: " .. stats.me .. "\n"
        valueToShow  = valueToShow .. "Amount in external storage: " .. stats.extInv .. "\n"
        valueToShow  = valueToShow .. "Amount missing in colony/ext: " .. stats.missingWithExternalInvAndMe .. "\n"
        valueToShow  = valueToShow .. ressourceStatus.action

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
                local extItemData = extChestItemMap[ressource.item]
                local ressourceStatus, stats = getRessourceStatus(ressource, itemMeData, extItemData)
                if ressourceStatus.id == ressourceStatuses.all_in_me_or_ex.id then
                    MeUtils.exportItem(ressource.item, stats.missingWithExternalInv)
                end
                if ressourceStatus.id == ressourceStatuses.craftable.id then
                    MeUtils.craftItem(ressource.item, stats.missingWithExternalInvAndMe)
                end


            end

        local ressourceTable = TableClass:new(monitor, 5, 5, "ressources")
        local ressourcePage = PageClass.new(monitor)



        ressourceTable:setDisplayKey(false)
        ressourceTable:setInternalTable(ressourceTableToShow)
        ressourceTable:setRowHeight(8)
        ressourceTable:changeStyle(elementBackColor, innerElementBackColor, textColor)
        ressourceTable:setOnPressFunc(onPressRessourceFunc)


        local onDrawFunc =
            function (_, isKey, key, _, button)
                if isKey then
                    return
                end
                local ressource = currentRessources[key]
                local itemMeData = itemsMap[ressource.item]
                local extItemData = extChestItemMap[ressource.item]
                local ressourceStatus = getRessourceStatus(ressource, itemMeData, extItemData)
                local color = ressourceStatus.color

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
        local pageSizeX, pageSizeY = pageStack1:getSize()
        local pageX, pageY = pageStack1:getPosition()
        ressourceTable:setSize(pageSizeX, pageSizeY - 4)
        
        logger.log(pageX .. "," .. pageY)
        ressourceTable:setPosition(pageX,pageY)

        ressourcePage:add(ressourceTable)
        ressourcePage:setBackColor(elementBackColor)
        pageStack1:pushPage(ressourcePage)
        local _,_,_, endY = ressourceTable:getArea()
        local SendAllButton = ToggleableButtonClass:new(pageX, pageY, "Send/Craft ALL!")
        SendAllButton:forceWidthSize(pageSizeX - 2)
        SendAllButton:setUpperCornerPos(pageX + 1, endY + 1)
        SendAllButton:changeStyle(nil, textColor)


        local OnSendAll = 
            function ()
                ressourceTable:pressAllButtons()
            end



        SendAllButton:setOnManualToggle(OnSendAll)
        ressourcePage:add(SendAllButton)
        
        page:draw()


        


    end

internalTable:setOnPressFunc(onPressFunc)
table.insert(buttonList, pageStack1)

page:addButtons(buttonList)

page:draw()

local shouldStopGuiLoop =
    function()
        return not isRunning
    end

local guiHandler = GuiHandlerClass:new(refreshDelay,page, shouldStopGuiLoop)


guiHandler:loop()


