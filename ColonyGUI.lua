
-- Import required modules
local ButtonClass = require("GUI.buttonClass")
local ToggleableButtonClass = require("GUI.toggleableButtonClass")
local PageClass = require("GUI.pageClass")
local TableClass = require("GUI.tableClass")
local ObTableClass = require("GUI.obTableClass")
local MonUtils = require("UTIL.monUtils")
local MeUtils = require("UTIL.meUtils")
local logger = require("UTIL.logger")
local colIntUtil = require("UTIL.colonyIntegratorPerUtils")
local peripheralProxyClass = require("UTIL.peripheralProxy")
local ChestWrapper = require("UTIL.chestWrapper")
local GuiHandlerClass = require("GUI.guiHandlerClass")
local logClass = require("GUI.logClass")
local workOrderFetcherClass = require("MODEL.workOrderFetcherClass")
local ressourceFetcherClass = require("MODEL.ressourceFetcherClass")

-- Define constants
local BACKGROUND_COLOR = colors.yellow
local ELEMENT_BACK_COLOR = colors.red
local INNER_ELEMENT_BACK_COLOR = colors.yellow
local TEXT_COLOR = colors.lime

local REFRESH_DELAY = 100
local CHANNEL = 1
local LOG_HEIGHT = 10

local RESSOURCE_STATUS_LIST = {
    all_in_external_inv = {action ="Nothing to do.", color=colors.green, id =1},
    all_in_me_or_ex = {action = "Press to send to external inv.", color= colors.yellow, id = 2},
    no_missing = {action = "Nothing to do.", color = colors.green, id = 3},
    missing_not_craftable = {action = "Cannot be crafted!", color = colors.red, id = 4},
    craftable = {action = "Press to craft!", color=colors.orange, id = 5}
    }

--functions
local function getWorkOrders(colonyPeripheral)
    local status, workOrders = pcall(colIntUtil.getWorkOrders, colonyPeripheral)
    if not status then
        logger.log(workOrders)
        logger.log(debug.traceback())
        workOrders = {}
    end
    return workOrders
end

local function getMeItems()
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

local function getDataForRessource(ressourceDataFromColony, ressourceDataFromMeSystem, externalInventoryAmount)

        -- get default ME system value if none were passed
        local localRessourceDataFromMeSystem = ressourceDataFromMeSystem
        if not localRessourceDataFromMeSystem then
            localRessourceDataFromMeSystem = {amount = 0, isCraftable = false}
        end

        -- make sure we have atleast 0 in external inventory
        if not externalInventoryAmount then
            externalInventoryAmount = 0
        end

        -- calculate information about ressource
        local missing = ressourceDataFromColony.needed - ressourceDataFromColony.available - ressourceDataFromColony.delivering
        local missingWithExternalInv = missing - externalInventoryAmount
        local missingWithExternalInvAndMe = missingWithExternalInv - localRessourceDataFromMeSystem.amount

        local stats = {
            missing = missing, 
            me = localRessourceDataFromMeSystem.amount,
            extInv = externalInventoryAmount ,
            missingWithExternalInv = missingWithExternalInv,
            missingWithExternalInvAndMe = missingWithExternalInv,
            statusID = nil
        }

        if missing <= 0 then
            stats.statusID = "no_missing"
        elseif missingWithExternalInv <= 0 then
            stats.statusID = "all_in_external_inv"
        elseif missingWithExternalInvAndMe <= 0 then
            stats.statusID = "all_in_me_or_ex"
        elseif localRessourceDataFromMeSystem.isCraftable then
            stats.statusID = "craftable"
        else
            stats.statusID = "missing_not_craftable"
        end
        return stats

end

-- Setup Monitor
local monitor = peripheral.find("monitor")
MonUtils.resetMonitor(monitor)
local monitorX, monitorY = monitor.getSize()

-- Initialize logger for debug
logger.init(term.current(), "ColonyGUI", true)

