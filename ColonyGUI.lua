
local ButtonClass = require("GUI.buttonClass")
local ToggleableButtonClass = require("GUI.toggleableButtonClass")
local PageClass = require("GUI.pageClass")
local TableClass = require("GUI.tableClass")
local MonUtils = require("UTIL.monUtils")
local MeUtils = require("UTIL.meUtils")
local logger = require("UTIL.logger")
local PageStackClass = require("GUI.pageStackClass")
local colIntUtil = require("UTIL.colonyIntegratorPerUtils")
local peripheralProxyClass = require("UTIL.peripheralProxy")

local monitor = peripheral.find("monitor")
MonUtils.resetMonitor(monitor)

local terminal = term.current()
logger.init(terminal, "buttonTest", true)


local isRunning = true

local buttonList = {}

local function endProgram()
    isRunning = false
end

local page = PageClass.new(monitor)



local monX, monY =monitor.getSize()


local ExitButton = ButtonClass:new(monX - 1, monY -1, "X")
ExitButton:setFunction(endProgram)
table.insert(buttonList, ExitButton)

local  displayTableFunction =  (function(value)
    if value.name then
        return "{" ..value.name .. "}"
    elseif value.id then
        return "Work Order ID :" .. value.id
    else
        return "{...}"
    end
end)





local channel = 1

local colIntPer = peripheralProxyClass:new(channel, "colonyIntegrator" )

local status, workOrders = pcall(colIntUtil.getWorkOrders,colIntPer)
if not status then
    logger.log(workOrders)
    logger.log(debug.traceback())
    return
end

local tableToShow = {}
for _, value in pairs(workOrders) do
    table.insert(tableToShow, "Pending work order " .. value.id .. ". \nBuilding " .. value.buildingName)
end
local pageStack1, internalTable = TableClass.createTableStack(monitor, 5, 5, 40, 30, tableToShow, "Item List", displayTableFunction)
internalTable:setDisplayKey(false)
internalTable.title = nil
internalTable:setRowHeight(5)
table.insert(buttonList, pageStack1)

page:addButtons(buttonList)
page:draw()

--pageStack:draw()


while isRunning do
---@diagnostic disable-next-line: undefined-field
    page:handleEvent(os.pullEvent())
end

