local ToggleableButtonClass = require("GUI.ToggleableButtonClass")
local CustomPaintUtils = require("UTIL.customPaintUtils")
local logger = require("UTIL.logger")
local PageStackClass = require("GUI.PageStackClass")
local PageClass      = require("GUI.PageClass")
local LabelClass     = require("GUI.LabelClass")
local stringUtils    = require("UTIL.stringUtils")

local DEFAULT_X_SIZE = 20
local DEFAULT_Y_SIZE = 20
local DEFAULT_ELEMENT_BACK_COLOR = colors.gray
local DEFAULT_TEXT_COLOR = colors.black

local function DEFAULT_TABLE_VALUE_DISPLAYED( value)
    return("{...}")
end

local TableClass = {}
TableClass.__index = TableClass
setmetatable(TableClass, { __index = PageClass })

function TableClass:new( monitor, x, y, title, sizeX, sizeY, document)
    self = setmetatable(PageClass:new(monitor,x,y, document), TableClass)
    self.title =title
    self.isScrollable = true
    self.sizeX = sizeX or DEFAULT_X_SIZE
    self.sizeY = sizeY or DEFAULT_Y_SIZE
    self.internalData = {}
    self.tableElements = {}
    self.margin = 1
    self.buttonMargin = 1
    self.marginBetweenColumns = 1
    self.marginBetweenRows = 1
    self.elementBackColor = DEFAULT_ELEMENT_BACK_COLOR
    self.textColor = DEFAULT_TEXT_COLOR
    self.shouldShowColumnTitles = true
    self.keyTitle = "Keys"
    self.valueTitle = "Values"
    self.keyRowProportion = 0.3
    self.scrollButtons = {}
    self.refreshButton = nil
    self.titleElement = nil
    self.scrollAmount = nil
    self.currentScroll = 0
    self.getValueToDisplayForTableCallback = DEFAULT_TABLE_VALUE_DISPLAYED
    self.displayKey = false
    self.areButtonsDirty = true
    self.rowHeight = 3
    self.hasManualRefresh = false
    self.columnCount = 1
    self.onTableElementPressedCallback = nil
    self.onTableElementDrawnCallback = nil
    self.onAskForNewDataCallback = nil
    self.onPostRefreshDataCallback = nil
    self.type = "table"
    self.tableElementProperties = {}

    -- sets default scroll amount
    self:setScrollAmount()
    return self
  end

function TableClass:__tostring() 
    return stringUtils.Format("[Table %(id), Title:%(title), nElements:%(nelements), Position:%(position), Size:%(size) ]",
                              {id = self.id,
                              title = stringUtils.Truncate(tostring(self.title),20),
                              nelements = #self.elements,
                              position = (stringUtils.CoordToString(self.x, self.y)),
                              size = (stringUtils.CoordToString(self:getSize()))})
   
end

function TableClass:setTableElementsProperties(properties)
    self.tableElementProperties = properties or {}
end

function TableClass:changeStyle(backColor, elementBackColor, textColor)
    self.backColor = backColor or self.backColor
    self.elementBackColor = elementBackColor or self.elementBackColor
    self.textColor = textColor or self.textColor
    self.areButtonsDirty = true
    self:setElementDirty()

end

function TableClass:getColumnCount()
    return self.columnCount
end

function TableClass:setColumnCount(columnCount)
    self.columnCount = columnCount or 1
    self.areButtonsDirty = true;
    self:setElementDirty()
end


function TableClass:setTableValueDisplayed(func)
    self.getValueToDisplayForTableCallback = func or DEFAULT_TABLE_VALUE_DISPLAYED
end

function TableClass:setScrollAmount(amount) 
    if not amount then
        self.scrollAmount = self:getRowHeight() + self.marginBetweenRows
    else
        self.scrollAmount = amount
    end
    self:setElementDirty()
end

function TableClass:setOnTableElementPressedCallback(func)
    
    self.onTableElementPressedCallback = func
    self.areButtonsDirty = true
end

function TableClass:setOnTableElementDrawnCallback(func)
    self.onTableElementDrawnCallback = func
    self.areButtonsDirty = true
end

function TableClass:setRowHeight(rowHeight)
   self.rowHeight = rowHeight 
   self.areButtonsDirty = true
   self:setElementDirty()
end

function TableClass:updateButtonsForScroll()
    if not self.isScrollable then
        return
    end
    self:doForEachTableElement(
        function (button, isKey, position)
            local x,y = self:getElementStart(position, isKey)
            button:setUpperCornerPos(x,y + self.currentScroll)
        end
        )
