local logger = require("UTIL.logger")
local CustomPaintUtils = require("UTIL.customPaintUtils")
local stringUtils = require('UTIL.stringUtils')
local ElementClass= require('GUI.elementClass')

local DEFAULT_BACK_COLOR = colors.lightGray
local DEFAULT_TEXT_COLOR = colors.black

-- Define the ButtonClass table

local ButtonClass = {}
ButtonClass.__index = ButtonClass
setmetatable(ButtonClass, { __index = ElementClass })

-- Define a constructor for the ButtonClass
function ButtonClass:new(xPos, yPos, text)
  self = setmetatable(ElementClass:new(xPos, yPos), ButtonClass)
  self.text = text
  self.margin = 1
  self.backColor = DEFAULT_BACK_COLOR
  self.textColor = DEFAULT_TEXT_COLOR
  self.forceWidthSize = nil
  self.forceHeightSize = nil
  self.shouldSplitText = true
  self.shouldCenterText = false
  return self
end

-- Define a draw method for the ButtonClass
function ButtonClass:internalDraw(startLimitX, startLimitY, endLimitX, endLimitY)
  local startX, startY, endX, endY = self:getArea()
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

  for _, line in ipairs(self:getTextLines()) do
    if currentLine > endYToWrite then
        break
    end

    self.monitor.setCursorPos(self.x, currentLine)
    local textToWrite = string.sub(line, indexToStart, indexToEnd)
    if self.shouldCenterText then
        local lettersToWrite = #line
        local spacesToAdd = math.max(0,math.floor((maxTextSize - lettersToWrite + 1)/2))
        textToWrite = string.rep(" ", spacesToAdd) .. textToWrite 
    end
    self.monitor.write(textToWrite)
    currentLine = currentLine + 1
  end

end

function ButtonClass:handleEvent(eventName, ...)

    if eventName == "monitor_touch" then
        return self:handleTouchEvent(eventName, ...)
    end

    return false
end

-- Define a getArea method for the ButtonClass
function ButtonClass:getArea()
    local startTextX, startTextY, sizeTextX, sizeTextY, endTextX, endTextY = self:getTextArea()
    local startX = startTextX - self.margin
    local startY = startTextY - self.margin

    local sizeX  = sizeTextX + (self.margin*2)
    
    local sizeY  = sizeTextY + (self.margin*2)


    local endX = startX + sizeX - 1
    local endY = startY + sizeY - 1

    return startX, startY, endX, endY, sizeX, sizeY
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

return ButtonClass


