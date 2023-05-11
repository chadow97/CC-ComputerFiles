local GuiHandlerClass = {}

function GuiHandlerClass:new(refreshDelay, mainPage, shouldStopFunc)
    if not mainPage then
        error("Gui handler must have a page!")
    end
    local o = {
      refreshDelay = refreshDelay or 1,
      mainPage = mainPage,
      shouldStopFunc = shouldStopFunc or function() return false end,
    }
    setmetatable(o, self)
    self.__index = self
    return o
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
    end
    
    self.mainPage:handleEvent(unpack(eventData))
  end
end

return GuiHandlerClass
