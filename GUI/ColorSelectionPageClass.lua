local logger                = require "UTIL.logger"
local CustomPageClass       = require "GUI.CustomPageClass"
local LabelClass            = require "GUI.LabelClass"
local PageClass             = require "GUI.pageClass"
local ToggleableButtonClass = require "GUI.ToggleableButtonClass"

-- Define constants

local COLOR_WIDTH = 4
local COLOR_HEIGHT = 4
local COLOR_MARGIN = 1


-- Define the RessourcePage Class 
---@class ColorSelectionPage: CustomPage
local ColorSelectionPageClass = {}
ColorSelectionPageClass.__index = ColorSelectionPageClass
setmetatable(ColorSelectionPageClass, {__index = CustomPageClass})

function ColorSelectionPageClass:new(monitor, parentPage, document, title, startingColor)
  ---@class ColorSelectionPage: CustomPage
  local instance = setmetatable(CustomPageClass:new(monitor, parentPage, document, "Configuration"), ColorSelectionPageClass)
  instance.title = title
  instance.selectedColor = startingColor
  instance.colorLabelMap = {}

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
    local borderPageSizeY = 30
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
    self.smallPage:applyDocumentStyle()
    self.borderPage:addElement(self.smallPage)

    local yValueForEntry = smallPagePosY + 1
    --Title
    self.titleLabel = LabelClass:new(nil, nil, self.title , self.document)
    self.titleLabel:forceWidthSize(smallPageSizeX - 2)
    self.titleLabel:setUpperCornerPos(smallPagePosX + 1, yValueForEntry)
    self.titleLabel:applyDocumentStyle()
    self.titleLabel:setCenterText(true)
    self.smallPage:addElement(self.titleLabel)
  
    yValueForEntry = yValueForEntry + 4
    self.colorLabel = LabelClass:new(nil, nil, "" , self.document)
    self.colorLabel:forceWidthSize(smallPageSizeX - 2)
    self.colorLabel:forceHeightSize(3)
    self.colorLabel:setUpperCornerPos(smallPagePosX + 1, yValueForEntry)
    self:updateColorLabel()
    self.smallPage:addElement(self.colorLabel)

     yValueForEntry = yValueForEntry + 4

    yValueForEntry = self:createColorGrid(smallPagePosX + 1, yValueForEntry, smallPageSizeX - 2) + 2


    self.confirmButton = ToggleableButtonClass:new(nil, nil, "Confirm", self.document)
    self.confirmButton:applyDocumentStyle()
    self.confirmButton:setUpperCornerPos(smallPagePosX + 1, yValueForEntry - 1)
    self.confirmButton:setOnManualToggle(self:getOnConfirmPressed())
    self.confirmButton:setCenterText(true)
    self.confirmButton:forceWidthSize(smallPageSizeX - 2)
    self.smallPage:addElement(self.confirmButton)

end

function ColorSelectionPageClass:createColorGrid(xPos, yPos, width)
    local startingXpos = xPos
    local xOffset = 0
    local xJump = COLOR_WIDTH + COLOR_MARGIN
    local yJump = COLOR_HEIGHT + COLOR_MARGIN
    for _, color in pairs(colors) do
        if type(color) == "number" then
            self:createColorLabel(startingXpos + xOffset, yPos, color)
            xOffset = xOffset + xJump
            if (xOffset + COLOR_WIDTH)> width then
                xOffset = 0
                yPos = yPos + yJump
            end           
        end

    end
    return (yPos + COLOR_HEIGHT)
end

function ColorSelectionPageClass:createColorLabel(xPos, yPos, color)
    local currentColorLabel = ToggleableButtonClass:new(nil, nil, "", self.document)
    currentColorLabel:setMargin(0)
    currentColorLabel:setUpperCornerPos(xPos, yPos)
    currentColorLabel:forceHeightSize(COLOR_HEIGHT)
    currentColorLabel:forceWidthSize(COLOR_WIDTH)
    currentColorLabel:changeStyle(nil, color, nil, colors.black)
    currentColorLabel:setOnManualToggle(self:getOnColorPressed(color))
    self.smallPage:addElement(currentColorLabel)

    self.colorLabelMap[color] = currentColorLabel

end

function ColorSelectionPageClass:getOnColorPressed(color)
    return function ()
        self.selectedColor = color
        self:updateColorLabel()
    end
end

function ColorSelectionPageClass:updateColorLabel()
    self.document:startEdition()
    self.colorLabel:setBackColor(self.selectedColor)
    self.document:registerCurrentAreaAsDirty(self.colorLabel)
    self.document:endEdition()
end

function ColorSelectionPageClass:getOnConfirmPressed()
    return function()
        self.parentPage:popPage(self.selectedColor)
    end
end

return ColorSelectionPageClass