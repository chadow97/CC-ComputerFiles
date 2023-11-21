local ObTableClass          = require "GUI.obTableClass"
local logger                = require "UTIL.logger"
local WorkOrderFetcherClass = require "MODEL.workOrderFetcherClass"
local RessourcePageClass    = require "COLONYGUI.ressourcePageClass"
local CustomPageClass       = require "GUI.customPageClass"
local InventoryManagerClass = require "MODEL.inventoryManagerClass"
local BuilderManagerClass   = require "MODEL.builderManagerClass"
local RequestManagerClass   = require "MODEL.requestManagerClass"

-- Define constants

local ELEMENT_BACK_COLOR = colors.red
local INNER_ELEMENT_BACK_COLOR = colors.lime
local TEXT_COLOR = colors.yellow

-- Define the RessourcePage Class 
local RequestPageClass = {}
RequestPageClass.__index = RequestPageClass
setmetatable(RequestPageClass, {__index = CustomPageClass})



function RequestPageClass:new(monitor, parentPage, document)
  self = setmetatable(CustomPageClass:new(monitor, parentPage, document, "workOrderPage"), RequestPageClass)

  self.parentPage = parentPage
  self.requestManager = self.document:getManagerForType(RequestManagerClass.TYPE)
  self:buildCustomPage()
  return self
end

function RequestPageClass:__tostring() 
    return CustomPageClass.__tostring(self)
  end

function RequestPageClass:onBuildCustomPage()

    local parentPageSizeX, parentPageSizeY = self.parentPage:getSize()
    local parentPagePosX, parentPagePosY = self.parentPage:getPos()

    local requestTable = ObTableClass:new(self.monitor, 1,1, "Requests", nil, nil, self.document)
    requestTable:setDataFetcher(self.requestManager)
    requestTable:setDisplayKey(true)
    requestTable:setKeyRowPropertion(0.8)
    requestTable:setRowHeight(10)
    requestTable:changeStyle(ELEMENT_BACK_COLOR, INNER_ELEMENT_BACK_COLOR, TEXT_COLOR)
    requestTable:setHasManualRefresh(true)
    requestTable:setSize(parentPageSizeX, parentPageSizeY)
    requestTable:setPos(parentPagePosX,parentPagePosY)

    self:setBackColor(ELEMENT_BACK_COLOR)
    self:addElement(requestTable)

end

return RequestPageClass