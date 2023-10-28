local logger = require("UTIL.logger")
local CustomPaintUtils = require("UTIL.customPaintUtils")
local ElementClass     = require("GUI.elementClass")

local PageClass = {}
PageClass.__index = PageClass
setmetatable(PageClass, { __index = ElementClass })

local DEFAULT_BACK_COLOR = colors.black

function PageClass:new(monitor, xPos, yPos)
    self = setmetatable(ElementClass:new(xPos, yPos), PageClass)
    self.elements = {}
    -- By default, area is entire monitor
    self.x = xPos or 1
    self.y = yPos or 1
    self:setMonitor(monitor)
    self.sizeX, self.sizeY = self.monitor.getSize()
    self.eraseOnDraw = true
    self.backColor = DEFAULT_BACK_COLOR
    return self
end

function PageClass:addElement(pageElement)
    pageElement:setMonitor(self.monitor)
    pageElement:setParentPage(self)
    table.insert(self.elements, pageElement)
    self:setElementDirty()
end

function PageClass:setBackColor(color)
    self.backColor = color or self.backColor
    self:setElementDirty()
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

function PageClass:internalDraw()
    if self.eraseOnDraw then
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
    self:setParentDirty()
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

function PageClass:onResumeAfterContextLost()
    for _, button in pairs(self.elements) do
        button:onResumeAfterContextLost()
    end
    ElementClass.onResumeAfterContextLost(self)
end

function PageClass:disableErase()
    self.eraseOnDraw = false
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

return PageClass