-- Table to hold all buttons of the root page
local RootPageButtonList = {}

-- Setup exit program button
local isRunning = true
local function endProgram()
    isRunning = false
end
local ExitButton = ButtonClass:new(monitorX, monitorY, "X")
ExitButton:setFunction(endProgram)
ExitButton:changeStyle(nil, ELEMENT_BACK_COLOR)
ExitButton:setMargin(0)
table.insert(RootPageButtonList, ExitButton)

-- Setup proxy to mineColonies
local colonyPeripheral = peripheralProxyClass:new(CHANNEL, "colonyIntegrator" )

local externalChest = ChestWrapper:new()

-- Get CurrentWorkOrders
local workOrders = getWorkOrders(colonyPeripheral)


-- Create table to show in tablePage for workOrders
local workOrderTableToShow = {}
for workOrderKey, value in pairs(workOrders) do
    local valueToShow = "Pending work order " .. value.id .. ". \nBuilding " .. value.buildingName
    workOrderTableToShow[workOrderKey] = valueToShow
end

local workOrderFetcher = workOrderFetcherClass:new(colonyPeripheral)
local mainStackPage, mainStackTable = ObTableClass.createTableStack(monitor, 2, 2, monitorX - 2, monitorY - 2, "Item List", workOrderFetcher)


mainStackTable:setDisplayKey(false)
mainStackTable.title = nil
mainStackTable:setRowHeight(4)
mainStackTable:changeStyle(ELEMENT_BACK_COLOR, INNER_ELEMENT_BACK_COLOR, TEXT_COLOR)
mainStackPage:changeStyle(nil, ELEMENT_BACK_COLOR)

local mainStackPageSizeX, mainStackPageSizeY = mainStackPage:getSize()
local mainStackPageX, mainStackPageY = mainStackPage:getPosition()




--[[
local currentRessources = nil
local itemsMap = nil
local extChestItemMap = nil

local ExternalChest = ChestWrapper:new()
local getRessourcesAndRessourcesToShow = function (workOrderKey, workOrders)
    local workOrder = workOrders[workOrderKey]
    local ressources = colonyPeripheral:getWorkOrderResources(workOrder.id)[1]
    itemsMap = getMeItems()
    if not ExternalChest then
        extChestItemMap = {}
    else
        extChestItemMap = ExternalChest:getAllItems()
    end

    if not ressources then
        ressources = {}
        logger.log("Colony Peripheral did not answer!")
    end

    local ressourceTableToShow = {}

    for ressourceKey, ressource in pairs(ressources) do
        local itemMeData = itemsMap[ressource.item]
        local extItemData = extChestItemMap[ressource.item]
        local ressourceStats = getDataForRessource(ressource, itemMeData, extItemData)
        -- stat is (missing, me, extInv)


        local valueToShow = ressource.item .. "\nNeeded for colony: " .. ressourceStats.missing .. "\n"

        valueToShow  = valueToShow .. "Amount in me system: " .. ressourceStats.me .. "\n"
        valueToShow  = valueToShow .. "Amount in external storage: " .. ressourceStats.extInv .. "\n"
        valueToShow  = valueToShow .. "Amount missing in colony/ext: " .. ressourceStats.missingWithExternalInvAndMe .. "\n"
        valueToShow  = valueToShow .. RESSOURCE_STATUS_LIST[ressourceStats.statusID].action

        ressourceTableToShow[ressourceKey] = valueToShow

    end

    return ressources, ressourceTableToShow
end


local ProcessAll = 
    function (ressourcesToProcess, meItemsMapToProcess, extChestItemMapToProcess)
        -- 1. handle ressourceToSend and collect ressourcesToCraft!
        local mapToCraft = {}
        local mapToSendToExtFromMe = {}

        

        for key, ressource in pairs(ressourcesToProcess) do
            
            local itemMeData = meItemsMapToProcess[ressource.item]
            local extItemData = extChestItemMapToProcess[ressource.item]

            local stats = getDataForRessource(ressource, itemMeData, extItemData)
            local ressourceStatusId = RESSOURCE_STATUS_LIST[stats.statusID].id

            if ressourceStatusId == RESSOURCE_STATUS_LIST.all_in_me_or_ex.id then
                MeUtils.exportItem(ressource.item, stats.missingWithExternalInv)
            elseif ressourceStatusId == RESSOURCE_STATUS_LIST.craftable.id then
                table.insert(mapToCraft, key)
            end           
        end

        
        while #mapToCraft > 0 do
            -- find crafting cpu
            local cpu = MeUtils.getFreeCpu()
            if not cpu then
                break
            end
           local keyOfItemToCraft = table.remove(mapToCraft)
           local ressource = currentRessources[keyOfItemToCraft]
           local itemMeData = itemsMap[ressource.item]
           local extItemData = extChestItemMap[ressource.item]
           local stats = getDataForRessource(ressource, itemMeData, extItemData)
           logger.log(MeUtils.craftItem(ressource.item, stats.missingWithExternalInvAndMe, cpu))
        end

        -- 2 .repeat as long as there is free crafting unit and things to craft
        -- 2.1. find a crafting unit
        -- 2.2. try to craft ressource, if fail, add to blacklisted ressources



    end
--]]
local rootPage = PageClass.new(monitor)
rootPage:setBackColor(BACKGROUND_COLOR)

