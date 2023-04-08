
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

--table.insert(buttonList, ButtonClass:new(10, 5, "hey"))

local monX, monY =monitor.getSize()

--[[
table.insert(buttonList, ButtonClass:new(15, 10, "how"))
table.insert(buttonList, ButtonClass:new(20, 12, "are"))
table.insert(buttonList, ButtonClass:new(23, 15, "you?"))
table.insert(buttonList, ButtonClass:new(30, 30, "Im a weirdo!!!"))
]]--

local ExitButton = ButtonClass:new(monX - 1, monY -1, "X")
ExitButton:setFunction(endProgram)
table.insert(buttonList, ExitButton)

--[[

local ToggleButton = ToggleableButtonClass:new(40, 32, "Toggle me!!!")
table.insert(buttonList, ToggleButton)

local ToggleButton2 = ToggleableButtonClass:new(60, 5, "HEAVEN")
ToggleButton2:disableAutomaticUntoggle()
ToggleButton2:changeStyle(colors.blue, colors.white, colors.red, colors.black)

ToggleButton2:setOnManualToggle(
    (function(button)


        button:setText(button:isPressed() and "HELL" or "HEAVEN")
 

    end))
table.insert(buttonList, ToggleButton2)
]]--


--[[
local ToggleButton3 = ToggleableButtonClass:new(70, 25, "Click me haha!")
ToggleButton3:setOnManualToggle(
    (function(button) 
        local maxX, maxY = page:getSize()

        local newXPos = math.random(maxX - 1) + 1
        local newYPos = math.random(maxY - 1) + 1

        button:setPos(newXPos,newYPos)
    
    
    end)
)
table.insert(buttonList, ToggleButton3)
]]--
----[[
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

