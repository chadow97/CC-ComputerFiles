local logger                = require "UTIL.logger"
local CustomPageClass       = require "GUI.CustomPageClass"
local LabelClass            = require "GUI.LabelClass"
local PageClass             = require "GUI.pageClass"
local ToggleableButtonClass = require "GUI.ToggleableButtonClass"

-- Define constants
local ELEMENT_BACK_COLOR = colors.red
local INNER_ELEMENT_BACK_COLOR = colors.lime
local TEXT_COLOR = colors.yellow


-- Define the RessourcePage Class 
local NumberSelectionPageClass = {}
NumberSelectionPageClass.__index = NumberSelectionPageClass
setmetatable(NumberSelectionPageClass, {__index = CustomPageClass})

function NumberSelectionPageClass:new(monitor, parentPage, document, title, min, max)
  local instance = setmetatable(CustomPageClass:new(monitor, parentPage, document, "Configuration"), NumberSelectionPageClass)
  instance.title = title
  instance.min = min
  instance.max = max
  instance.inputContent = ""
  instance.maxDigitSize = nil

  instance:buildCustomPage()

  return instance
end

function NumberSelectionPageClass:__tostring() 
  return CustomPageClass.__tostring(self)
end

function NumberSelectionPageClass:onBuildCustomPage()
      
    local parentPageSizeX, parentPageSizeY = self.parentPage:getSize()
    local parentPagePosX, parentPagePosY = self.parentPage:getPos()

    self:setBackColor(nil)

    local borderPageSizeX = 35
    local borderPageSizeY = 35
    local borderPosX = math.floor((parentPageSizeX - borderPageSizeX)/2) + parentPagePosX
    local borderPosY = math.floor((parentPageSizeY - borderPageSizeY)/2) + parentPagePosY

    self.borderPage = PageClass:new(self.monitor,nil, nil, self.document)
    self.borderPage:setSize(borderPageSizeX, borderPageSizeY)
    self.borderPage:setPos(borderPosX, borderPosY)
    self.borderPage:setBackColor(colors.black)
    self:addElement(self.borderPage)

    local smallPageSizeX = borderPageSizeX - 2
    local smallPageSizeY = borderPageSizeY - 2
    local smallPagePosX = borderPosX + 1
    local smallPagePosY = borderPosY + 1

    self.smallPage = PageClass:new(self.monitor,nil, nil, self.document)
    self.smallPage:setSize(smallPageSizeX, smallPageSizeY)
    self.smallPage:setPos(smallPagePosX, smallPagePosY)
    self.smallPage:setBackColor(ELEMENT_BACK_COLOR)
    self.borderPage:addElement(self.smallPage)

    local yValueForEntry = smallPagePosY + 1
    --Title
    self.titleLabel = LabelClass:new(nil, nil, self.title , self.document)
    self.titleLabel:forceWidthSize(smallPageSizeX - 2)
    self.titleLabel:setUpperCornerPos(smallPagePosX + 1, yValueForEntry)
    self.titleLabel:changeStyle(TEXT_COLOR, INNER_ELEMENT_BACK_COLOR)
    self.titleLabel:setCenterText(true)
    self.smallPage:addElement(self.titleLabel)
  
    yValueForEntry = yValueForEntry + 4
    self.inputLabel = LabelClass:new(nil, nil, "" , self.document)
    self.maxDigitSize = smallPageSizeX - 2 - 2
    self.inputLabel:forceWidthSize(smallPageSizeX - 2)
    self.inputLabel:setUpperCornerPos(smallPagePosX + 1, yValueForEntry)
    self.inputLabel:changeStyle(colors.black, colors.white)
    self.inputLabel:setCenterText(false)
    self.inputLabel:forceHeightSize(3)
    self.smallPage:addElement(self.inputLabel)
     yValueForEntry = yValueForEntry + 4

    local leftMarginForGrid = (smallPageSizeX - 11)/2

    self:createGrid(smallPagePosX + leftMarginForGrid, yValueForEntry)

    yValueForEntry = yValueForEntry + 4*4

    self.confirmButton = ToggleableButtonClass:new(nil, nil, "Confirm", self.document)
    self.confirmButton:changeStyle(TEXT_COLOR, INNER_ELEMENT_BACK_COLOR)
    self.confirmButton:setUpperCornerPos(smallPagePosX + 1, yValueForEntry)
    self.confirmButton:setOnManualToggle(self:getOnConfirmPressed())
    self.confirmButton:setCenterText(true)
    self.confirmButton:forceWidthSize(smallPageSizeX - 2)
    self.smallPage:addElement(self.confirmButton)

    yValueForEntry = yValueForEntry + 4

    self.minMaxInfo = LabelClass:new(nil, nil, string.format("Min:%s/Max:%s",self.min, self.max) , self.document)
    self.minMaxInfo:changeStyle(TEXT_COLOR, INNER_ELEMENT_BACK_COLOR)
    self.minMaxInfo:setUpperCornerPos(smallPagePosX + 1, yValueForEntry)
    self.minMaxInfo:setCenterText(true)
    self.minMaxInfo:forceWidthSize(smallPageSizeX - 2)
    self.smallPage:addElement(self.minMaxInfo)
