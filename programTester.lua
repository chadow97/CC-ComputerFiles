local ButtonClass = require("GUI.buttonClass")
local ToggleableButtonClass = require("GUI.toggleableButtonClass")
local PageClass = require("GUI.pageClass")
local MonUtils = require("UTIL.monUtils")
local logger = require("UTIL.logger")


logger.init(term.current())
logger.deactiveate()


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
local shouldSleep = true
local sleepTime = 9

table.remove(programArgs, 1)

local page = PageClass.new(monitor)

monitorX, monitorY = monitor.getSize()


local buttonList = {}
local StopButton = ButtonClass:new( monitorX - 14, monitorY - 1, "Stop")
StopButton:changeStyle(colors.black, colors.red)
table.insert(buttonList, StopButton)

local RestartButton = ButtonClass:new(monitorX - 7, monitorY - 1, "Restart")
RestartButton:changeStyle(colors.black, colors.green)

table.insert(buttonList, RestartButton)

local CountdownButton = ButtonClass:new(monitorX - 14, monitorY - 5, "Countdown")
CountdownButton:changeStyle(colors.black, colors.orange)
CountdownButton:forceHeightSize(3)
CountdownButton:forceWidthSize(16)
table.insert(buttonList, CountdownButton)



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
    CountdownButton.text = ""
    page:draw()
    keepHolding = true
    while keepHolding do
        ---@diagnostic disable-next-line: undefined-field
        page:handleEvent(os.pullEvent())
    end
    if keepTesting and shouldSleep then
        local percent = 0
        for i = 1, sleepTime, 0.1 do
            percent = math.floor((i-1)/(sleepTime - 1) * 100)
            local count = math.floor(percent / 10)
            local squareString = string.rep('O', count)
            local emptyString = string.rep(".", 10- count)

            if percent < 10 then
                percent = '0' .. percent
            else
                percent = tostring(percent)
            end
            CountdownButton.text = "" .. percent .. "%:" .. squareString ..emptyString
            page:draw()
            sleep(0.1)
            
        end
        
    end
    
end






