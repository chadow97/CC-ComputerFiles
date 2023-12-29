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
local monitor = peripheral.find("monitor")
MonUtils.resetMonitor(monitor)
---@diagnostic disable-next-line: undefined-field
local monitorX, monitorY = monitor.getSize()

-- Initialize logger for debug
logger.init(term.current(), "ColonyGUI.log", true)

-- Create document, allows to retrieve data.
local document = ColonyDocumentClass:new()
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
rootPage:setBackColor(document.style.tertiary)
rootPage:addElement(pageStack)

local shouldStopGuiLoop =
    function()
        return not isRunning
    end
local guiHandler = GuiHandlerClass:new(rootPage, shouldStopGuiLoop, document)
document:registerEverythingAsDirty()
document:endEdition()
guiHandler:loop()