local shouldStopGuiLoop =
    function()
        return not isRunning
    end
local guiHandler = GuiHandlerClass:new(REFRESH_DELAY, rootPage, shouldStopGuiLoop)

local function OnWorkOrderPressed(positionInTable, isKey, workOrder)
    -- do nothing if key, it shouldnt be displayed
    if (isKey) then
        return
    end
    local ressourceFetcher = ressourceFetcherClass:new(colonyPeripheral, workOrder.id, externalChest)

    local ressourceTable = ObTableClass:new(monitor, 1,1, "ressource")
    ressourceTable:setBlockDraw(true)
    ressourceTable:setDataFetcher(ressourceFetcher)
    ressourceTable:setDisplayKey(false)
    ressourceTable:setRowHeight(8)
    ressourceTable:changeStyle(ELEMENT_BACK_COLOR, INNER_ELEMENT_BACK_COLOR, TEXT_COLOR)
    ressourceTable:setColumnCount(3)
    ressourceTable:setHasManualRefresh(true)
    ressourceTable:setSize(mainStackPageSizeX, mainStackPageSizeY - 4 - LOG_HEIGHT)
    ressourceTable:setPosition(mainStackPageX,mainStackPageY)
    local _,_,_, ressourceTableEndY = ressourceTable:getArea()
    
    local log = logClass:new(1,1,"")
    log:setUpperCornerPos(mainStackPageY + 1, ressourceTableEndY + 1)
    log:forceWidthSize(mainStackPageSizeX - 2)
    log:forceHeightSize(LOG_HEIGHT)
    log:changeStyle(nil, TEXT_COLOR)
    
    local SendAllButton = ToggleableButtonClass:new(1, 1, "Send/Craft ALL!")
    SendAllButton:forceWidthSize(mainStackPageSizeX - 2)
    SendAllButton:setUpperCornerPos(mainStackPageX + 1, ressourceTableEndY + 1 + LOG_HEIGHT)
    SendAllButton:changeStyle(nil, TEXT_COLOR)


    local ressourcePage = PageClass.new(monitor)
    ressourcePage:setBlockDraw(true)
    ressourcePage:setBackColor(ELEMENT_BACK_COLOR)

    ressourcePage:add(ressourceTable)
    ressourcePage:add(SendAllButton)
    ressourcePage:add(log)
    ressourcePage:setBlockDraw(false)
    ressourceTable:setBlockDraw(false)
    
    mainStackPage:pushPage(ressourcePage)

