local ObTableClass          = require "GUI.obTableClass"
local logger                = require "UTIL.logger"
local RessourcePageClass    = require "COLONYGUI.ressourcePageClass"
local BuilderManagerClass   = require "MODEL.builderManagerClass"
local InventoryManagerClass = require "MODEL.inventoryManagerClass"
local CustomPageClass       = require "GUI.customPageClass"
local ToggleableButtonClass = require "GUI.toggleableButtonClass"
local ElementClass          = require "GUI.elementClass"
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

  self:buildCustomPage()
  return self
end

function ColonyPageClass:onBuildCustomPage()
    local colonyMgr = self.document:getManagerForType(ColonyManagerClass.TYPE)
    local colony = colonyMgr:getColony()

    local parentPageSizeX, parentPageSizeY = self.parentPage:getSize()
    local parentPagePosX, parentPagePosY = self.parentPage:getPos()
    --  x, y, text, document
    local titleLabel = LabelClass:new(nil, nil, tostring(colony.name) , self.document)
    titleLabel:forceWidthSize(parentPageSizeX - 2)
    titleLabel:setUpperCornerPos(parentPagePosX + 1, parentPagePosY + 1)
    titleLabel:changeStyle(TEXT_COLOR, INNER_ELEMENT_BACK_COLOR)
    titleLabel:setCenterText(true)

    local descLabel = LabelClass:new(nil, nil, self:getDescriptionForColony(colony), self.document)
    descLabel:forceWidthSize(parentPageSizeX - 2)
    descLabel:setUpperCornerPos(parentPagePosX + 1, parentPagePosY + 5)
    descLabel:changeStyle(TEXT_COLOR, INNER_ELEMENT_BACK_COLOR)
    

    self:setBackColor(ELEMENT_BACK_COLOR)

    self:addElement(titleLabel)
    self:addElement(descLabel)

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