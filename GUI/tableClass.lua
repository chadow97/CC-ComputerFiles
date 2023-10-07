local ToggleableButtonClass = require("GUI.toggleableButtonClass")
local CustomPaintUtils = require("UTIL.customPaintUtils")
local logger = require("UTIL.logger")
local PageStackClass = require("GUI.pageStackClass")


-- Define the TableClass
local TableClass = {}
local TableClass_mt = { __index = TableClass }

local defaultSizeX = 20
local defaultSizeY = 20

local function DefaultTableValueDisplayed( value)
    return("{...}")
end

function TableClass:new( monitor, posX, posY, title, sizeX, sizeY)
    local properties = {
      monitor = monitor,
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
      scrollButtons = {},
      refreshButton = nil,
      scrollAmount = nil,
      currentScroll = 0,
      tableValueDisplayed = DefaultTableValueDisplayed,
      displayKey = true,
      areButtonsDirty = true,
      rowHeight = 3,
      onPressFunc = nil,
      onDrawButton = nil,
      onAskForNewData = nil,
      columnCount = 1,
      hasManualRefresh = false
    }


    setmetatable(properties, TableClass_mt)
    -- sets default scroll amount
    properties:setScrollAmount()
    return properties
  end

function TableClass:changeStyle(backColor, elementBackColor, textColor)
    self.backColor = backColor or self.backColor
    self.elementBackColor = elementBackColor or self.elementBackColor
    self.textColor = textColor or self.textColor
    self.areButtonsDirty = true

end

function TableClass:getColumnCount()
    return self.columnCount
end

function TableClass:setColumnCount(columnCount)
    self.columnCount = columnCount or 1
    self.areButtonsDirty = true;
end


function TableClass:setTableValueDisplayed(func)
    self.tableValueDisplayed = func or DefaultTableValueDisplayed
end

function TableClass:setScrollAmount(amount) 
    if not amount then
        self.scrollAmount = self:getRowHeight() + self.marginBetweenRows
    else
        self.scrollAmount = amount
    end

end

function TableClass:setOnPressFunc(func)
    self.onPressFunc = func
    self.areButtonsDirty = true
end

function TableClass:setOnDrawButton(func)
    self.onDrawButton = func
    self.areButtonsDirty = true
end

function TableClass:setRowHeight(rowHeight)
   self.rowHeight = rowHeight 
   self.areButtonsDirty = true
end

local function updateButtonsForScroll(table)
    if not table.isScrollable then
        return
    end
    table:doForEachTableElement(
        function (button, isKey, position)
            local x,y = table:getElementStart(position, isKey)
            button:setUpperCornerPos(x,y + table.currentScroll)
        end
        )


end

function TableClass:createButtonsForTable()
    self.internalButtonHolder = {}
    self.scrollButtons = {}

    local index = 1

    for key, value in pairs(self.internalTable) do
        self:createButtonsForRow(key, value, index)
        index = index + 1
    end

    local startX, startY, endX, endY = self:getArea()
    if (self.isScrollable) then

        local Up = ToggleableButtonClass:new(endX,endY-1, "U")
        Up:setMargin(0)

        local Down = ToggleableButtonClass:new(endX, endY, "D")
        Down:setMargin(0)

        Up:changeStyle(nil, self.backColor)
        Down:changeStyle(nil, self.backColor)

        self.scrollButtons.Up = Up
        self.scrollButtons.Down= Down
        Up:setPage(self)
        Down:setPage(self)

        Up:setOnManualToggle(
            (function(button) 
                self:scroll(true)
            end)
        )
        Down:setOnManualToggle(
            (function(button) 
                self:scroll(false)
            end)
        )

        updateButtonsForScroll(self)

    end
    if (self.hasManualRefresh) then
        local RefreshButton = ToggleableButtonClass:new(startX,startY, "R")
        RefreshButton:setMargin(0)
        RefreshButton:changeStyle(nil, self.backColor)
        RefreshButton:setPage(self)
        RefreshButton:setOnManualToggle(            
            (function(button) 
            self:RefreshData()
            end)
        )
        self.refreshButton = RefreshButton
    end

    self:setMonitorForAll()
    self.areButtonsDirty = false;


end


