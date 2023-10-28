local logger = require "UTIL.logger"
local ToggleableButtonClass = require("GUI.toggleableButtonClass")
local PageClass             = require("GUI.pageClass")
-- define the PageStackClass

local PageStackClass = {}
PageStackClass.__index = PageStackClass
setmetatable(PageStackClass, { __index = PageClass })


-- constructor
function PageStackClass:new(monitor)
  self = setmetatable(PageClass:new(monitor), PageStackClass)
  self.pageStack = {}

  self.exitButton = ToggleableButtonClass:new(1,1, "X")
  self:updateButtonPosition()
  self.exitButton:setMargin(0)
  PageClass.addElement(self, self.exitButton)

  self.exitButton:setOnManualToggle(
      (function(button) 
          self:popPage()
      end)
  )

  return self
end

function PageStackClass:updateButtonPosition()
    self.exitButton:setPos(self.x+ self.sizeX - 1,self.y)
end

function PageStackClass:changeExitButtonStyle(...)
  self.exitButton:changeStyle(...)
end

-- adding a page in a pageStackClass puts it on top of the stack
function PageStackClass:addElement(page)
  self:pushPage(page)
end

-- push a page onto the stack
function PageStackClass:pushPage(page)
  table.insert(self.pageStack, page)

  page:setMonitor(self.monitor)
  page:setParentPage(self)
  page:setSize(self:getSize())
  page:setPos(self.x, self.y)
  self:setElementDirty()
  self:askForRedraw(self)
end

-- pop the top page from the stack
function PageStackClass:popPage()
  if #self.pageStack == 0 then
    logger.log("No pages inserted!!")
    return
  end
  if (#self.pageStack == 1) then
    return
  end
  table.remove(self.pageStack)

  self:getTopPage():onResumeAfterContextLost()


  self:askForRedraw(self)
end

function PageStackClass:getTopPage()
    return self.pageStack[#self.pageStack]
end

function PageStackClass:canDraw(asker)
  -- page stack doesnt allow any drawing unless its the top page, as the other pages are hidden under.
  if asker ~= self:getTopPage() and asker ~= self and asker ~= self.exitButton then
    return false
  end
  return PageClass.canDraw(self, asker)
end


function PageStackClass:askForRedraw(asker)
    -- PageStackClass in control of area, if page is shown it is ok to draw
    if asker ~= self:getTopPage() and asker ~= self and asker ~= self.exitButton then
      return
    end
    PageClass.askForRedraw(self,asker)
end

function PageStackClass:internalDraw()
  self:getTopPage():draw()
  self.exitButton:draw()
end

function PageStackClass:setPosition(x,y)
    PageClass.setPos(self, x, y)
    self:updateButtonPosition()
    self:setElementDirty()
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