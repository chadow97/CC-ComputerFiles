local logger = require "UTIL.logger"
local ToggleableButtonClass = require("GUI.toggleableButtonClass")
-- define the PageStackClass
PageStackClass = {}

-- constructor
function PageStackClass:new(monitor)
  local obj = {
    pageStack = {},
    monitor = monitor,
    posX = 1,
    posY = 1,
    sizeX = 10,
    sizeY = 10,
    parentPage = nil,
    exitButton = nil
  }
  setmetatable(obj, self)
  self.__index = self

  self.exitButton = ToggleableButtonClass:new(1,1, "X")
  obj:updateButtonPosition()
  self.exitButton:setMargin(0)
  self.exitButton:setMonitor(monitor)
  self.exitButton:setPage(obj)

  self.exitButton:setOnManualToggle(
      (function(button) 
          obj:popPage()
      end)
  )


  return obj
end

function PageStackClass:updateButtonPosition()
    self.exitButton:setPos(self.posX+ self.sizeX - 1,self.posY)
end

-- setter and getter for monitor
function PageStackClass:setMonitor(monitor)
  self.monitor = monitor
  self.exitButton:setMonitor(monitor)
end

function PageStackClass:getMonitor()
  return self.monitor
end

-- push a page onto the stack
function PageStackClass:pushPage(page)
  table.insert(self.pageStack, page)

  page:setMonitor(self.monitor)
  page:setPage(self)
  page:setSize(self:getSize())
  page:setPosition(self.posX, self.posY)
  self:draw()
end

-- pop the top page from the stack
function PageStackClass:popPage()
  if (#self.pageStack == 1) then
    return
  end
  table.remove(self.pageStack)

  self:getTopPage():onResumeAfterContextLost()


  self:draw()
end

function PageStackClass:getTopPage()
    return self.pageStack[#self.pageStack]
end

function PageStackClass:askForRedraw(asker)
    -- PageStackClass in control of area, if page is shown it is ok to draw

    if asker == self.exitButton then
        self:draw()
    end

    if asker == self:getTopPage() then
        self:draw()
    end
end

-- draw the current stack of pages
function PageStackClass:draw()

  self:getTopPage():draw()
  self.exitButton:draw()
end

-- get the area covered by the page stack
function PageStackClass:getArea()

  return self.posX, self.posY, self.posX + self.sizeX - 1, self.posY + self.sizeY - 1, self.sizeX, self.sizeY
end

-- get the size of the page stack
function PageStackClass:getSize()
    return self.sizeX, self.sizeY
end

function PageStackClass:setPosition(posX,posY)
    self.posX = posX
    self.posY = posY
    self:updateButtonPosition()
end

function PageStackClass:setSize(sizeX,sizeY)
    self.sizeX = sizeX
    self.sizeY = sizeY
    self:updateButtonPosition()
end

function PageStackClass:setPage(page)
    self.parentPage = page
end

-- handle an event
function PageStackClass:handleEvent(...)

    if self.exitButton:handleEvent(...) then
        return true
    end
    return self:getTopPage():handleEvent(...)
end

function PageStackClass:onResumeAfterContextLost()
    self.exitButton:onResumeAfterContextLost()
    self:getTopPage():onResumeAfterContextLost()
end

return PageStackClass