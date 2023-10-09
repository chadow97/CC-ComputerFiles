local logger = require("UTIL.logger")
-- Define the ButtonClass table

local ElementClass = {}
ElementClass.__index = ElementClass

-- Define a constructor for the ButtonClass
function ElementClass:new(xPos, yPos)
  self = setmetatable({}, ElementClass)
  self.x = xPos or 1
  self.y = yPos or 1
  self.monitor = nil
  self.parentPage = nil
  self.onElementTouchedCallback = nil
  self.onDrawCallback = nil
  return self
end

function ElementClass:askForRedraw()
    if self.parentPage then
        self.parentPage:askForRedraw(self) -- passing asker
    end
end

function ElementClass:setMonitor(monitor)
    self.monitor = monitor
end

function ElementClass:setOnDrawCallback( onDrawCallback)
    self.onDrawCallback = onDrawCallback
end

function ElementClass:draw(startLimitX, startLimitY, endLimitX, endLimitY)
    if self.onDrawCallback then
        self:onDrawCallback()
    end
    self:internalDraw(startLimitX, startLimitY, endLimitX, endLimitY)
end

function ElementClass:internalDraw(startLimitX, startLimitY, endLimitX, endLimitY)
    logger.log("Called not implemented draw!")
end

function ElementClass:handleTouchEvent(eventName, side, xPos, yPos)

    if self:isPosInElement(xPos, yPos) then
        self:callElementTouchedCallback()
        return true
    end
    return false
end

function ElementClass:callElementTouchedCallback()
    if self.onElementTouchedCallback then
        self:onElementTouchedCallback()
    end
end


function ElementClass:handleEvent(eventName, ...)

    if eventName == "monitor_touch" then
        return self:handleTouchEvent(eventName, ...)
    end

    return false
end

function ElementClass:getArea()
    logger.log("Called unimplemented getArea")
end

function ElementClass:isPosInElement(x, y)
    logger.log("Called unimplemented isPosInElement")
end

function ElementClass:setPos(x, y)
    self.x = x
    self.y = y
end

function ElementClass:getPos()
    return self.x,self.y
end

function ElementClass:setBackColor(backColor)
    self.backColor = backColor
end

function ElementClass:setTextColor(textColor)
    self.textColor = textColor
end

function ElementClass:changeStyle(textColor, backColor)
    self:setTextColor(textColor or self.textColor)
    self:setBackColor(backColor or self.backColor)
end

function ElementClass:setOnElementTouched(onElementTouchedCallback)
    self.onElementTouchedCallback = onElementTouchedCallback
end

function ElementClass:setParentPage(page)
    self.parentPage = page
end

function ElementClass:onResumeAfterContextLost()
    -- nothing to do!
end

return ElementClass