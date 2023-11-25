local ObTableClass          = require "GUI.obTableClass"
local logger                = require "UTIL.logger"
local WorkOrderFetcherClass = require "MODEL.workOrderFetcherClass"
local RessourcePageClass    = require "COLONYGUI.ressourcePageClass"
local CustomPageClass       = require "GUI.customPageClass"
local InventoryManagerClass = require "MODEL.inventoryManagerClass"
local BuilderManagerClass   = require "MODEL.builderManagerClass"
local RequestManagerClass   = require "MODEL.requestManagerClass"
local RequestItemManagerClass = require "MODEL.requestItemManagerClass"
local RequestItemsFetcher     = require "MODEL.requestItemsFetcher"
local LabelClass              = require "GUI.labelClass"

-- Define constants

local ELEMENT_BACK_COLOR = colors.red
local INNER_ELEMENT_BACK_COLOR = colors.lime
local TEXT_COLOR = colors.yellow

-- Define the RessourcePage Class 
local RequestDetailsPageClass = {}
RequestDetailsPageClass.__index = RequestDetailsPageClass
setmetatable(RequestDetailsPageClass, {__index = CustomPageClass})



function RequestDetailsPageClass:new(requestId, monitor, parentPage, document)
  self = setmetatable(CustomPageClass:new(monitor, parentPage, document, "requestItemsPage"), RequestDetailsPageClass)
  self.requestId = requestId
  self.parentPage = parentPage
  self.requestLabel = nil
  self.requestManager = self.document:getManagerForType(RequestManagerClass.TYPE)
  self:buildCustomPage()
  return self
end

function RequestDetailsPageClass:__tostring() 
    return CustomPageClass.__tostring(self)
  end

function RequestDetailsPageClass:onBuildCustomPage()

    local parentPageSizeX, parentPageSizeY = self.parentPage:getSize()
    local parentPagePosX, parentPagePosY = self.parentPage:getPos()

    self.requestLabel = LabelClass:new(nil, nil, "" , self.document)
    self.requestLabel:forceWidthSize(parentPageSizeX - 2)
    self.requestLabel:setUpperCornerPos(parentPagePosX + 1, parentPagePosY + 1)
    self.requestLabel:changeStyle(TEXT_COLOR, INNER_ELEMENT_BACK_COLOR)
    local request = self.requestManager:getOb(self.requestId)
    self:updateRequestText(request)
    self.requestLabel:setCenterText(true)

    self:addElement(self.requestLabel)

    local requestDetailsTable = ObTableClass:new(self.monitor, 1,1, "Requests Details", nil, nil, self.document)
    local requestItemFetcher = RequestItemsFetcher:new(self.requestId, self.document)
    requestDetailsTable:setDataFetcher(requestItemFetcher)
    requestDetailsTable:setDisplayKey(true)
    requestDetailsTable:setKeyRowPropertion(0.8)
    requestDetailsTable:setRowHeight(10)
    requestDetailsTable:changeStyle(ELEMENT_BACK_COLOR, INNER_ELEMENT_BACK_COLOR, TEXT_COLOR)
    requestDetailsTable:setHasManualRefresh(true)
    requestDetailsTable:setSize(parentPageSizeX, parentPageSizeY - 11)
    requestDetailsTable:setPos(parentPagePosX,parentPagePosY + 11)

    self:setBackColor(ELEMENT_BACK_COLOR)
    self:addElement(requestDetailsTable)

end

function RequestDetailsPageClass:handleRefreshEvent(...)
    local request = self.requestManager:getOb(self.requestId)

    self.document:startEdition()
    self:updateRequestText(request)
    self.document:registerCurrentAreaAsDirty(self.requestLabel)
    local handled = CustomPageClass.handleRefreshEvent(...)
    self.document:endEdition()

    return handled
end

function RequestDetailsPageClass:updateRequestText(request)
    self.requestLabel:setText(request:GetKeyDisplayString())
end

return RequestDetailsPageClass