local logger = require("UTIL.logger")
local CustomPaintUtils = require("UTIL.customPaintUtils")
local ElementClass     = require("GUI.elementClass")

local PageClass = {}
PageClass.__index = PageClass
setmetatable(PageClass, { __index = ElementClass })

function PageClass:new(monitor, xPos, yPos)
    logger.log(monitor)
    self = setmetatable(ElementClass:new(xPos, yPos), PageClass)
    self.elements = {}
    logger.callStackToFile()
    -- By default, area is entire monitor
    self.x = xPos or 1
    self.y = yPos or 1
    self:setMonitor(monitor)
    self.sizeX, self.sizeY = self.monitor.getSize()
    self.eraseOnDraw = true
    self.backColor = colors.black
    self.blockDraw = false
    return self
end

function PageClass:add(pageElement)
    pageElement:setMonitor(self.monitor)
    pageElement:setParentPage(self)
    table.insert(self.elements, pageElement)
end

function PageClass:setBackColor(color)
    self.backColor = color or self.backColor
end

function PageClass:setBlockDraw( shouldBlockDraw )
    self.blockDraw = shouldBlockDraw
end

function PageClass:addButtons(buttonList)
    for _, button in ipairs(buttonList) do      
        self:add(button)
    end
end

function PageClass:getElementCount()
    return #self.elements
end

function PageClass:getElements()
    return self.elements
end

-- Define the draw method to draw the page
function PageClass:draw(startLimitX, startLimitY, endLimitX, endLimitY)
    if self.blockDraw then
        return
    end
    ElementClass.draw(self, startLimitX, startLimitY, endLimitX, endLimitY)

end

function PageClass:internalDraw(startLimitX, startLimitY, endLimitX, endLimitY)
    if self.eraseOnDraw then
        local startX, startY, endX, endY = self:getArea()
        CustomPaintUtils.drawFilledBox(startX, startY, endX, endY,  self.backColor, self.monitor)
    end
    for _, element in ipairs(self.elements) do
        element:draw(startLimitX, startLimitY, endLimitX, endLimitY)
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


-- Define the handleEvent method to handle events on the page
function PageClass:handleEvent(...)
    for i = #self.elements, 1, -1 do
        local button = self.elements[i]
        if button:handleEvent(...) then
            return true
        end
    end
    return ElementClass.handleEvent(self, ...)
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

return PageClass