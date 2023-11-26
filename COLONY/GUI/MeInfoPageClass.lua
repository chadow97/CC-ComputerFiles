local ObTableClass          = require "GUI.ObTableClass"
local logger                = require "UTIL.logger"
local CustomPageClass       = require "GUI.CustomPageClass"
local MeItemManagerClass    = require "COLONY.MODEL.MeItemManagerClass"
local stringUtils           = require "UTIL.stringUtils"
local LabelClass            = require "GUI.LabelClass"
local MeSystemManagerClass  = require "COLONY.MODEL.MeSystemManagerClass"

-- Define constants

local ELEMENT_BACK_COLOR = colors.red
local INNER_ELEMENT_BACK_COLOR = colors.lime
local TEXT_COLOR = colors.yellow

-- Define the RessourcePage Class 
local MeInfoPageClass = {}
MeInfoPageClass.__index = MeInfoPageClass
setmetatable(MeInfoPageClass, {__index = CustomPageClass})



function MeInfoPageClass:new(monitor, parentPage, document)
  self = setmetatable(CustomPageClass:new(monitor, parentPage, document, "requestPage"), MeInfoPageClass)

  self.parentPage = parentPage
  self.meItemsManager = self.document:getManagerForType(MeItemManagerClass.TYPE)
  self.meSystemManager = self.document:getManagerForType(MeSystemManagerClass.TYPE)
  self.descLabel = nil
  self:buildCustomPage()
  return self
end

function MeInfoPageClass:__tostring() 
    return CustomPageClass.__tostring(self)
  end

function MeInfoPageClass:onBuildCustomPage()

    local parentPageSizeX, parentPageSizeY = self.parentPage:getSize()
    local parentPagePosX, parentPagePosY = self.parentPage:getPos()

    local meSystem = self.meSystemManager:getMeSystem()
    self.descLabel = LabelClass:new(nil, nil, self:getDescriptionForMeSystem(meSystem), self.document)
    self.descLabel:forceWidthSize(parentPageSizeX - 2)
    self.descLabel:setUpperCornerPos(parentPagePosX + 1, parentPagePosY + 1)
    self.descLabel:changeStyle(TEXT_COLOR, INNER_ELEMENT_BACK_COLOR)
    self:addElement(self.descLabel)

    local meItemTable = ObTableClass:new(self.monitor, 1,1, "Me Items", nil, nil, self.document)
    meItemTable:setDataFetcher(self.meItemsManager)
    meItemTable:setDisplayKey(false)
    meItemTable:setRowHeight(5)
    meItemTable:setColumnCount(4)
    meItemTable:changeStyle(ELEMENT_BACK_COLOR, INNER_ELEMENT_BACK_COLOR, TEXT_COLOR)
    meItemTable:setHasManualRefresh(true)
    meItemTable:setSize(parentPageSizeX, parentPageSizeY - 12 )
    meItemTable:setPos(parentPagePosX,parentPagePosY + 12)


    self:setBackColor(ELEMENT_BACK_COLOR)
    self:addElement(meItemTable)

end

function MeInfoPageClass:getDescriptionForMeSystem(meSystem)
    return string.format(
    [[
General ME system information:
Total storage: %s
Used storage: %s (%s%%)
Free storage: %s (%s%%)
#Crafting cells: %s
Energy capacity: %s
Current energy: %s ((%s%%))
Energy usage: %s
    ]],
    meSystem.totalItemStorage,
    meSystem.usedItemStorage,
    meSystem:getUsedPercentage(),
    meSystem.availableItemStorage,
    meSystem:getFreePercentage(),
    meSystem:getNumberOfCraftingCells(),
    meSystem.maxEnergyStorage,
    meSystem.energyStorage,
    meSystem:getEnergyPercentage(),
    meSystem.energyUsage

)
end

function MeInfoPageClass:handleRefreshEvent(...)
    local meSystem = self.meSystemManager:getMeSystem()

    self.document:startEdition()
    self.descLabel:setText(self:getDescriptionForMeSystem(meSystem))
    self.document:registerCurrentAreaAsDirty(self.descLabel)
    local handled = CustomPageClass.handleRefreshEvent(...)
    self.document:endEdition()

    return handled
end



return MeInfoPageClass