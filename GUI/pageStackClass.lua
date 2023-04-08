local logger = require "UTIL.logger"
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
  }
  setmetatable(obj, self)
  self.__index = self
  return obj
end

-- setter and getter for monitor
function PageStackClass:setMonitor(monitor)
  self.monitor = monitor
end

function PageStackClass:getMonitor()
  return self.monitor
end

-- push a page onto the stack
function PageStackClass:pushPage(page)
  table.insert(self.pageStack, page)
  logger.logToFile("page in pagestack is now " .. page.title)
  page:setMonitor(self.monitor)
  page:setPage(self)
  page:setSize(self:getSize())
  page:setPosition(self.posX, self.posY)
  self:draw()
end

-- pop the top page from the stack
function PageStackClass:popPage()
  table.remove(self.pageStack)
  self:draw()
end

function PageStackClass:getTopPage()
    return self.pageStack[#self.pageStack]
end

-- draw the current stack of pages
function PageStackClass:draw()
  logger.logToFile("drawing PageStack , redirecting to:" .. self:getTopPage().title)
  self:getTopPage():draw()
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
end

function PageStackClass:setSize(sizeX,sizeY)
    self.sizeX = sizeX
    self.sizeY = sizeY
end

function PageStackClass:setPage(page)
    self.parentPage = page
end

-- handle an event
function PageStackClass:handleEvent(...)
    logger.logToFile("handling event in pageStack, sending it to :" .. self:getTopPage().title)
    return self:getTopPage():handleEvent(...)
end

return PageStackClass