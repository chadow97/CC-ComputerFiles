local logger = require "UTIL.logger"
local GuiHandlerClass = {}

function GuiHandlerClass:new(refreshDelay, mainPage, shouldStopFunc, document)
    if not mainPage then
        error("Gui handler must have a page!")
    end
    local o = {
      refreshDelay = refreshDelay or 1,
      mainPage = mainPage,
      shouldStopFunc = shouldStopFunc or function() return false end,
      onRefreshCallbacks = {},
      document = document
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
  

function GuiHandlerClass:setRefreshDelay(rate)
  self.refreshRate = rate
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
    
    local eventData = {os.pullEvent()}
    local eventName = eventData[1]
    
    if eventName == "timer" and eventData[2] == refreshTimerID then
      eventData = {"refresh_data"}
      refreshTimerID = nil
      self:handleRefresh()
    end
    
    self.mainPage:handleEvent(unpack(eventData))
  end
end

return GuiHandlerClass
