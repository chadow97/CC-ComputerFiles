
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
local RessourcePageClass = require("COLONYGUI.ressourcePageClass")

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

local function OnWorkOrderPressed(positionInTable, isKey, workOrder)
    -- do nothing if key, it shouldnt be displayed
    if (isKey) then
        return
    end
    local ressourcePage = RessourcePageClass:new(monitor, mainStackPage, colonyPeripheral, workOrder.id, externalChest)
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


