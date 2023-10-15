
-- Import required modules
local ButtonClass = require("GUI.buttonClass")
local PageClass = require("GUI.pageClass")
local MonUtils = require("UTIL.monUtils")
local logger = require("UTIL.logger")
local peripheralProxyClass = require("UTIL.peripheralProxy")
local ChestWrapper = require("UTIL.chestWrapper")
local GuiHandlerClass = require("GUI.guiHandlerClass")
local MainMenuPageClass = require("COLONYGUI.mainMenuPageClass")
local PageStackClass     = require("GUI.pageStackClass")
local ColonyDocumentClass= require("COLONYGUI.colonyDocumentClass")

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

-- Create document, allows to retrieve data.
local document = ColonyDocumentClass:new()

-- Setup exit program button
local isRunning = true
local function endProgram()
    isRunning = false
end
local exitButton = ButtonClass:new(monitorX, monitorY, "X")
exitButton:setOnElementTouched(endProgram)
exitButton:changeStyle(nil, ELEMENT_BACK_COLOR)
exitButton:setMargin(0)


-- Setup proxy to mineColonies
local colonyPeripheral = peripheralProxyClass:new(CHANNEL, "colonyIntegrator","right")

local pageStack = PageStackClass:new(monitor)
pageStack:setSize(monitorX - 2,monitorY - 2)
pageStack:setPosition(2,2)
local mainMenuPage = MainMenuPageClass:new(monitor, pageStack, colonyPeripheral, document)
pageStack:pushPage(mainMenuPage)
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


