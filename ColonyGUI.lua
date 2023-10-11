
-- Import required modules
local ButtonClass = require("GUI.buttonClass")
local PageClass = require("GUI.pageClass")
local MonUtils = require("UTIL.monUtils")
local logger = require("UTIL.logger")
local peripheralProxyClass = require("UTIL.peripheralProxy")
local ChestWrapper = require("UTIL.chestWrapper")
local GuiHandlerClass = require("GUI.guiHandlerClass")
local WorkOrderPageClass = require("COLONYGUI.workOrderPageClass")
local PageStackClass     = require("GUI.pageStackClass")

-- Define constants
local BACKGROUND_COLOR = colors.yellow
local ELEMENT_BACK_COLOR = colors.red

local REFRESH_DELAY = 100
local CHANNEL = 1

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
local exitButton = ButtonClass:new(monitorX, monitorY, "X")
exitButton:setOnElementTouched(endProgram)
exitButton:changeStyle(nil, ELEMENT_BACK_COLOR)
exitButton:setMargin(0)
table.insert(RootPageButtonList, exitButton)

-- Setup proxy to mineColonies
local colonyPeripheral = peripheralProxyClass:new(CHANNEL, "colonyIntegrator" )

local externalChest = ChestWrapper:new()

local pageStack = PageStackClass:new(monitor)
pageStack:setSize(monitorX - 2,monitorY - 2)
pageStack:setPosition(2,2)
local workOrderPage = WorkOrderPageClass:new(monitor, pageStack, colonyPeripheral, externalChest)
pageStack:pushPage(workOrderPage)
pageStack:changeExitButtonStyle(nil, ELEMENT_BACK_COLOR)

local rootPage = PageClass:new(monitor)
rootPage:setBackColor(BACKGROUND_COLOR)
rootPage:addElement(pageStack)
rootPage:addElement(exitButton)

local shouldStopGuiLoop =
    function()
        return not isRunning
    end
local guiHandler = GuiHandlerClass:new(REFRESH_DELAY, rootPage, shouldStopGuiLoop)
guiHandler:loop()