end

function TableClass:createElementButtons()
    local index = 1
    for key, value in pairs(self.internalData) do
        self:createTableElementsForRow(key, value, index)
        index = index + 1
    end
end

function TableClass:createButtonsForTable()

    self.elements = {}
    self.tableElements = {}
    self.scrollButtons = {}
    self:createElementButtons()

    local startX, startY, endX, endY = self:getArea()
    if (self.isScrollable) then

        local Up = ToggleableButtonClass:new(endX,endY-1, "U", self.document)
        Up:setMargin(0)

        local Down = ToggleableButtonClass:new(endX, endY, "D", self.document)
        Down:setMargin(0)

        Up:changeStyle(nil, self.backColor)
        Down:changeStyle(nil, self.backColor)

        self.scrollButtons.Up = Up
        self.scrollButtons.Down= Down
        self:addElement(Up)
        self:addElement(Down)

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

        self:updateButtonsForScroll()

    end
    if (self.hasManualRefresh) then     
        local RefreshButton = ToggleableButtonClass:new(startX,startY, "R", self.document)
        RefreshButton:setMargin(0)
        RefreshButton:changeStyle(nil, self.backColor)
        self:addElement(RefreshButton)
        RefreshButton:setOnManualToggle(            
            (function(button) 
            self:refreshData()
            end)
        )
        if self.refreshButton then
            RefreshButton.toggled = self.refreshButton.toggled
            RefreshButton.toggledTimer = self.refreshButton.toggledTimer
        end
        self.refreshButton = RefreshButton
    end

    if self.title then
        local titleStartX, titleStartY = self:getTitleArea()
        self.titleElement = LabelClass:new(titleStartX,titleStartY,self.title, self.document)
        self.titleElement:setMargin(0)
        self.titleElement:setTextColor(colors.black)
        self.titleElement:setBackColor(self.backColor)
        self:addElement(self.titleElement)
    end

    self.areButtonsDirty = false;
    self:setElementDirty()
end

function TableClass:createScrollButtons()
    local Up = ToggleableButtonClass:new(1,1, "U")
    Up:setMargin(0)

    local Down = ToggleableButtonClass:new(1, 1, "D")
    Down:setMargin(0)
   
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

    self.scrollButtons.Up = Up
    self.scrollButtons.Down= Down
    self:addElement(Up)
    self:addElement(Down)
end

function TableClass:updateScrollButtons()
    if self.isScrollable then
        if (not self.scrollButtons.Up or not self.scrollButtons.Down) then
            self:createScrollButtons()
        end
        
        self.scrollButtons.Up:changeStyle(nil, self.backColor)
        self.scrollButtons.Down:changeStyle(nil, self.backColor)

        local _, _, endX, endY = self:getArea()
        self.scrollButtons.Up:setPos(endX,endY-1)
        self.scrollButtons.Down:setPos(endX, endY)

    else
        if (self.scrollButtons.Up) then
            self:removeElement(self.scrollButtons.Up)
            self.scrollButtons.Up = nil
        end
        if (self.scrollButtons.Down) then
            self:removeElement(self.scrollButtons.Down)
            self.scrollButtons.Down = nil 
        end
    
    end
end


function TableClass:scroll(isUp)
    self.document:startEdition()
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

   
    local maxScroll = (self:getRowCount() - 1) * (self:getRowHeight() + self.marginBetweenRows) * -1

    if (scrollGoal < maxScroll) then
        realScroll = maxScroll
    end

    local realMovement = realScroll - self.currentScroll
    self.currentScroll = self.currentScroll + realMovement
    self:updateButtonsForScroll()
    self:setElementDirty()
    self.document:registerCurrentAreaAsDirty(self)
    self.document:endEdition()
end



function TableClass:setOnTableElementPressedCallbackForElement(element, key, isKey, position, data)
    local  wrapper =
        function()
            self.onTableElementPressedCallback(position, isKey,key, data)
        end 

    if self.onTableElementPressedCallback then
        element:setOnManualToggle(wrapper)
        return true
    end
    return false
end

function TableClass:setOnTableElementDrawnCallbackForElement(element, key, isKey, position, data)
    local wrapper =
        function()
            self.onTableElementDrawnCallback(position, isKey, key, data, element)
        end
    if self.onDrawButton then
        element:setOnDrawCallback(wrapper)
        return true
    end
    return false