function TableClass:scroll(isUp)
    if not self.isScrollable then
        return
    end
    
    local movement = self.scrollAmount
    if not isUp then
        movement = self.scrollAmount * -1
    end

    local scrollGoal = self.currentScroll + movement
    local realScroll = scrollGoal

    if (scrollGoal >= 0) then
        realScroll = 0
    end

   
    local maxScroll = (self:getInternalTableElementCount() - 1) * (self:getRowHeight() + self.marginBetweenRows) * -1

    if (scrollGoal < maxScroll) then
        realScroll = maxScroll
    end

    local realMovement = realScroll - self.currentScroll
    self.currentScroll = self.currentScroll + realMovement

    updateButtonsForScroll(self)
end



local function setupOnManualToggle(table, button, key, isKey, position, data)

    local  wrapper =
        function()
            table.onPressFunc(position, isKey,key, data)
        end 

    if table.onPressFunc then
        button:setOnManualToggle(wrapper)
        return true
    end
    return false
end

local function setupOnDrawButton(table, button, key, isKey, position, data)
    local wrapper = 
        function()
            table.onDrawButton(position, isKey, key, data, button)
        end
    if table.onDrawButton then
        button:setOnDraw(wrapper)
        return true
    end
    return false
end

local function processTableElement(tableClass, tableButton, key, value, position)

    if setupOnManualToggle(tableClass, tableButton,key, false, position, value ) then
        return
    end
    local func = function ()
        if not tableClass.page.pushPage then
            return
        end
        local InnerTablePage = TableClass:new(tableClass.monitor, nil, nil, key)
        InnerTablePage:setInternalTable(value)
        InnerTablePage:setTableValueDisplayed(tableClass.tableValueDisplayed)
        tableClass.page:pushPage(InnerTablePage)
    end


    tableButton:setOnManualToggle(func)

end

function TableClass:createButtonsForRow(key, value, position)

    local keyX,keyY = self:getElementStart(position, true)
    local valueX, valueY = self:getElementStart(position, false)

    local keyButton
    if self.displayKey then
        keyButton = ToggleableButtonClass:new(0, 0, key)
        keyButton:changeStyle(self.elementBackColor, self.textColor)
        keyButton:setPage(self)
        keyButton:setUpperCornerPos(keyX,keyY)
        keyButton:forceWidthSize(self:getKeyRowWidth())
        keyButton:forceHeightSize(self:getRowHeight())
        setupOnManualToggle( self, keyButton, key, true, position, key)
        setupOnDrawButton(self, keyButton, key, true, position, key)
    end
    local typeOfValue = type(value)
    local displayedText = value

    if (typeOfValue == "function") then
        displayedText = "function"
    elseif (typeOfValue == "table")  then
        displayedText = self.tableValueDisplayed(value)
    elseif (typeOfValue == "boolean" or typeOfValue == "number") then
        displayedText = tostring(value)
    end
    
    local valueButton = ToggleableButtonClass:new(0, 0, displayedText)
    if (typeOfValue == "table")  then    
        processTableElement(self, valueButton, key, value , position)
    end
    valueButton:changeStyle(self.elementBackColor, self.textColor)
    valueButton:setPage(self)
    valueButton:setUpperCornerPos(valueX,valueY)
    valueButton:forceWidthSize(self:getValueRowWidth())
    valueButton:forceHeightSize(self:getRowHeight())
    setupOnManualToggle( self, valueButton, key, false, position, value)
    setupOnDrawButton(self, valueButton,key, false, position, value)

    self.internalButtonHolder[key] = {keyButton = keyButton, valueButton = valueButton}
end



function TableClass:getElementStart(position, isKey)

    -- get column and row for element
    local row = math.floor((position - 1) / self:getColumnCount()) + 1
    local column = (position - 1) % self:getColumnCount() + 1

    -- get position of key column
    local firstElementX, firstElementY = self:getDrawableArea()
    local elementY = firstElementY + ((row - 1) * (self:getRowHeight() +self.marginBetweenRows))
    local elementX = firstElementX + ((column - 1) * (self:getKeyColomnWidth() + self.marginBetweenColumns))

    -- offset if not key!
    if not isKey then
        elementX = elementX + self:getKeyRowWidth()
        if self.displayKey then
            elementX = elementX + self.marginBetweenColumns
        end
    end


    return elementX,elementY
