local ObTableClass          = require "GUI.ObTableClass"
local logger                = require "UTIL.logger"
local CustomPageClass       = require "GUI.CustomPageClass"
local MeItemManagerClass    = require "COLONY.MODEL.MeItemManagerClass"

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
  self:buildCustomPage()
  return self
end

function MeInfoPageClass:__tostring() 
    return CustomPageClass.__tostring(self)
  end

function MeInfoPageClass:onBuildCustomPage()

    local parentPageSizeX, parentPageSizeY = self.parentPage:getSize()
    local parentPagePosX, parentPagePosY = self.parentPage:getPos()

    local meItemTable = ObTableClass:new(self.monitor, 1,1, "Me Items", nil, nil, self.document)
    meItemTable:setDataFetcher(self.meItemsManager)
    meItemTable:setDisplayKey(false)
    meItemTable:setRowHeight(5)
    meItemTable:setColumnCount(4)
    meItemTable:changeStyle(ELEMENT_BACK_COLOR, INNER_ELEMENT_BACK_COLOR, TEXT_COLOR)
    meItemTable:setHasManualRefresh(true)
    meItemTable:setSize(parentPageSizeX, parentPageSizeY)
    meItemTable:setPos(parentPagePosX,parentPagePosY)


    self:setBackColor(ELEMENT_BACK_COLOR)
    self:addElement(meItemTable)

end



return MeInfoPageClass