end

function TableClass:getDefaultOnTableElementPressedCallback()
    return function()
        -- check if table is in a pagestack
        if not self.parentPage.pushPage then
            return
        end
        local InnerTablePage = TableClass:new(self.monitor, nil, nil, nil)
        InnerTablePage:setInternalTable(nil)
        InnerTablePage:setTableValueDisplayed(self.getValueToDisplayForTableCallback)
        self.parentPage:pushPage(InnerTablePage)    
    end
end

function TableClass:processTableElement(elementButton, key, value, position)

    if self:setOnTableElementPressedCallbackForElement(elementButton,key, false, position, value ) then
        return
    end

    elementButton:setOnManualToggle(self:getDefaultOnTableElementPressedCallback())
end

function TableClass:getStringToDisplayForElement(data, isKey, position)

    if isKey then
        -- nothing special to do for key
        return data
    else
        local typeOfData = type(data)
        local stringToDisplay = data
        if (typeOfData == "function") then
            stringToDisplay = "function"
        elseif (typeOfData == "table")  then
            stringToDisplay = self.getValueToDisplayForTableCallback(data)
        elseif (typeOfData == "boolean" or typeOfData == "number") then
            stringToDisplay = tostring(data)
        end
        return stringToDisplay
    end
end

function TableClass:getTableElementStyleAccordingToData(isKey, position)
    -- return elementBackColor, elementTextColor

    -- always default 
    return nil,nil
end

function TableClass:updateElementStyleAccordingToData(tableElement, isKey, position)
    -- check if style was overriden
    local elementBackColor, elementTextColor = self:getTableElementStyleAccordingToData(isKey, position)
    if not elementBackColor then
        elementBackColor = self.elementBackColor
    end

    if not elementTextColor then
        elementTextColor = self.textColor
    end

    tableElement:changeStyle(elementTextColor, elementBackColor)

end

function TableClass:createTableElementsForRow(key, value, position)

    local keyX,keyY = self:getElementStart(position, true)
    local valueX, valueY = self:getElementStart(position, false)

    local keyElement
    if self.displayKey then
        local keyStringToDisplay = self:getStringToDisplayForElement(key, true, position)
        keyElement = ToggleableButtonClass:new(0, 0, keyStringToDisplay, self.document)
        self:updateElementStyleAccordingToData(keyElement,true, position)
        keyElement:setUpperCornerPos(keyX,keyY)
        keyElement:forceWidthSize(self:getKeyRowWidth())
        keyElement:forceHeightSize(self:getRowHeight())
        keyElement:setLimit(self:getAreaForElements())
        keyElement:setProperties(self.tableElementProperties)
        self:addElement(keyElement)
        self:setOnTableElementPressedCallbackForElement(keyElement, key, true, position, key)
        self:setupOnDrawButton(keyElement, key, true, position, key)
    end
    local typeOfValue = type(value)
    local displayedText = self:getStringToDisplayForElement(value, false, position)
    
    
    local valueElement = ToggleableButtonClass:new(0, 0, displayedText, self.document)
    if (typeOfValue == "table")  then    
        self:processTableElement(valueElement, key, value , position)
    end
    self:updateElementStyleAccordingToData(valueElement, false, position)
    self:addElement(valueElement)
    valueElement:setUpperCornerPos(valueX,valueY)
    valueElement:forceWidthSize(self:getValueRowWidth())
    valueElement:forceHeightSize(self:getRowHeight())
    valueElement:setLimit(self:getAreaForElements())
    valueElement:setProperties(self.tableElementProperties)
    self:setOnTableElementPressedCallbackForElement( valueElement, key, false, position, value)
    self:setupOnDrawButton(valueElement,key, false, position, value)

    self.tableElements[key] = {keyButton = keyElement, valueButton = valueElement}
    return keyElement, valueElement
end


function TableClass:getElementStart(position, isKey)

    -- get column and row for element
    local row = math.floor((position - 1) / self:getColumnCount()) + 1
    local column = (position - 1) % self:getColumnCount() + 1

    -- get position of key column
    local firstElementX, firstElementY = self:getAreaForElements()
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

function TableClass:setKeyRowPropertion(proportion)
    assert(proportion > 0)
    assert(proportion <= 1)
    self.keyRowProportion = proportion or 0.3
end

