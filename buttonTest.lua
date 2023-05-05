
local ButtonClass = require("GUI.buttonClass")
local ToggleableButtonClass = require("GUI.toggleableButtonClass")
local PageClass = require("GUI.pageClass")
local TableClass = require("GUI.tableClass")
local MonUtils = require("UTIL.monUtils")
local MeUtils = require("UTIL.meUtils")
local logger = require("UTIL.logger")
local PageStackClass = require("GUI.pageStackClass")

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
    else
        return "{...}"
    end
end)

local pageStack1, internalTable = TableClass.createTableStack(monitor, 5, 5, 40, 30, MeUtils.getItemList(), "Item List", displayTableFunction)
internalTable:setTableValueDisplayed(

)
table.insert(buttonList, pageStack1)

local pageStack2 = TableClass.createTableStack(monitor, 46, 5 , 40, 30, MeUtils.getCraftableItemNames(), "Craftable Item Names")

table.insert(buttonList, pageStack2)





page:addButtons(buttonList)
page:draw()

--pageStack:draw()


while isRunning do
---@diagnostic disable-next-line: undefined-field

    page:handleEvent(os.pullEvent())
    
end

