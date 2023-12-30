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

-- Setup Monitor
---@type Monitor
local monitor = peripheral.find("monitor")
MonUtils.resetMonitor(monitor)

local monitorX, monitorY = monitor.getSize()

-- Initialize logger for debug
logger.init(term.current(), "RPH.log", true,logger.LOGGING_LEVEL.WARNING, logger.OUTPUT.FILE)
logger.log("Started RPH", logger.LOGGING_LEVEL.ALWAYS)

-- Create document, allows to retrieve data.
local document = DocumentClass:new()
document:startEdition()
-- Setup exit program button
local isRunning = true
local function endProgram()
    isRunning = false
end

local pageStack = PageStackClass:new(monitor, document)
pageStack:setSize(monitorX - 2,monitorY - 2)
pageStack:setPosition(2,2)
local mainMenuPage = MainMenuPageClass:new(monitor, pageStack, document)
pageStack:pushPage(mainMenuPage)
pageStack:setOnFirstPageClosed(endProgram)
pageStack:getExitButton():applyDocumentStyle()

local rootPage = PageClass:new(monitor, 1, 1, document)
rootPage:setBackColor(document.style.backgroundColor)
rootPage:addElement(pageStack)

local shouldStopGuiLoop =
    function()
        return not isRunning
    end
local guiHandler = GuiHandlerClass:new(rootPage, shouldStopGuiLoop, document)
document:registerEverythingAsDirty()
document:endEdition()
guiHandler:loop()


