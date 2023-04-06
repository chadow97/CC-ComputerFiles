local ToggleableButtonClass = require("GUI.toggleableButtonClass")
local CustomPaintUtils = require("UTIL.customPaintUtils")
local logger = require("UTIL.logger")


-- Define the TableClass
local TableClass = {}
local TableClass_mt = { __index = TableClass }

local defaultSizeX = 20
local defaultSizeY = 20
function TableClass:new( posX, posY, title, sizeX, sizeY)
    local properties = {
      monitor = nil,
      page = nil,
      internalTable = {},
      title = title,
      isScrollable = true,
      posX = posX or 1,
      posY = posY or 1,
      sizeX = sizeX or defaultSizeX,
      sizeY = sizeY or defaultSizeY,
      margin = 1,
      buttonMargin = 1,
      marginBetweenColumns = 1,
      marginBetweenRows = 1,
      backColor = colors.lightGray,
      elementBackColor = colors.gray,
      textColor = colors.black,
      shouldShowColumnTitles = true,
      keyTitle = "Keys",
      valueTitle = "Values",
      keyRowProportion = 0.3,
      internalButtonHolder = {},
      scrollButtons = {}
    }


    setmetatable(properties, TableClass_mt)
    return properties
  end

function TableClass:createButtonsForTable()
    self.internalButtonHolder = {}
    self.scrollButtons = {}

    local index = 1


    for key, value in pairs(self.internalTable) do
        self:createButtonsForRow(key, value, index)
        index = index + 1
    end

    if (self.isScrollable) then
        local startX, startY, endX, endY = self:getArea()


        local Up = ToggleableButtonClass:new(endX,endY-1, "U")
        Up:setMargin(0)
        local Down = ToggleableButtonClass:new(endX, endY, "D")
        Down:setMargin(0)
        self.scrollButtons[Up] = Up
        self.scrollButtons[Down]= Down
        Up:setPage(self)
        Down:setPage(self)




    end
    

    self:setMonitorForAll()


end

function TableClass:createButtonsForRow(key, value, position)

    local keyX,keyY = self:getElementStart(position, true)
    local valueX, valueY = self:getElementStart(position, false)

    local keyButton = ToggleableButtonClass:new(0, 0, key)
    keyButton:changeStyle(self.elementBackColor, self.textColor)
    keyButton:setPage(self)
    keyButton:setUpperCornerPos(keyX,keyY)
    keyButton:forceWidthSize(self:getKeyRowWidth())
    local valueButton = ToggleableButtonClass:new(0, 0, value)
    valueButton:changeStyle(self.elementBackColor, self.textColor)
    valueButton:setPage(self)
    valueButton:setUpperCornerPos(valueX,valueY)
    valueButton:forceWidthSize(self:getValueRowWidth())

    self.internalButtonHolder[key] = {keyButton = keyButton, valueButton = valueButton}
end

function TableClass:getElementStart(position, isKey)

    local elementX = self.posX + self.margin
    if not isKey then
        elementX = elementX + self:getKeyRowWidth() + self.marginBetweenColumns 
    end
    local elementY = self.posY + ((position - 1)* (self:getRowHeight() +self.marginBetweenRows)) + self.margin 

    return elementX,elementY
end

function TableClass:getRowHeight()
    return 1 + (2* self.buttonMargin)
end

function TableClass:getKeyRowWidth()
    return math.floor((self.sizeX - self.marginBetweenColumns - (self.margin * 2))* self.keyRowProportion)
end

function TableClass:getValueRowWidth()
    return self.sizeX - self:getKeyRowWidth() - self.marginBetweenColumns - (self.margin * 2)
end

-- Getter/setter for the monitor
function TableClass:setMonitor(monitor)  
  self.monitor = monitor
  self:setMonitorForAll()
end

function TableClass:getMonitor()
  return self.monitor
end

-- Getter/setter for the page
function TableClass:setPage(page)
  self.page = page
end

function TableClass:getPage()
  return self.page
end

-- Getter for isScrollable
function TableClass:getIsScrollable()
    return self.isScrollable
  end
  
  -- Setter for isScrollable
function TableClass:setIsScrollable(value)
    self.isScrollable = value
end

-- Getter/setter for the internal table
function TableClass:setInternalTable(internalTable)
    self.internalTable = internalTable
    self:createButtonsForTable()
end

function TableClass:getInternalTable()
  return self.internalTable
end


function TableClass:getArea()
    local endX = self.posX + self.sizeX - 1
    local endY = self.posY + self.sizeY - 1
    return self.posX, self.posY, endX, endY, self.sizeX, self.sizeY
end

function TableClass:getDrawableArea()
    local startX, startY, endX, endY, sizeX, sizeY = self:getArea()
    return startX + self.margin, startY + self.margin, endX - self.margin, endY - self.margin, sizeX - self.margin*2, sizeY - self.margin*2
end

function TableClass:getSize()
    return self.sizeX, self.sizeY
end

-- function should be (button, isKey, position, ... (func arguments))
function TableClass:doForEachButton(func, ...)
       
    local position = 1    

    for key, elementButtons in pairs(self.internalButtonHolder) do
        local keyButton = elementButtons.keyButton
        local valueButton = elementButtons.valueButton
        -- call on key first
        func(keyButton, true, position, ...)
        func(valueButton, false, position, ...)
    end

end

-- function should be (button)
function TableClass:doForScrollButtons(func, ...)
    logger.log(self.scrollButtons)

    for key, button in pairs(self.scrollButtons) do
        func(button)
    end

end

function TableClass:doForAllButtonsInPage(...)
    self:doForEachButton(...)
    self:doForScrollButtons(...)
end


-- Empty implementation of the draw function
function TableClass:draw()
    -- 1st step: draw background
    local startX, startY, endX, endY = self:getArea()
    CustomPaintUtils.drawFilledBox(startX, startY, endX, endY,  self.backColor, self.monitor)
    -- 2nd step: draw buttons

    local drawElement = function(button) 
        button:draw(self:getDrawableArea())
    end
    self:doForEachButton(drawElement)

    local drawScrollButtons = function(button)
        button:draw()
    end

    self:doForScrollButtons(drawScrollButtons)
end

-- Empty implementation of the handleEvent function
function TableClass:handleEvent(...)
    local func = function(button, isKey, position, ...)
        button:handleEvent(...)
    end

    self:doForAllButtonsInPage(func, ...)
end

function TableClass:setMonitorForAll()
    local func = function(button) 
        button:setMonitor(self.monitor)
    end
    self:doForAllButtonsInPage(func)
end

-- Return the TableClass
return TableClass