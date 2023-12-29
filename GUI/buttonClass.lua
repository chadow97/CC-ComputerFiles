local logger = require("UTIL.logger")
local CustomPaintUtils = require("UTIL.customPaintUtils")
local stringUtils = require('UTIL.stringUtils')
local ElementClass= require('GUI.ElementClass')

local DEFAULT_BACK_COLOR = colors.lightGray
local DEFAULT_TEXT_COLOR = colors.black

-- Define the ButtonClass table
---@class Button: Element
local ButtonClass = {}
ButtonClass.__index = ButtonClass
setmetatable(ButtonClass, { __index = ElementClass })

ButtonClass.properties = { should_center = "should_center"}

-- Define a constructor for the ButtonClass
function ButtonClass:new(xPos, yPos, text, document)
  ---@class Button: Element
  local instance = setmetatable(ElementClass:new(xPos, yPos, document), ButtonClass)
  instance.text = text
  instance.margin = 1
  instance.backColor = DEFAULT_BACK_COLOR
  instance.textColor = DEFAULT_TEXT_COLOR
  instance.forcedWidthSize = nil
  instance.forcedHeightSize = nil
  instance.shouldSplitText = true
  instance.shouldCenterText = false
  instance.limitArea = { startX = nil, startY = nil, endX = nil, endY = nil}
  instance.type = "element"
  return instance
end

function ButtonClass:__tostring() 
    return stringUtils.Format("[Button %(id), Text: %(text), Position:%(position), Size:%(size) ]",
                              {id = self.id, 
                              text = stringUtils.Truncate(tostring(self.text), 20), 
                              position = (stringUtils.CoordToString(self.x, self.y)),
                              size = (stringUtils.CoordToString(self:getSize()))})
   
end

function ButtonClass:getChildElements()
    -- buttons have no children! How sad!
    return {}
end

function ButtonClass:setProperties(properties)
    for propertyKey, propertyValue in pairs(properties) do
        if propertyKey == ButtonClass.properties.should_center then
            self:setCenterText(propertyValue)
        end
    end
    ElementClass.setProperties(self,properties)
end

function ButtonClass:setLimit(startLimitX, startLimitY, endLimitX, endLimitY)
    self.limitArea = { startX = startLimitX, startY = startLimitY, endX = endLimitX, endY = endLimitY}
end

function ButtonClass:getLimitValues()
    return self.limitArea.startX, self.limitArea.startY, self.limitArea.endX, self.limitArea.endY
end

-- Define a draw method for the ButtonClass
function ButtonClass:internalDraw()
  local startLimitX, startLimitY, endLimitX, endLimitY = self:getLimitValues()
  local startX, startY, endX, endY, sizeX, sizeY = self:getArea(false)

  local startXToDraw = startX
  local startYtoDraw = startY
  local endXToDraw = endX
  local endYToDraw = endY

  if startLimitX then
    startXToDraw = math.max(startXToDraw, startLimitX)
  end
  if startLimitY then
    startYtoDraw = math.max(startYtoDraw, startLimitY)
  end
  if endLimitX then
    endXToDraw = math.min(endXToDraw, endLimitX)
  end
  if endLimitY then

    endYToDraw = math.min(endYToDraw, endLimitY)
  end

  if ((endXToDraw - startXToDraw < 0) or
      (endYToDraw - startYtoDraw < 0) ) then
        return
  end

  CustomPaintUtils.drawFilledBox(startXToDraw, startYtoDraw, endXToDraw, endYToDraw,  self.backColor, self.monitor)
  if (self.y < startYtoDraw or self.y > endYToDraw) then
    return
  end

  self.monitor.setTextColor(self.textColor)

  local indexToStart = math.max(1, startXToDraw - self.x + 1)
  local indexToEnd = math.min(self:availableTextSize(), endXToDraw - self.x + 1)
  local maxTextSize = indexToEnd - indexToStart + 1


  if (indexToEnd - indexToStart < 0) then
    return
  end

  local endYToWrite = endYToDraw - self.margin

  local currentLine = self.y

  local textLines = self:getTextLines()
  if self.shouldCenterText then
    textLines = stringUtils.CenterLinesInRectangle(textLines, sizeX - (self.margin*2), sizeY - (self.margin*2) )
  end

  for _, line in ipairs(textLines) do
    if currentLine > endYToWrite then
        break
    end

    self.monitor.setCursorPos(self.x, currentLine)
    local textToWrite = string.sub(line, indexToStart, indexToEnd)

    self.monitor.write(textToWrite)
    currentLine = currentLine + 1
  end

