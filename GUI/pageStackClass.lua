local logger = require "UTIL.logger"
local ToggleableButtonClass = require("GUI.ToggleableButtonClass")
local PageClass             = require("GUI.PageClass")
local stringUtils           = require("UTIL.stringUtils")


---@class PageStack: Page
local PageStackClass = {}
PageStackClass.__index = PageStackClass
setmetatable(PageStackClass, { __index = PageClass })


-- constructor
function PageStackClass:new( document)
  self = setmetatable(PageClass:new( 1,1, document), PageStackClass)
  self.pageStack = {}
  self.functionsToCallOnExitMap = {}

  self.exitButton = ToggleableButtonClass:new(1,1, "X", self.document)
  self:updateButtonPosition()
  self.exitButton:setMargin(0)
  self.type = "pageStack"
  
  ---@type function
  self.onFirstPageClosed = nil
  PageClass.addElement(self, self.exitButton)

  self.exitButton:setOnManualToggle(
      (function(button) 
          self:popPage()
      end)
  )

  return self
end

function PageStackClass:getExitButton()
    return self.exitButton
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
    if not self.x or self.sizeX or self.y then
      return
    end
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
function PageStackClass:pushPage(page, functionToCallOnExit)
  self.document:startEdition()
  table.insert(self.pageStack, page)
  page:setMonitor(self.monitor)
  page:setParentPage(self)
  page:setSize(self:getSize())
  page:setPos(self.x, self.y)
  self.document:registerCurrentAreaAsDirty(self)
  self.functionsToCallOnExitMap[page.id] = functionToCallOnExit
  self.document:endEdition()
end


---@param func function
function PageStackClass:setOnFirstPageClosed(func)
    self.onFirstPageClosed = func
end

-- pop the top page from the stack
function PageStackClass:popPage(dataToPass)
  
  if #self.pageStack == 0 then
    error("No pages inserted!!")
    return
  end
  if (#self.pageStack == 1) then
    if self.onFirstPageClosed then
        self.onFirstPageClosed()
    end
    return
  end
  self.document:startEdition()
  local removedPage = table.remove(self.pageStack)
  local functionForRemovedPage = self.functionsToCallOnExitMap[removedPage.id]
  self.functionsToCallOnExitMap[removedPage.id] = nil
  if  functionForRemovedPage then
    functionForRemovedPage(dataToPass)
  end

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