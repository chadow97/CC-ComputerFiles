-- add absolute paths to package to allow programs to use libraries from anywhere!
package.path = package.path .. ";/?;/?.lua"

local ButtonClass = require("GUI.ButtonClass")
local PageClass = require("GUI.PageClass")
local TableClass = require("GUI.TableClass")
local MonUtils = require("UTIL.monUtils")
local MeUtils = require("UTIL.meUtils")
local logger = require("UTIL.logger")
local PageStackClass = require("GUI.PageStackClass")
local LogClass = require("GUI.LogClass")
local DocumentClass = require("MODEL.DocumentClass")


---@type Monitor
local monitor = peripheral.find("monitor")
MonUtils.resetMonitor(monitor)

local terminal = term.current()
logger.init(terminal, "buttonTest", true)


local isRunning = true

local buttonList = {}

local function endProgram()
    isRunning = false
end


local monX, monY =monitor.getSize()

local document = DocumentClass:new()
local page = PageClass:new(monitor, nil, nil, document)
local ExitButton = ButtonClass:new(monX - 1, monY -1, "X", document)
ExitButton:setOnElementTouched(endProgram)
table.insert(buttonList, ExitButton)

local log = LogClass:new(10,10, nil, document)
log:setUpperCornerPos(19,40)
log:forceWidthSize(20)
log:forceHeightSize(5)

table.insert(buttonList, log)

page:addElements(buttonList)
page:draw()

for i = 1, 10 do
    log:addLine("nooooo" .. i)
    page:draw()
    sleep(1)
end

--pageStack:draw()


while isRunning do
---@diagnostic disable-next-line: undefined-field

    page:handleEvent(os.pullEvent())
    
end

