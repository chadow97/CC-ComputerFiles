local logger = require("UTIL.logger")
local CustomPaintUtils = require("UTIL.customPaintUtils")
local IdGenerator = require("UTIL.IdGenerator")
local stringUtils = require('UTIL.stringUtils')
-- Define the ButtonClass table
local ButtonClass = {}

local defaultOldTextColor = colors.red



-- Define the metatable for the ButtonClass
local ButtonClass_mt = { __index = ButtonClass }



local function defaultButtonPressed(button)
    -- save number of time button was pressed
    if button.pressed == nil then
        button.pressed = 0
    end
    button.pressed = button.pressed + 1
    button:setText(tostring(button.pressed))
    button:askForRedraw()
end


-- Define a constructor for the ButtonClass
function ButtonClass.new(self, x, y, text)
  local obj = { x = x or 1,
                y = y or 1, 
                text = text,
                margin = 1,
                backColor = colors.lightGray,
                textColor = colors.black,
                func = defaultButtonPressed,
                monitor = monitor,
                page = nil,
                id = IdGenerator.generateId(),
                forcedWidthSize = nil,
                forcedHeightSize = nil,
                shouldSplitText = true,
                onDraw = nil

               }

  setmetatable(obj, ButtonClass_mt)
  return obj
end

function ButtonClass.setOnDraw(self, func)
    self.onDraw = func
end

function ButtonClass.askForRedraw(self)
    if self.page then
        self.page:askForRedraw(self) -- passing asker
    end
end

function ButtonClass.setMonitor(self, monitor)
    
    self.monitor = monitor
end



-- Define a draw method for the ButtonClass
function ButtonClass.draw(self, startLimitX, startLimitY, endLimitX, endLimitY)
  if self.onDraw then
    self.onDraw(self)
  end
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
    self.monitor.write(textToWrite)
    currentLine = currentLine + 1
  end

end

function ButtonClass.handleTouchEvent(self, eventName, side, xPos, yPos)

    if self:isPosInButton(xPos, yPos) then
        self.func(self)
        return true
    end
    return false
end


function ButtonClass.handleEvent(self, eventName, ...)

    if eventName == "monitor_touch" then
        return self:handleTouchEvent(eventName, ...)
    end

    return false
end

-- Define a getArea method for the ButtonClass
function ButtonClass.getArea(self)
    local startTextX, startTextY, sizeTextX, sizeTextY, endTextX, endTextY = self:getTextArea()
    local startX = startTextX - self.margin
    local startY = startTextY - self.margin

    local sizeX  = sizeTextX + (self.margin*2)
    
    local sizeY  = sizeTextY + (self.margin*2)


    local endX = startX + sizeX - 1
    local endY = startY + sizeY - 1

    return startX, startY, endX, endY, sizeX, sizeY

end

function ButtonClass.getTextArea(self)

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

function ButtonClass.getTextHeight(self)
    return #self:getTextLines()
end

function ButtonClass.getTextLines(self)
    if self.shouldSplitText then
        return stringUtils.splitLines(self.text)
    else
        return {self.text}
    end

end

function ButtonClass.isPosInButton(self, x, y)

    local startX, startY, endX, endY = self:getArea()
    local xInside = x >= startX and x <= endX
    local yInside = y >= startY and y <= endY

    return xInside and yInside

end

function ButtonClass.getText(self)
    return self.text
end

function ButtonClass.setText(self, text)
    self.text = text
end

function ButtonClass.setPos(self, x, y)
    self.x = x
    self.y = y
end

function ButtonClass.setUpperCornerPos(self,x,y)
    self.x = x + self.margin
    self.y = y + self.margin

end

function ButtonClass.getPos(self)
    return self.x,self.y
end

function ButtonClass.setMargin(self, margin)
    self.margin = margin
end

function ButtonClass.setBackColor(self, backColor)
    self.backColor = backColor
end

function ButtonClass.setTextColor(self, textColor)
    self.textColor = textColor
end

function ButtonClass.changeStyle(self, textColor, backColor)
    self:setTextColor(textColor or self.textColor)
    self:setBackColor(backColor or self.backColor)
end

function ButtonClass.setFunction(self, func)
    self.func = func
end

function ButtonClass.setPage(self, page)
    self.page = page
end

function ButtonClass.forceWidthSize(self, forcedSize )
    
    self.forcedWidthSize = forcedSize
end

function ButtonClass.forceHeightSize(self, forcedSize)
    self.forcedHeightSize = forcedSize
end

function ButtonClass.availableTextSize(self)
    if self.forcedWidthSize == nil then
        return #self.text
    end
    return self.forcedWidthSize - (self.margin * 2)
end

function ButtonClass.onResumeAfterContextLost(self)
    -- nothing to do!
end

function ButtonClass.executeMainAction(self)
    self.func(self)
end

function ButtonClass:setOnAskForNewData(func)
    self.onAskForNewData = func
end

function ButtonClass:handleRefreshDataEvent()
    -- ask data handler for new data

    -- refresh is not setup
    if not self.onAskForNewData then
        return
    end 
    local Data = self.onAskForNewData(self)

    if self:getText() == Data then
        return
    end

    self:setText(Data)
    self:askForRedraw()

end

return ButtonClass


