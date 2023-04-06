local ButtonClass = require("GUI.buttonClass")
local ToggleableButtonClass = require("GUI.toggleableButtonClass")
local PageClass = require("GUI.pageClass")
local MonUtils = require("UTIL.monUtils")
local logger = require("UTIL.logger")


logger.init(term.current())


local args = {...}

local programName = args[1]

if programName == nil then
    print("Syntax is: programTester programName arguments")
    return
end

local programArgs = args
-- remove program name

-- base monitor to log too.




local monitor = peripheral.find("monitor")
local keepTesting = true
local keepHolding = true

table.remove(programArgs, 1)

local page = PageClass.new(monitor)

monitorX, monitorY = monitor.getSize()


local buttonList = {}
local StopButton = ButtonClass:new( monitorX - 15, monitorY - 1, "Stop")
StopButton:changeStyle(colors.black, colors.red)
table.insert(buttonList, StopButton)

local RestartButton = ButtonClass:new(monitorX - 8, monitorY - 1, "Restart")
RestartButton:changeStyle(colors.black, colors.green)
table.insert(buttonList, RestartButton)


local OnStop =
    (function()
        keepTesting = false
        keepHolding = false
    end)

StopButton:setFunction(OnStop)

local OnRestart = 
    (function()
        keepHolding = false
    end)

RestartButton:setFunction(OnRestart)    



page:addButtons(buttonList)
page:disableErase()
-- main loop
while keepTesting do
    MonUtils.resetMonitor(monitor)
    logger.terminal.clear() 
    shell.run(programName,table.unpack(programArgs))
    -- program ended for some reason ... see if you want to restart it
    page:draw()
    keepHolding = true
    while keepHolding do
        ---@diagnostic disable-next-line: undefined-field
        page:handleEvent(os.pullEvent())
    end
end