end
--[[
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
                local ressourceStatus, stats = getDataForRessource(ressource, itemMeData, extItemData)
                if ressourceStatus.id == RESSOURCE_STATUS_LIST.all_in_me_or_ex.id then
                    MeUtils.exportItem(ressource.item, stats.missingWithExternalInv)
                end
                if ressourceStatus.id == RESSOURCE_STATUS_LIST.craftable.id then
                    MeUtils.craftItem(ressource.item, stats.missingWithExternalInvAndMe)
                end


            end

        local ressourceTable = TableClass:new(monitor, 5, 5, "ressources")
        local ressourcePage = PageClass.new(monitor)



        ressourceTable:setDisplayKey(false)
        ressourceTable:setInternalTable(ressourceTableToShow)
        ressourceTable:setRowHeight(8)
        ressourceTable:changeStyle(ELEMENT_BACK_COLOR, INNER_ELEMENT_BACK_COLOR, TEXT_COLOR)
        ressourceTable:setOnPressFunc(onPressRessourceFunc)



        local onDrawFunc =
            function (_, isKey, key, _, button)
                if isKey then
                    return
                end
                local ressource = currentRessources[key]
                local itemMeData = itemsMap[ressource.item]
                local extItemData = extChestItemMap[ressource.item]
                local ressourceStats = getDataForRessource(ressource, itemMeData, extItemData)
                local color = RESSOURCE_STATUS_LIST[ressourceStats.statusID].color

                button:setTextColor(color)
            end

        local onAskForNewData =
            function ()
                local newTableToShow
                currentRessources, newTableToShow = getRessourcesAndRessourcesToShow(workOrderKey, workOrders)
                return newTableToShow
            end


        local logHeight = 10
        ressourceTable:setOnDrawButton(onDrawFunc)
        ressourceTable:setColumnCount(3)
        ressourceTable:setOnAskForNewData(onAskForNewData)
        ressourceTable:setHasManualRefresh(true)
        local pageSizeX, pageSizeY = mainStackPage:getSize()
        local pageX, pageY = mainStackPage:getPosition()
        ressourceTable:setSize(pageSizeX, pageSizeY - 4 - logHeight)
        ressourceTable:setPosition(pageX,pageY)
        ressourcePage:add(ressourceTable)
        ressourcePage:setBackColor(ELEMENT_BACK_COLOR)
        mainStackPage:pushPage(ressourcePage)
        local _,_,_, endY = ressourceTable:getArea()

        local log = logClass:new(1,1,"")
        log:setUpperCornerPos(pageX + 1, endY + 1)
        log:forceWidthSize(pageSizeX - 2)
        log:forceHeightSize(logHeight)
        log:changeStyle(nil, TEXT_COLOR)

        ressourcePage:add(log)
      
        local SendAllButton = ToggleableButtonClass:new(pageX, pageY, "Send/Craft ALL!")
        SendAllButton:forceWidthSize(pageSizeX - 2)
        SendAllButton:setUpperCornerPos(pageX + 1, endY + 1 + logHeight)
        SendAllButton:changeStyle(nil, TEXT_COLOR)
        local IsSendingAll = false


        local OnSendAll = 
            function ()
                IsSendingAll = not IsSendingAll
                log:addLine("Pressed!")
                
            end

        local OnRefresh = function ()
            if IsSendingAll then
                ProcessAll(currentRessources, itemsMap, extChestItemMap)
            end
        end

        guiHandler:addOnRefreshCallback(OnRefresh)

        SendAllButton:setOnManualToggle(OnSendAll)
        ressourcePage:add(SendAllButton)
        
        rootPage:draw()

        
        


    end
    --]]

mainStackTable:setOnPressFunc(OnWorkOrderPressed)
    

table.insert(RootPageButtonList, mainStackPage)

rootPage:addButtons(RootPageButtonList)


guiHandler:loop()