end

function TableClass:getRowHeight()
    return self.rowHeight
end

function TableClass:getKeyColomnWidth()
    local marginBetweenKeyColumns = self.marginBetweenColumns * (self:getColumnCount() - 1)
    local outsideMargins = self.margin * 2
    local totalWidth = self.sizeX - outsideMargins
    if self.displayKey then
        totalWidth = totalWidth - marginBetweenKeyColumns
    end

    return math.floor(totalWidth/self:getColumnCount())
end

function TableClass:getKeyRowWidth()
    if (not self.displayKey) then
        return 0
    end
    return math.floor((self:getKeyColomnWidth() - self.marginBetweenColumns)* self.keyRowProportion)
end

function TableClass:getValueRowWidth()
    if (not self.displayKey) then
        return self:getKeyColomnWidth()
    end
    return self:getKeyColomnWidth() - self.marginBetweenColumns - self:getKeyRowWidth()
end

-- Getter/setter for the monitor
function TableClass:setMonitor(monitor)  
  self.monitor = monitor
  self:setMonitorForAll()
  self.areButtonsDirty = true;
end

function TableClass:getMonitor()
  return self.monitor
end

-- Getter/setter for the page
function TableClass:setPage(page)
  self.page = page
  self.areButtonsDirty = true;
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
    self.areButtonsDirty = true;
end

function TableClass:setHasManualRefresh(value)
    self.hasManualRefresh = value
    self.areButtonsDirty = true;
end

-- Getter/setter for the internal table
function TableClass:setInternalTable(internalTable)
    self.internalTable = internalTable
    self.areButtonsDirty = true;
end

function TableClass:setDisplayKey(displayKey)
    self.displayKey = displayKey
    self.areButtonsDirty = true;
end

function TableClass:getInternalTable()
  return self.internalTable
end

function TableClass:getInternalTableElementCount()
    local count = 0

    for key, value in pairs(self.internalTable) do
        count = count + 1
    end

    return count
end


function TableClass:getArea()
    local endX = self.posX + self.sizeX - 1
    local endY = self.posY + self.sizeY - 1
    return self.posX, self.posY, endX, endY, self.sizeX, self.sizeY
end

-- Area where you can draw buttons
function TableClass:getDrawableArea()
    local startX, startY, endX, endY, sizeX, sizeY = self:getArea()
    local titleOffset = 0
    if self.title then
        titleOffset = 1
    end
    return startX + self.margin, startY + self.margin + titleOffset, endX - self.margin, endY - self.margin, sizeX - self.margin*2, sizeY - self.margin*2
end

function TableClass:getSize()
    return self.sizeX, self.sizeY
end

function TableClass:getTitleArea()
    -- get drawableArea 

    local startX, startY, endX, endY, sizeX,sizeY = self:getDrawableArea()
    --title is always over drawableArea and 1 high
    return startX, startY - 1, endX, startY-1, sizeX, 1
end

-- function should be (button, isKey, position, ... (func arguments))
function TableClass:doForEachTableElement(func, ...)
       
    local position = 1   

    for key, elementButtons in pairs(self.internalButtonHolder) do
        local keyButton = elementButtons.keyButton
        local valueButton = elementButtons.valueButton
        -- call on key first
        if self.displayKey then
            func(keyButton, true, position, ...)
        end
        func(valueButton, false, position, ...)

        position = position + 1
    end

end

-- function should be (button, isKey, position, ...)
function TableClass:doForScrollButtons(func, ...)
    for key, button in pairs(self.scrollButtons) do
        func(button, nil, nil, ...)
    end

end

-- function should be (button, isKey, position, ...)
function TableClass:doForExtraButtons(func, ...)
    if self.refreshButton then
        func(self.refreshButton, nil, nil, ...)
    end

end

function TableClass:doForAllButtonsInPage(...)
    self:doForEachTableElement(...)
    self:doForScrollButtons(...)
    self:doForExtraButtons(...)
end

function TableClass:askForRedraw()
    -- if table has no parent, then we can draw, else we ask its parents to handle drawing.
    if self.page then
        self.page:askForRedraw(self) -- passing asker
    else
        self:draw()
    end


