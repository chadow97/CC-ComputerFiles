local logger = require("UTIL.logger")
local IdGenerator = require("UTIL.IdGenerator")
local AreaClass = require("UTIL.AreaClass")
local expect    = require("cc.expect").expect
-- Define the ButtonClass table

---@class Element
local ElementClass = {}
ElementClass.__index = ElementClass

ElementClass.DIRTY_STATES = {
    CLEAN = 1,
    SELF_DIRTY = 2,
    PARENT_DIRTY = 3
}

ElementClass.properties = { on_draw_function = "on_draw_function"}

-- Define a constructor for the ButtonClass
function ElementClass:new(xPos, yPos, document)
  expect(1, xPos,"number", "nil")
  expect(2, yPos,"number", "nil")
  ---@class Element
  local instance = setmetatable({}, ElementClass)
  instance.x = xPos or 1
  instance.y = yPos or 1
  instance.monitor = nil
  instance.parentPage = nil
  instance.onElementTouchedCallback = nil
  instance.onDrawCallback = nil
  instance.onRefreshCallback = nil
  instance.id = IdGenerator.generateId()
  instance:setParentDirty()
  instance.blockDraw = false
  instance.document = document
  instance.type = "element"
  logger.logOnError(document,"Document is invalid")
  return instance
end

function ElementClass:__tostring()
 return assert(false, "toStringShouldBeOverloaded")
end

function ElementClass:getChildElements()
    return assert(false, "getChildElements not implemented")
end

function ElementClass:canTryToOnlyDrawChild(dirtyArea, child)
    -- by default, if an area fits a child we should probably only draw that child
    return true
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
    if self.blockDraw then 
        return false
    end
    if self.parentPage then
        -- by default, you can draw ur child if ur parent allows ur to draw yourself
        return self.parentPage:canDraw(self)
    end
    -- if no parent, child can be drawn
    return true
end

function ElementClass:setMonitor(monitor)
    self.monitor = monitor
    self:setParentDirty()
end

function ElementClass:setOnDrawCallback( onDrawCallback)
    self.onDrawCallback = onDrawCallback
end

function ElementClass:setBlockDraw( shouldBlockDraw )
    self.blockDraw = shouldBlockDraw
end

function ElementClass:setProperties(properties)
    for propertyKey, propertyValue in pairs(properties) do
        if propertyKey == ElementClass.properties.on_draw_function then
            self:setOnDrawCallback(propertyValue)
        end
    end
end

function ElementClass:draw()

    if not self:canDraw(self) then
        return
    end
    logger.log("Drawing :" .. tostring(self), logger.LOGGING_LEVEL.INFO)
    if self.onDrawCallback then
        self:onDrawCallback()
    end
    self:internalDraw()
    self:removeDirty()
end

function ElementClass:internalDraw()
    error("Called not implemented draw!")
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

function ElementClass:setOnRefreshCallback(func)
    self.onRefreshCallback = func
end

function ElementClass:handleRefreshEvent(eventName, ...)
    if self.onRefreshCallback then
        self.onRefreshCallback(self)
    end
    return false
end


function ElementClass:handleEvent(eventName, ...)
    if eventName == "refresh_data" then
        return self:handleRefreshEvent(eventName, ...)
    end
    if eventName == "monitor_touch" then
        return self:handleTouchEvent(eventName, ...)
    end

    return false
end

function ElementClass:getArea()
    error("Called unimplemented getArea")
end

function ElementClass:getAreaAsObject()
    return AreaClass:new(self:getArea())
end

function ElementClass:isPosInElement(x, y) 
    local startX, startY, endX, endY = self:getArea()
    local xInside = x >= startX and x <= endX
    local yInside = y >= startY and y <= endY

    return xInside and yInside
end

function ElementClass:setPos(x, y)
    expect(1,x,"number", "nil")
    expect(2,y, "number", "nil")
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


---@param style Style
function ElementClass:applyStyle(style)
    style:applyStyleToElement(self)
end

function ElementClass:applyDocumentStyle()
    self:applyStyle(self.document.style)
end

function ElementClass:onResumeAfterContextLost()
    -- nothing to do!
end

return ElementClass