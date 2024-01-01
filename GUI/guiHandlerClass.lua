local logger = require "UTIL.logger"
local DocumentClass = require "MODEL.DocumentClass"

local PerformanceMonitorClass = require("PERFMON.PerformanceMonitor")



---@class GuiHandler
local GuiHandlerClass = {}
function GuiHandlerClass:new(mainPage, shouldStopFunc, document)
    if not mainPage then
        error("Gui handler must have a page!")
    end
    ---@class GuiHandler
    local o = {
      mainPage = mainPage,
      shouldStopFunc = shouldStopFunc or function() return false end,
      onRefreshCallbacks = {},
      document = document,
      refreshDelay = document.config:get(DocumentClass.configs.refresh_delay)
    }
    setmetatable(o, self)

    -- make sure to draw when edition is done.
    document:addEditionListener(o)

    self.__index = self
    return o
  end

function GuiHandlerClass:onEditionEnded()
  local elementsToDraw = self.document:getElementsToDraw(self.mainPage)
  for _, elementToDraw in ipairs(elementsToDraw) do
    elementToDraw:draw()
  end
  self.document:clean()
end

function GuiHandlerClass:setMainPage(page)
  self.mainPage = page
end

function GuiHandlerClass:setShouldStopFunc(func)
  self.shouldStopFunc = func
end

function GuiHandlerClass:addOnRefreshCallback(func)
  table.insert(self.onRefreshCallbacks, func)
end

function GuiHandlerClass:handleRefresh()
  for _, func in ipairs(self.onRefreshCallbacks) do
    func()
  end
end

function GuiHandlerClass:loop()
  local refreshTimerID = nil
  local timerStartTime = nil
  local PerfMonitor = PerformanceMonitorClass.getInstance()
  
  while not self.shouldStopFunc() do
    local timeSinceLastUpdate = 0
    
    if timerStartTime then
      timeSinceLastUpdate = (os.epoch("utc") - timerStartTime) / 1000
    end
    
    if timeSinceLastUpdate >= self.refreshDelay then
      if refreshTimerID then
        os.cancelTimer(refreshTimerID)
      end
      refreshTimerID = nil
    end
    
    if not refreshTimerID then
      refreshTimerID = os.startTimer(self.refreshDelay)
      timerStartTime = os.epoch("utc")
    end

    if PerfMonitor ~= nil then
        PerfMonitor:startSection("Event Pull")   
    end
    local eventData = {os.pullEvent()}
    ---@type string
    local eventName = eventData[1]
    local isRefreshingData = false
    if PerfMonitor ~= nil then
        PerfMonitor:endSection("Event Pull")
    end
    --overload event refresh data
    if eventName == "timer" and eventData[2] == refreshTimerID then
        eventName = "refresh_data"
        eventData = {eventName}
        refreshTimerID = nil
        isRefreshingData = true
        
    end
    if PerfMonitor ~= nil then
        PerfMonitor:startSection(eventName)
    end
    if (isRefreshingData) then
        self:handleRefresh()
    end
    self.document:handleEvent(table.unpack(eventData))
    self.mainPage:handleEvent(table.unpack(eventData))
    if PerfMonitor ~= nil then
        PerfMonitor:endSection(eventName)
    end
  end
end

return GuiHandlerClass