function TableClass:getValueRowWidth()
    if (not self.displayKey) then
        return self:getKeyColomnWidth()
    end
    return self:getKeyColomnWidth() - self.marginBetweenColumns - self:getKeyRowWidth()
end

-- Getter/setter for the monitor
function TableClass:setMonitor(monitor)
  PageClass.setMonitor(self,monitor)
  self.areButtonsDirty = true;
end

-- Getter/setter for the page
function TableClass:setParentPage(parentPage)
  PageClass.setParentPage(self,parentPage)
  self.areButtonsDirty = true;
end

-- Getter for isScrollable
function TableClass:getIsScrollable()
    return self.isScrollable
  end
  
  -- Setter for isScrollable
function TableClass:setIsScrollable(value)
    self.isScrollable = value
    self.areButtonsDirty = true;
    self:setElementDirty()
end

function TableClass:setHasManualRefresh(value)
    self.hasManualRefresh = value
    self.areButtonsDirty = true;
    self:setElementDirty()
end

-- Getter/setter for the internal table
function TableClass:setInternalTable(internalData)
    self.internalData = internalData
    self.areButtonsDirty = true;
    self:setElementDirty()
end

function TableClass:setDisplayKey(displayKey)
    self.displayKey = displayKey
    self.areButtonsDirty = true;
    self:setElementDirty()
end

function TableClass:getInternalTable()
  return self.internalData
end

function TableClass:getRowCount()
    return #self.internalData
end

-- Area where you can draw elements
function TableClass:getAreaForElements()
    local startX, startY, endX, endY, sizeX, sizeY = self:getArea()
    local titleOffset = 0
    if self.title then
        titleOffset = 1
    end
    return startX + self.margin, startY + self.margin + titleOffset, endX - self.margin, endY - self.margin, sizeX - self.margin*2, sizeY - self.margin*2
end

function TableClass:getTitleArea()
    -- get drawableArea 

    local startX, startY, endX, endY, sizeX,sizeY = self:getAreaForElements()
    --title is always over drawableArea and 1 high
    return startX, startY - 1, endX, startY-1, sizeX, 1
end

-- function should be (button, isKey, position, ... (func arguments))
function TableClass:doForEachTableElement(func, ...)
       
    local position = 1   

    for key, elementButtons in pairs(self.tableElements) do
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

function TableClass:setOnAskForNewData(func)
    self.onAskForNewData = func
end

function TableClass:handleRefreshDataEvent()
    self:refreshData()
end

function TableClass:onPostRefreshData()
    if self.onPostRefreshDataCallback then
        self.onPostRefreshDataCallback(self)
    end
end

function TableClass:setOnPostRefreshDataCallback( callback )
    self.onPostRefreshDataCallback = callback
end

function TableClass:refreshData()
    -- ask data handler for new data

    -- refresh is not setup
    if not self.onAskForNewData then
        return
    end 
    local NewInternalTable = self.onAskForNewData()

    -- nothing to do if table didn't change
    if (not NewInternalTable or NewInternalTable == self.internalData) then
        return
    end

    self:setInternalTable(NewInternalTable)
    self:onPostRefreshData()
end

function TableClass:internalDraw() 
    -- CreateButtons if needed
    if self.areButtonsDirty then
        self:createButtonsForTable()
    end

    PageClass.internalDraw(self)

end

function TableClass:handleTouchEvent(eventName, side, xPos, yPos)
    -- only question element if event is in area
    local elementIterator = nil

    local startX, startY, endX, endY = self:getAreaForElements()
    local xInside = xPos >= startX and xPos <= endX
    local yInside = yPos >= startY and yPos <= endY
    if xInside and yInside then
        elementIterator = self.allElementsIterator
    else
        elementIterator = self.nonTableElementsIterator
    end

    for element in elementIterator(self) do
        if element:handleEvent(eventName, side, xPos, yPos) then
            return true
        end
    end

    return false

end

function TableClass:setPos(x,y)
    PageClass.setPos(self, x,y)
    self.areButtonsDirty = true;
end

function TableClass:nonTableElementsIterator()

    local nonTableElements = {}
    if self.isScrollable then
        table.insert(nonTableElements, self.scrollButtons.Up)
        table.insert(nonTableElements, self.scrollButtons.Down)
    end
    if self.refreshButton then
        table.insert(nonTableElements, self.refreshButton)
    end

    local position = 1
    return function ()
        local button = nonTableElements[position]
        position = position + 1
        return button
    end
end

-- Return the TableClass
return TableClass