end

function TableClass:setOnAskForNewData(func)
    self.onAskForNewData = func
end

function TableClass:handleRefreshDataEvent()
    self:RefreshData()

end

function TableClass:RefreshData()
    -- ask data handler for new data

    -- refresh is not setup
    if not self.onAskForNewData then
        return
    end 
    local NewInternalTable = self.onAskForNewData()

    -- nothing to do if table didn't change
    if (not NewInternalTable or NewInternalTable == self.internalTable) then
        return
    end

    self:setInternalTable(NewInternalTable)
    self:askForRedraw()
end

function TableClass:draw()

    -- CreateButtons if needed

    if self.areButtonsDirty then
        self:createButtonsForTable()
    end

    -- 1st step: draw background
    local startX, startY, endX, endY = self:getArea()
    CustomPaintUtils.drawFilledBox(startX, startY, endX, endY,  self.backColor, self.monitor)

    -- 2nd step: draw title if needed
    local titleStartX, titleStartY = self:getTitleArea()
    self.monitor.setCursorPos(titleStartX, titleStartY)
    self.monitor.setTextColor(colors.black)
    if self.title then
        self.monitor.write(self.title)
    end

    -- 3rd step: draw table buttons

    local drawElement = function(button) 
        button:draw(self:getDrawableArea())
    end
    self:doForEachTableElement(drawElement)

    --4th step: draw srollbuttons

    local drawButtonFunction = function(button)
        button:draw()
    end

    self:doForScrollButtons(drawButtonFunction)
    self:doForExtraButtons(drawButtonFunction)
end

function TableClass:handleEvent(eventName, ...)
    if eventName == "refresh_data" then 
        return self:handleRefreshDataEvent()
    end

    for button in self:allButtons() do
        if button:handleEvent(eventName, ...) then
            return true
        end
    end
end

function TableClass:setPosition(posX,posY)
    self.posX = posX
    self.posY = posY
    self.areButtonsDirty = true;
end

function TableClass:setSize(sizeX,sizeY)
    self.sizeX = sizeX
    self.sizeY = sizeY
    self.areButtonsDirty = true;
end

function TableClass:allButtons()
    local buttonKeys = {}
    for key, _ in pairs(self.internalButtonHolder) do
        table.insert(buttonKeys, key)
    end

    local nonElementButtons = {}
    if self.isScrollable then
        table.insert(nonElementButtons, self.scrollButtons.Up)
        table.insert(nonElementButtons, self.scrollButtons.Down)
    end
    if self.hasManualRefresh then
        table.insert(nonElementButtons, self.refreshButton)
    end


    local position = 1
    local isKey = self.displayKey

    return function ()
        local button = nil
        if (position <= #buttonKeys) then
            local key = buttonKeys[position]
            if isKey then
                button = self.internalButtonHolder[key].keyButton
                isKey = false
            else
                button = self.internalButtonHolder[key].valueButton
                isKey = self.displayKey
                position = position + 1
            end
        else
            local nonElementPosition = position - #buttonKeys
            button = nonElementButtons[nonElementPosition]
            position = position + 1
        end

        return button
    end
end

function TableClass:setMonitorForAll()
    local func = function(button) 
        button:setMonitor(self.monitor)
    end
    self:doForAllButtonsInPage(func)
end

function TableClass:onResumeAfterContextLost()
    local func = function(button) 
        button:onResumeAfterContextLost()
    end

    self:doForAllButtonsInPage(func)
end

function TableClass:pressAllButtons()
    local toDoForAllButtons = 
        function(button)
            button:executeMainAction()
        end
    self:doForEachTableElement(toDoForAllButtons)
end


-- static function

function TableClass.createTableStack(monitor, posX, posY, sizeX,sizeY, table, tableName, displayTableFunction)

    local newTable = TableClass:new(monitor, 1,1, tableName)

    newTable:setTableValueDisplayed(displayTableFunction)
    newTable:setInternalTable(table)
    
    local tableStack = PageStackClass:new(monitor)
    tableStack:setSize(sizeX,sizeY)
    tableStack:setPosition( posX,posY)
    tableStack:pushPage(newTable)

    return tableStack, newTable
end

-- Return the TableClass
return TableClass