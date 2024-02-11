-- add absolute paths to package to allow programs to use libraries from anywhere!
package.path = package.path .. ";/?;/?.lua"
-- Import required modules
local RphDocumentClass = require "RPH.MODEL.RphDocumentClass"
local MessagesPageClass = require "RPH.GUI.MessagesPageClass"
local PageClass = require("GUI.PageClass")
local MonUtils = require("UTIL.monUtils")
local logger = require("UTIL.logger")
local GuiHandlerClass = require("GUI.GuiHandlerClass")
local PageStackClass     = require("GUI.PageStackClass")
local PerformanceMonitorClass = require("PERFMON.PerformanceMonitor")
-- Initialize logger for debug
logger.init(term.current(), "RPH.log", true,logger.LOGGING_LEVEL.WARNING, logger.OUTPUT.FILE)
logger.log("Started RPH", logger.LOGGING_LEVEL.ALWAYS)


local PerfMonitor = PerformanceMonitorClass.createInstance("./output/perf_report_rph.log", "RPH", false)
PerfMonitor:startSection("Initialisation")

-- Setup Monitor
---@type Monitor
local monitor = peripheral.find("monitor")
MonUtils.resetMonitor(monitor)

local monitorX, monitorY = monitor.getSize()


-- Create document, allows to retrieve data.
local document = RphDocumentClass:new()
document:startEdition()
-- Setup exit program button
local isRunning = true
local function endProgram()
    isRunning = false
end

-- Open the rednet modem
rednet.open("left")

local pageStack = PageStackClass:new(document)
pageStack:setSize(monitorX - 2,monitorY - 2)
pageStack:setPosition(2,2)
local messagePageClass = MessagesPageClass:new(pageStack, document)
pageStack:pushPage(messagePageClass)
pageStack:setOnFirstPageClosed(endProgram)
pageStack:getExitButton():applyDocumentStyle()

local rootPage = PageClass:new( 1, 1, document)
rootPage:setBackColor(document.style.backgroundColor)
rootPage:addElement(pageStack)

local shouldStopGuiLoop =
    function()
        return not isRunning
    end
local guiHandler = GuiHandlerClass:new(rootPage, shouldStopGuiLoop, document)
document:registerEverythingAsDirty()
document:endEdition()
PerfMonitor:endSection("Initialisation")
guiHandler:loop()
PerfMonitor:endMonitoring()


