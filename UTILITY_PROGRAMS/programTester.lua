-- add absolute paths to package to allow programs to use libraries from anywhere!
package.path = package.path .. ";/?;/?.lua"

local ButtonClass = require("GUI.ButtonClass")
local PageClass = require("GUI.PageClass")
local MonUtils = require("UTIL.monUtils")
local logger = require("UTIL.logger")
local DocumentClass = require("MODEL.DocumentClass")

--Setup autocomplete
local completion = require "cc.shell.completion"
local complete = completion.build(
    {completion.file}
)

shell.setCompletionFunction("programTester.lua", complete)


logger.init(term.current(),"programTester.log", true)

local args = {...}

local programName = args[1]

if programName == nil then
    print("Syntax is: programTester programName arguments")
    return
end

local programArgs = args

local monitor = peripheral.find("monitor")
local keepTesting = true
local keepHolding = true
local shouldSleep = true
local sleepTime = 9

table.remove(programArgs, 1)

local document = DocumentClass:new()

local page = PageClass:new(monitor, 1,1, document)

local monitorX, monitorY = monitor.getSize()


local buttonList = {}
local StopButton = ButtonClass:new( monitorX - 14, monitorY - 1, "Stop", document)
StopButton:changeStyle(colors.black, colors.red)
table.insert(buttonList, StopButton)

local RestartButton = ButtonClass:new(monitorX - 7, monitorY - 1, "Restart", document)
RestartButton:changeStyle(colors.black, colors.green)

table.insert(buttonList, RestartButton)

local CountdownButton = ButtonClass:new(monitorX - 14, monitorY - 5, "Countdown", document)
CountdownButton:changeStyle(colors.black, colors.orange)
CountdownButton:forceHeightSize(3)
CountdownButton:forceWidthSize(16)
table.insert(buttonList, CountdownButton)



local OnStop =
    (function()
        keepTesting = false
        keepHolding = false
    end)

StopButton:setOnElementTouched(OnStop)

local OnRestart = 
    (function()
        keepHolding = false
    end)

RestartButton:setOnElementTouched(OnRestart)   



page:addElements(buttonList)
page:setIsTransparentBack(true)
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
            local percentString = ""

            if percent < 10 then
                percentString = '0' .. percent
            else
                percentString = tostring(percent)
            end
            CountdownButton.text = "" .. percentString .. "%:" .. squareString ..emptyString
            page:draw()
            sleep(0.1)
            
        end
        
    end
    
end






