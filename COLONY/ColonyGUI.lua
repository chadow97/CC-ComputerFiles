-- add absolute paths to package to allow programs to use libraries from anywhere!
package.path = package.path .. ";/?;/?.lua"


local logger = require("UTIL.logger")
-- Initialize logger for debug, doing so before other modules so logging works as initialized!
logger.init(term.current(), "ColonyGUI.log", true,logger.LOGGING_LEVEL.WARNING, logger.OUTPUT.FILE)


local file =  fs.open("OUTPUT/yoyo", "a")
file.write("whyyyyy")
logger.log("Started colony program", logger.LOGGING_LEVEL.ALWAYS)
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
if (monitor == nil ) then
    print("No monitor to display!!")
    logger.log("No monitor to use!",logger.LOGGING_LEVEL.ERROR)
    return
end
MonUtils.resetMonitor(monitor)
---@diagnostic disable-next-line: undefined-field
local monitorX, monitorY = monitor.getSize()


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


