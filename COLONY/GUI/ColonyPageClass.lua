local CustomPageClass       = require "GUI.customPageClass"
local ColonyManagerClass    = require "MODEL.colonyManagerClass"
local LabelClass            = require "GUI.labelClass"
local stringUtils           = require "UTIL.stringUtils"

-- Define constants

local ELEMENT_BACK_COLOR = colors.red
local INNER_ELEMENT_BACK_COLOR = colors.lime
local TEXT_COLOR = colors.yellow

-- Define the RessourcePage Class 
local ColonyPageClass = {}
ColonyPageClass.__index = ColonyPageClass
setmetatable(ColonyPageClass, {__index = CustomPageClass})



function ColonyPageClass:new(monitor, parentPage, document)
  self = setmetatable(CustomPageClass:new(monitor, parentPage, document, "ColonyPage"), ColonyPageClass)
  self.descLabel = nil
  self.titleLabel = nil
  self.colonyMgr = nil

  self:buildCustomPage()
  return self
end

function ColonyPageClass:onBuildCustomPage()
    self.colonyMgr = self.document:getManagerForType(ColonyManagerClass.TYPE)
    local colony = self.colonyMgr:getColony()

    local parentPageSizeX, parentPageSizeY = self.parentPage:getSize()
    local parentPagePosX, parentPagePosY = self.parentPage:getPos()
    --  x, y, text, document
    self.titleLabel = LabelClass:new(nil, nil, "" , self.document)
    self.titleLabel:forceWidthSize(parentPageSizeX - 2)
    self.titleLabel:setUpperCornerPos(parentPagePosX + 1, parentPagePosY + 1)
    self.titleLabel:changeStyle(TEXT_COLOR, INNER_ELEMENT_BACK_COLOR)
    self.titleLabel:setCenterText(true)

    self.descLabel = LabelClass:new(nil, nil, "", self.document)
    self.descLabel:forceWidthSize(parentPageSizeX - 2)
    self.descLabel:setUpperCornerPos(parentPagePosX + 1, parentPagePosY + 5)
    self.descLabel:changeStyle(TEXT_COLOR, INNER_ELEMENT_BACK_COLOR)

    self:updateLabelsText(colony)
    

    self:setBackColor(ELEMENT_BACK_COLOR)

    self:addElement(self.titleLabel)
    self:addElement(self.descLabel)

end

function ColonyPageClass:updateLabelsText(colony)
    self.titleLabel:setText(tostring(colony.name))
    self.descLabel:setText(self:getDescriptionForColony(colony))
end

function ColonyPageClass:handleRefreshEvent(...)
    local colony = self.colonyMgr:getColony()

    self.document:startEdition()
    self:updateLabelsText(colony)
    self.document:registerCurrentAreaAsDirty(self.titleLabel)
    self.document:registerCurrentAreaAsDirty(self.descLabel)
    local handled = CustomPageClass.handleRefreshEvent(...)
    self.document:endEdition()

    return handled
end

function ColonyPageClass:getDescriptionForColony(colony)
    local description = stringUtils.Format(
    [[
ID: %(id)
Happiness: %(happiness)
Style: %(style)
IsUnderAttack: %(underAttack)
CurrentCitizens: %(currentCitizens)
Max citizens: %(maxCitizens)
Number of construction sites : %(constructionSites)
Number of graves: %(graves)
    ]],
    { 
    id= colony.id,
    happiness = colony.happiness,
    style = colony.style,
    underAttack = tostring(colony.isUnderAttack),
    currentCitizens = colony.amountOfCitizens,
    maxCitizens = colony.maxOfCitizens,
    constructionSites = colony.amountOfConstructionSites,
    graves = colony.amountOfGraves
    })

    return description
end

function ColonyPageClass:__tostring() 
  return CustomPageClass.__tostring(self)
end


return ColonyPageClass