end

function NumberSelectionPageClass:createGrid(startXPos, startYPos)
    self.digits = {}
    for y = 1,3 do
       for x= 1,3 do
        local digit = NumberSelectionPageClass.getDigitFromPosition(x,y)
        local xPos = startXPos + (x-1)*4 + 1
        local yPos = startYPos + (y-1)*4 + 1
        self.digits[digit] =self:createGridButton(xPos, yPos, digit, self:getOnDigitPressed(digit))
       end 
    end
    local yPos = startYPos + 3*4 + 1

    local xPos = startXPos + 1
    self.removeButton = self:createGridButton(xPos,yPos, "<", self:getOnRemovePressed())

    xPos = xPos + 4
    self.digits[0] = self:createGridButton(xPos, yPos, 0, self:getOnDigitPressed(0))

    xPos = xPos + 4
    self.clearButton = self:createGridButton(xPos, yPos, "C", self:getOnClearPressed())
end

function NumberSelectionPageClass:createGridButton(xPos, yPos, symbol, onPress)
    local digitButton = ToggleableButtonClass:new(xPos, yPos, tostring(symbol), self.document)
    digitButton:changeStyle(TEXT_COLOR, INNER_ELEMENT_BACK_COLOR)
    digitButton:setOnManualToggle(onPress)
    self.smallPage:addElement(digitButton)
    return digitButton
end

function NumberSelectionPageClass.getDigitFromPosition(x,y)
    return x + 3*(3-y)
end

function NumberSelectionPageClass:getOnDigitPressed(digit)
    return function ()
        local targetDisplay =  self.inputContent .. tostring(digit)
        local targetNumber = tonumber(targetDisplay)
        logger.logToFile("maxdigitsize: " .. self.maxDigitSize)
        if #targetDisplay > self.maxDigitSize then
            return
        end
        self.document:startEdition()
        self.inputContent = tostring(targetNumber)
        self.inputLabel:setText(self.inputContent) 
        self.document:registerCurrentAreaAsDirty(self.inputLabel)
        self.document:endEdition() 
    end
end

function NumberSelectionPageClass:getOnClearPressed()
    return function()
        self.document:startEdition()
        self.inputContent = ""
        self.inputLabel:setText(self.inputContent) 
        self.document:registerCurrentAreaAsDirty(self.inputLabel)
        self.document:endEdition()
    end
end

function NumberSelectionPageClass:getOnRemovePressed()
    return function()
        if #self.inputContent <= 0 then
            return
        end
        self.document:startEdition()
        self.inputContent = string.sub(self.inputContent, 1, -2)
        self.inputLabel:setText(self.inputContent) 
        self.document:registerCurrentAreaAsDirty(self.inputLabel)
        self.document:endEdition() 
    end
end

function NumberSelectionPageClass:getOnConfirmPressed()
    return function()
        local currentNumber = tonumber(self.inputContent)
        if currentNumber > self.max or currentNumber < self.min then
            return
        end
        self.parentPage:popPage(currentNumber)
    end
end

return NumberSelectionPageClass