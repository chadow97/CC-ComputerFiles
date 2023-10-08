
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
local RessourceClass = require("MODEL.ressourceClass")

-- Define constants
local BACKGROUND_COLOR = colors.yellow
local ELEMENT_BACK_COLOR = colors.red
local INNER_ELEMENT_BACK_COLOR = colors.lime
local TEXT_COLOR = colors.yellow

local REFRESH_DELAY = 100
local CHANNEL = 1
local LOG_HEIGHT = 10


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

local workOrderFetcher = workOrderFetcherClass:new(colonyPeripheral)
local mainStackPage, mainStackTable = ObTableClass.createTableStack(monitor, 2, 2, monitorX - 2, monitorY - 2, "Item List", workOrderFetcher)


mainStackTable:setDisplayKey(false)
mainStackTable.title = nil
mainStackTable:setRowHeight(4)
mainStackTable:changeStyle(ELEMENT_BACK_COLOR, INNER_ELEMENT_BACK_COLOR, TEXT_COLOR)
mainStackPage:changeStyle(nil, ELEMENT_BACK_COLOR)

local mainStackPageSizeX, mainStackPageSizeY = mainStackPage:getSize()
local mainStackPageX, mainStackPageY = mainStackPage:getPosition()

local IsSendingAll = false;

local function ProcessAll() 
    
end

local function OnRefresh()
        if IsSendingAll then
            -- ProcessAll(currentRessources, itemsMap, extChestItemMap)
        end
end
local function OnSendAllPressed()
        IsSendingAll = not IsSendingAll
end

local function OnRessourcePressed(positionInTable, isKey, ressource)
    -- do nothing if key, it shouldnt be displayed
    if  isKey then
        return
    end
    local actionToDo = ressource:getActionToDo()
    logger.log(actionToDo)
    if actionToDo == RessourceClass.ACTIONS.SENDTOEXTERNAL then
        MeUtils.exportItem(ressource.item, ressource.missingWithExternalInventory)
    elseif actionToDo == RessourceClass.ACTIONS.CRAFT then
        MeUtils.craftItem(ressource.itemId, ressource.missingWithExternalInventoryAndMe)
    end

end

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
    ressourceTable:setOnPressFunc(OnRessourcePressed)
    local _,_,_, ressourceTableEndY = ressourceTable:getArea()
    
    local logElement = logClass:new(1,1,"")
    logElement:setUpperCornerPos(mainStackPageY + 1, ressourceTableEndY + 1)
    logElement:forceWidthSize(mainStackPageSizeX - 2)
    logElement:forceHeightSize(LOG_HEIGHT)
    logElement:changeStyle(nil, INNER_ELEMENT_BACK_COLOR)
    
    local SendAllButton = ToggleableButtonClass:new(1, 1, "Send/Craft ALL!")
    SendAllButton:forceWidthSize(mainStackPageSizeX - 2)
    SendAllButton:setUpperCornerPos(mainStackPageX + 1, ressourceTableEndY + 1 + LOG_HEIGHT)
    SendAllButton:changeStyle(nil, INNER_ELEMENT_BACK_COLOR)
    SendAllButton:setOnManualToggle(OnSendAllPressed)


    local ressourcePage = PageClass.new(monitor)
    ressourcePage:setBlockDraw(true)
    ressourcePage:setBackColor(ELEMENT_BACK_COLOR)

    ressourcePage:add(ressourceTable)
    ressourcePage:add(SendAllButton)
    ressourcePage:add(logElement)
    ressourcePage:setBlockDraw(false)
    ressourceTable:setBlockDraw(false)
    
    mainStackPage:pushPage(ressourcePage)

end

local rootPage = PageClass.new(monitor)
rootPage:setBackColor(BACKGROUND_COLOR)

mainStackTable:setOnPressFunc(OnWorkOrderPressed)
    

table.insert(RootPageButtonList, mainStackPage)

rootPage:addButtons(RootPageButtonList)

local shouldStopGuiLoop =
    function()
        return not isRunning
    end
local guiHandler = GuiHandlerClass:new(REFRESH_DELAY, rootPage, shouldStopGuiLoop)
guiHandler:loop()


