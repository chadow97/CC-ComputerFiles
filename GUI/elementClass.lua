local logger = require("UTIL.logger")
local IdGenerator = require("UTIL.IdGenerator")
-- Define the ButtonClass table

local ElementClass = {}
ElementClass.__index = ElementClass

ElementClass.DIRTY_STATES = {
    CLEAN = 1,
    SELF_DIRTY = 2,
    PARENT_DIRTY = 3
}

-- Define a constructor for the ButtonClass
function ElementClass:new(xPos, yPos)
  self = setmetatable({}, ElementClass)
  self.x = xPos or 1
  self.y = yPos or 1
  self.monitor = nil
  self.parentPage = nil
  self.onElementTouchedCallback = nil
  self.onDrawCallback = nil
  self.id = IdGenerator.generateId()
  self:setParentDirty()
  return self
end

function ElementClass:shouldAskParentForRedraw()
    return self.dirtyState == ElementClass.DIRTY_STATES.PARENT_DIRTY
end

function ElementClass:shouldDrawElement()
    return self.dirtyState ~= ElementClass.DIRTY_STATES.CLEAN
end

function ElementClass:setParentDirty()
    self.dirtyState = ElementClass.DIRTY_STATES.PARENT_DIRTY
end

function ElementClass:setElementDirty()
    self.dirtyState = ElementClass.DIRTY_STATES.SELF_DIRTY
end

function ElementClass:removeDirty()
    self.dirtyState = ElementClass.DIRTY_STATES.CLEAN
end

function ElementClass:canDraw(asker)
    if self.parentPage then
        -- by default, you can draw ur child if ur parent allows ur to draw yourself
        return self.parentPage:canDraw(self)
    end
    -- if no parent, child can be drawn
    return true
end

function ElementClass:askForRedraw(asker)
    if self.parentPage and self:shouldAskParentForRedraw() then
        self.parentPage:askForRedraw(self)
    else
        self:draw()
    end
end

function ElementClass:setMonitor(monitor)
    self.monitor = monitor
    self:setParentDirty()
end

function ElementClass:setOnDrawCallback( onDrawCallback)
    self.onDrawCallback = onDrawCallback
end

function ElementClass:draw(startLimitX, startLimitY, endLimitX, endLimitY)
    if not self:canDraw(self) then
        return
    end
    if self.onDrawCallback then
        self:onDrawCallback()
    end

    self:internalDraw(startLimitX, startLimitY, endLimitX, endLimitY)
    self:removeDirty()
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
    local startX, startY, endX, endY = self:getArea()
    local xInside = x >= startX and x <= endX
    local yInside = y >= startY and y <= endY

    return xInside and yInside
end

function ElementClass:setPos(x, y)
    self.x = x
    self.y = y
    self:setParentDirty()
end

function ElementClass:getPos()
    return self.x,self.y
end

function ElementClass:setOnElementTouched(onElementTouchedCallback)
    self.onElementTouchedCallback = onElementTouchedCallback
end

function ElementClass:setParentPage(page)
    self.parentPage = page
    self:setParentDirty()
end

function ElementClass:onResumeAfterContextLost()
    -- nothing to do!
end

return ElementClass