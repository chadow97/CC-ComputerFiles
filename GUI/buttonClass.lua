local logger = require("UTIL.logger")
local CustomPaintUtils = require("UTIL.customPaintUtils")
local IdGenerator = require("UTIL.IdGenerator")
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
                forcedWidthSize = nil
               }

  setmetatable(obj, ButtonClass_mt)
  return obj
end


function ButtonClass.askForRedraw(self)
    logger.logToFile("button" .. self.text .. "asked for redraw of page" .. self.page.title )
    self.page:askForRedraw(self) -- passing asker
end

function ButtonClass.setMonitor(self, monitor)
    
    self.monitor = monitor
end



-- Define a draw method for the ButtonClass
function ButtonClass.draw(self, startLimitX, startLimitY, endLimitX, endLimitY)
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

  


  self.monitor.setCursorPos(self.x, self.y)
  self.monitor.setTextColor(self.textColor)

  local textToWrite = self.text

  local firstLetter = math.max(1, startXToDraw - self.x + 1)
  local lastLetter = math.min(self:availableTextSize(), endXToDraw - self.x + 1)

  if (lastLetter - firstLetter < 0) then
    return
  end

  textToWrite = string.sub(textToWrite, firstLetter, lastLetter) 

  self.monitor.write(textToWrite)
end

function ButtonClass.handleTouchEvent(self, eventName, side, xPos, yPos)
    if self:isPosInButton(xPos, yPos) then
        self.func(self)
        return true
    end
    return false
end


function ButtonClass.handleEvent(self, eventName, ...)
    logger.logToFile("handling event" .. eventName .." in button" )
    if eventName == "monitor_touch" then
        return self:handleTouchEvent(eventName, ...)
    end

    return false
end

-- Define a getArea method for the ButtonClass
function ButtonClass.getArea(self)
    local startX = self.x - self.margin
    local startY = self.y - self.margin

    local sizeX  = self.forcedWidthSize or #self.text + (self.margin*2)
    local sizeY  = 1 + (self.margin*2)


    local endX = startX + sizeX - 1
    local endY = startY + sizeY - 1

    return startX, startY, endX, endY, sizeX, sizeY

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
    self:setTextColor(textColor)
    self:setBackColor(backColor)
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

function ButtonClass.availableTextSize(self)
    if self.forcedWidthSize == nil then
        return #self.text
    end
    return self.forcedWidthSize - (self.margin * 2)
end

return ButtonClass


