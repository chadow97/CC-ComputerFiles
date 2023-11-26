-- add absolute paths to package to allow programs to use libraries from anywhere!
package.path = package.path .. ";/?;/?.lua"
-- Import required modules
local ButtonClass = require("GUI.ButtonClass")
local PageClass = require("GUI.PageClass")
local MonUtils = require("UTIL.monUtils")
local logger = require("UTIL.logger")
local peripheralProxyClass = require("UTIL.peripheralProxy")
local GuiHandlerClass = require("GUI.GuiHandlerClass")
local MainMenuPageClass = require("COLONY.GUI.MainMenuPageClass")
local PageStackClass     = require("GUI.PageStackClass")
local ColonyDocumentClass= require("COLONY.MODEL.ColonyDocumentClass")

-- Define constants
local BACKGROUND_COLOR = colors.yellow
local ELEMENT_BACK_COLOR = colors.red

local CHANNEL = 1

-- Setup Monitor
local monitor = peripheral.find("monitor")
MonUtils.resetMonitor(monitor)
local monitorX, monitorY = monitor.getSize()

-- Initialize logger for debug
logger.init(term.current(), "ColonyGUI.log", true)

-- Setup proxy to mineColonies
local colonyPeripheral = peripheralProxyClass:new(CHANNEL, "colonyIntegrator","right")

-- Create document, allows to retrieve data.
local document = ColonyDocumentClass:new(colonyPeripheral)
document:startEdition()
-- Setup exit program button
local isRunning = true
local function endProgram()
    isRunning = false
end
local exitButton = ButtonClass:new(monitorX, monitorY, "X", document)
exitButton:setOnElementTouched(endProgram)
exitButton:changeStyle(nil, ELEMENT_BACK_COLOR)
exitButton:setMargin(0)



local pageStack = PageStackClass:new(monitor, document)
pageStack:setSize(monitorX - 2,monitorY - 2)
pageStack:setPosition(2,2)
local mainMenuPage = MainMenuPageClass:new(monitor, pageStack, colonyPeripheral, document)
pageStack:pushPage(mainMenuPage)
pageStack:changeExitButtonStyle(nil, ELEMENT_BACK_COLOR)

local rootPage = PageClass:new(monitor, 1, 1, document)
rootPage:setBackColor(BACKGROUND_COLOR)
rootPage:addElement(pageStack)
rootPage:addElement(exitButton)

local shouldStopGuiLoop =
    function()
        return not isRunning
    end
local guiHandler = GuiHandlerClass:new(rootPage, shouldStopGuiLoop, document)
document:registerEverythingAsDirty()
document:endEdition()
guiHandler:loop()


