local logger = require "UTIL.logger"
local ToggleableButtonClass = require("GUI.ToggleableButtonClass")
local PageClass             = require("GUI.PageClass")
local stringUtils           = require("UTIL.stringUtils")
-- define the PageStackClass

local PageStackClass = {}
PageStackClass.__index = PageStackClass
setmetatable(PageStackClass, { __index = PageClass })


-- constructor
function PageStackClass:new(monitor, document)
  self = setmetatable(PageClass:new(monitor, 1,1, document), PageStackClass)
  self.pageStack = {}

  self.exitButton = ToggleableButtonClass:new(1,1, "X", self.document)
  self:updateButtonPosition()
  self.exitButton:setMargin(0)
  self.type = "pageStack"
  PageClass.addElement(self, self.exitButton)

  self.exitButton:setOnManualToggle(
      (function(button) 
          self:popPage()
      end)
  )

  return self
end

function PageStackClass:__tostring() 
  return stringUtils.Format("[PageStack %(id), nElements:%(nelements), #Pages:%(npages), TopPageId:%(toppage), Position:%(position), Size:%(size) ]",
                            {id = self.id,
                            nelements = #self.elements,
                            npages = #self.pageStack,
                            toppage = self:getTopPage().id,
                            position = (stringUtils.CoordToString(self.x, self.y)),
                            size = (stringUtils.CoordToString(self:getSize()))})
 
end

function PageStackClass:getChildElements()
    local childs = {}
    local topPage = self:getTopPage()
    if topPage then
      table.insert(childs, topPage)      
    end
    for _, childElement in ipairs(self.elements) do
      table.insert(childs,childElement)
    end
    return childs
end

function PageStackClass:canTryToOnlyDrawChild(dirtyArea, child)
  -- if asking a child on top of the page, nothing to consider
  if child ~= self:getTopPage() then
    return true
  end
  -- if asking something on the back of the page, make sure childs will not erase overlay elements
  if dirtyArea:contains(self.exitButton:getAreaAsObject()) then
    return false
  end
  return true
end

function PageStackClass:updateButtonPosition()
    self.exitButton:setPos(self.x+ self.sizeX - 1,self.y)
end

function PageStackClass:changeExitButtonStyle(...)
  self.exitButton:changeStyle(...)
end

-- adding a page in a PageStackClass puts it on top of the stack
function PageStackClass:addElement(page)
  self:pushPage(page)
end

-- push a page onto the stack
function PageStackClass:pushPage(page)
  self.document:startEdition()
  table.insert(self.pageStack, page)
  page:setMonitor(self.monitor)
  page:setParentPage(self)
  page:setSize(self:getSize())
  page:setPos(self.x, self.y)
  self.document:registerCurrentAreaAsDirty(self)
  self.document:endEdition()
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
  self.document:startEdition()
  table.remove(self.pageStack)

  self:getTopPage():onResumeAfterContextLost()
  self.document:registerCurrentAreaAsDirty(self)
  self.document:endEdition()

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