end

function ButtonClass:handleEvent(eventName, ...)

    if eventName == "monitor_touch" then
        return self:handleTouchEvent(eventName, ...)
    else
        return ElementClass.handleEvent(self, eventName, ...)
    end
end

-- Define a getArea method for the ButtonClass
function ButtonClass:getArea( shouldLimit)
    -- should limit by default
    if not shouldLimit then
        shouldLimit = true
    end
    local startTextX, startTextY, sizeTextX, sizeTextY, endTextX, endTextY = self:getTextArea()
    local startX = startTextX - self.margin
    local startY = startTextY - self.margin

    local sizeX  = sizeTextX + (self.margin*2)
    
    local sizeY  = sizeTextY + (self.margin*2)


    local endX = startX + sizeX - 1
    local endY = startY + sizeY - 1

    if not shouldLimit then
        return startX, startY, endX, endY, sizeX, sizeY        
    end

    -- we want the actual area that is shown to the user, so we have to consider limits!
    local startLimitX, startLimitY, endLimitX, endLimitY = self:getLimitValues()
    if startLimitX then
        startX = math.max(startX, startLimitX)
    end

    if startLimitY then
        startY = math.max(startY, startLimitY)
    end
    if endLimitX then
        endX = math.min(endX, endLimitX)
    end
    if endLimitY then 
        endY = math.min(endY, endLimitY)
    end

    sizeX = endX - startX + 1
    sizeY = endY - startY + 1

    return startX, startY, endX, endY, sizeX, sizeY
end

function ButtonClass:getSize()
    local _, _, _,_, sizeX, sizeY = self:getArea()
    return sizeX, sizeY
end

function ButtonClass:getTextArea()

    local startTextX = self.x
    local startTextY = self.y
    local sizeTextX
    if self.forcedWidthSize then
        sizeTextX = self.forcedWidthSize - (self.margin * 2)
    else
        sizeTextX = #self.text
    end

    local sizeTextY
    if self.forcedHeightSize then
        sizeTextY = self.forcedHeightSize - (self.margin * 2)
    else
        sizeTextY = self:getTextHeight()
    end

    local endTextX = startTextX + sizeTextX - 1
    local endTextY = startTextY + sizeTextY - 1
    return startTextX, startTextY, sizeTextX, sizeTextY, endTextX, endTextY
end

function ButtonClass:getTextHeight()
    return #self:getTextLines()
end

function ButtonClass:getTextLines()
    if self.shouldSplitText then
        return stringUtils.splitLines(self.text)
    else
        return {self.text}
    end

end

function ButtonClass:setBackColor(backColor)
    self.backColor = backColor
    self:setElementDirty()
end

function ButtonClass:setTextColor(textColor)
    self.textColor = textColor
    self:setElementDirty()
end

function ButtonClass:changeStyle(textColor, backColor)
    self:setTextColor(textColor or self.textColor)
    self:setBackColor(backColor or self.backColor)
    self:setElementDirty()
end

function ButtonClass:getText()
    return self.text
end

function ButtonClass:setText(text)
    self.text = text
    self:setElementDirty()
end

function ButtonClass:setUpperCornerPos(x,y)
    self.x = x + self.margin
    self.y = y + self.margin
    self:setParentDirty()

end

function ButtonClass:setCenterText(shouldCenterText)
    self.shouldCenterText = shouldCenterText
    self:setElementDirty()
end

function ButtonClass:setMargin(margin)
    self.margin = margin
    self:setParentDirty()
end

function ButtonClass:forceWidthSize(forcedSize )  
    self.forcedWidthSize = forcedSize
    self:setParentDirty()
end

function ButtonClass:forceHeightSize(forcedSize)
    self.forcedHeightSize = forcedSize
    self:setParentDirty()
end

function ButtonClass:availableTextSize()
    if self.forcedWidthSize == nil then
        return #self.text
    end
    return self.forcedWidthSize - (self.margin * 2)
end

function ButtonClass:pressButton()
    self:callElementTouchedCallback()
end

---@param style Style
function ButtonClass:applyStyle(style)
    style:applyStyleToButton(self)
end

return ButtonClass


