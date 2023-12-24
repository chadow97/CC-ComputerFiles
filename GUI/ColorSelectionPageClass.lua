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
local ColorSelectionPageClass = {}
ColorSelectionPageClass.__index = ColorSelectionPageClass
setmetatable(ColorSelectionPageClass, {__index = CustomPageClass})

function ColorSelectionPageClass:new(monitor, parentPage, document, title, startingColor)
  local instance = setmetatable(CustomPageClass:new(monitor, parentPage, document, "Configuration"), ColorSelectionPageClass)
  instance.title = title
  instance.selectedColor = startingColor

  instance:buildCustomPage()

  return instance
end

function ColorSelectionPageClass:__tostring() 
  return CustomPageClass.__tostring(self)
end

function ColorSelectionPageClass:onBuildCustomPage()
      
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


    self.confirmButton = ToggleableButtonClass:new(nil, nil, "Confirm", self.document)
    self.confirmButton:changeStyle(TEXT_COLOR, INNER_ELEMENT_BACK_COLOR)
    self.confirmButton:setUpperCornerPos(smallPagePosX + 1, yValueForEntry)
    self.confirmButton:setOnManualToggle(self:getOnConfirmPressed())
    self.confirmButton:setCenterText(true)
    self.confirmButton:forceWidthSize(smallPageSizeX - 2)
    self.smallPage:addElement(self.confirmButton)

end

function ColorSelectionPageClass:getOnConfirmPressed()
    return function()
        local currentNumber = tonumber(self.inputContent)
        if currentNumber > self.max or currentNumber < self.min then
            return
        end
        self.parentPage:popPage(currentNumber)
    end
end

return ColorSelectionPageClass