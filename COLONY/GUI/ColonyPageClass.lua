local logger                = require "UTIL.logger"
local CustomPageClass       = require "GUI.CustomPageClass"
local ColonyManagerClass    = require "COLONY.MODEL.ColonyManagerClass"
local LabelClass            = require "GUI.LabelClass"
local stringUtils           = require "UTIL.stringUtils"

-- Define the RessourcePage Class 
---@class ColonyPageClass: CustomPage
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
    self.titleLabel:applyDocumentStyle()
    self.titleLabel:setCenterText(true)
    self:addElement(self.titleLabel)

    self.descLabel = LabelClass:new(nil, nil, "", self.document)
    self.descLabel:forceWidthSize(parentPageSizeX - 2)
    self.descLabel:setUpperCornerPos(parentPagePosX + 1, parentPagePosY + 5)
    self.descLabel:applyDocumentStyle()
    self:addElement(self.descLabel)

    self:updateLabelsText(colony)

    self:applyDocumentStyle()

end

function ColonyPageClass:updateLabelsText(colony)
    if colony.name == nil then
        self.titleLabel:setText("No colony found!")
        self.descLabel:setText("")
    else
        self.titleLabel:setText(tostring(colony.name))
        self.descLabel:setText(self:getDescriptionForColony(colony))
    end
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