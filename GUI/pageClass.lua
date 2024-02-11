local logger = require("UTIL.logger")
local CustomPaintUtils = require("UTIL.customPaintUtils")
local ElementClass     = require("GUI.ElementClass")
local stringUtils      = require("UTIL.stringUtils")
local expect    = require("cc.expect").expect

---@class Page:Element
local PageClass = {}
PageClass.__index = PageClass
setmetatable(PageClass, { __index = ElementClass })

local DEFAULT_BACK_COLOR = colors.black


function PageClass:new(xPos, yPos, document)
    expect(2,xPos,"number", "nil")
    expect(3, yPos,"number", "nil")

    self = setmetatable(ElementClass:new(xPos, yPos, document), PageClass)
    self.elements = {}
    -- By default, area is entire monitor
    self.x = xPos or 1
    self.y = yPos or 1
    self.sizeX = nil
    self.sizeY = nil
    self.transparentBack = false
    self.areElementsPositionRelative = false;
    self.backColor = DEFAULT_BACK_COLOR
    self.type = "page"
    return self
end

function PageClass:__tostring() 
    return stringUtils.Format("[Page %(id), nElements:%(nelements), Position:%(position), Size:%(size)]",
                              {id = self.id,
                              nelements = #self.elements,
                              position = (stringUtils.CoordToString(self.x, self.y)),
                              size = (stringUtils.CoordToString(self:getSize()))})
   
end

function PageClass:getChildElements()
    return self.elements
end

function PageClass:getChildIds()
    local childs = ""
    for index, value in ipairs(self.elements) do
        childs = childs .. value.id
        if index ~= #self.elements then
            childs = childs .. ","
        end
    end
    return stringUtils.UFormat("PageElements:[%s]", childs)
end

function PageClass:addElement(pageElement)
    pageElement:setMonitor(self.monitor)
    pageElement:setParentPage(self)
    table.insert(self.elements, pageElement)
end

function PageClass:setBackColor(color)
    if not color then
        self:setIsTransparentBack(true)
    else    
        self:setIsTransparentBack(false)
    end
    self.backColor = color or self.backColor
end

function PageClass:addElements(buttonList)
    for _, button in ipairs(buttonList) do      
        self:addElement(button)
    end
end

function PageClass:getElementCount()
    return #self.elements
end

function PageClass:getElements()
    return self.elements
end

function PageClass:removeElement(elementToFind)
    local elementPosition = nil
    for index, element in ipairs(self.elements) do
        if (element.id == elementToFind.id) then
            elementPosition = index
            break
        end
    end
    if (elementPosition) then
        table.remove(self.elements, elementPosition )
    else
        error("asked to remove unknown element from page")
    end
end


function PageClass:internalDraw()
    if not self.transparentBack then
        local startX, startY, endX, endY = self:getArea()
        CustomPaintUtils.drawFilledBox(startX, startY, endX, endY,  self.backColor, self.monitor)
    end
    for _, element in ipairs(self.elements) do
        element:draw()
    end

end

function PageClass:getArea()
    return self.x, self.y, self.x + self.sizeX - 1, self.y + self.sizeY - 1, self.sizeX, self.sizeY
end

function PageClass:getSize()
    return self.sizeX, self.sizeY
end

function PageClass:setSize(sizeX,sizeY)
    self.sizeX = sizeX
    self.sizeY = sizeY
end

function PageClass:setAreElementsPositionRelative(areElementsPositionRelative)
    self.areElementsPositionRelative = areElementsPositionRelative

end

function PageClass:setPos(posX, posY)
    if not self.areElementsPositionRelative then
        ElementClass.setPos(self, posX, posY)
        return
    end
    local OriginalPosX, OriginalPosY = self:getPos()
    local DeltaX = posX - OriginalPosX
    local DeltaY = posY - OriginalPosY
    for element in self:allElementsIterator() do
        local OriginalElementPosX, OriginalElementPosY = element:getPos()
        local FinalPosX = OriginalElementPosX + DeltaX
        local FinalPosY = OriginalElementPosY + DeltaY
        element:setPos(FinalPosX, FinalPosY)
    end
    ElementClass.setPos(self, posX, posY)
end

-- Define the handleEvent method to handle events on the page
function PageClass:handleEvent(eventName, ...)
    for i = #self.elements, 1, -1 do
        local element = self.elements[i]
        if element:handleEvent(eventName, ...) then
            return true
        end
    end
    return ElementClass.handleEvent(self, eventName, ...)
end

function PageClass:handleTouchEvent(...)

    if self.transparentBack then
        return false
    else 
        return ElementClass.handleTouchEvent(self, ...)
    end
end

function PageClass:onResumeAfterContextLost()
    for _, element in pairs(self.elements) do
        element:onResumeAfterContextLost()
    end
    ElementClass.onResumeAfterContextLost(self)
end

function PageClass:setIsTransparentBack( isTransparentBack)
    self.transparentBack = isTransparentBack
end

function PageClass:setMonitor(monitor)
    ElementClass.setMonitor(self, monitor)
    if not (self.elements) then
        return
    end
    for _, element in ipairs(self.elements) do
        element:setMonitor(monitor)
    end

end

function PageClass:allElementsIterator()
    local position = 1
    return function ()
        local element = self.elements[position]
        position = position + 1
        return element 
    end
end

---@param style Style
function PageClass:applyStyle(style)
    style:applyStyleToPage(self)
end

return PageClass