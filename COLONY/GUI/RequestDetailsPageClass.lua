local ObTableClass          = require "GUI.ObTableClass"
local logger                = require "UTIL.logger"
local ButtonClass           = require "GUI.ButtonClass"
local RequestItemClass      = require "COLONY.MODEL.RequestItemClass"
local InventoryManagerClass = require "COMMON.model.inventoryManagerClass"
local MeSystemManagerClass  = require "COMMON.MODEL.MeSystemManagerClass"

local CustomPageClass       = require "GUI.CustomPageClass"
local RequestManagerClass   = require "COLONY.MODEL.RequestManagerClass"
local RequestItemsFetcher     = require "COLONY.MODEL.requestItemsFetcherClass"
local LabelClass              = require "GUI.LabelClass"
local RequestInventoryHandlerClass = require "COLONY.MODEL.RequestInventoryHandlerClass"

-- Define the RessourcePage Class 
---@class RequestDetailsPageClass: CustomPage
local RequestDetailsPageClass = {}
RequestDetailsPageClass.__index = RequestDetailsPageClass
setmetatable(RequestDetailsPageClass, {__index = CustomPageClass})



function RequestDetailsPageClass:new(requestId, monitor, parentPage, document)
  self = setmetatable(CustomPageClass:new(monitor, parentPage, document, "requestItemsPage"), RequestDetailsPageClass)
  self.requestId = requestId
  self.parentPage = parentPage
  self.requestLabel = nil

  self.requestManager = self.document:getManagerForType(RequestManagerClass.TYPE)
  self.meSystemManager = self.document:getManagerForType(MeSystemManagerClass.TYPE)

  self.requestInventoryHandler = RequestInventoryHandlerClass:new(self.document)
  self.inventoryKey = self.requestInventoryHandler:getRequestInventoryKey()

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

    self.requestLabel:applyDocumentStyle()
    local request = self.requestManager:getOb(self.requestId)
    self:updateRequestText(request)
    self.requestLabel:setCenterText(true)
    self:addElement(self.requestLabel)

    local requestDetailsTable = ObTableClass:new(self.monitor, 1,1, "Requests Details", nil, nil, self.document)
    local requestItemFetcher = RequestItemsFetcher:new(self.requestId, self.document)
    requestDetailsTable:setDataFetcher(requestItemFetcher)
    requestDetailsTable:setDisplayKey(true)
    requestDetailsTable:setKeyRowPropertion(0.8)
    requestDetailsTable:setRowHeight(7)
    requestDetailsTable:applyDocumentStyle()
    requestDetailsTable:setHasManualRefresh(true)
    requestDetailsTable:setSize(parentPageSizeX, parentPageSizeY - 11 - 4)
    requestDetailsTable:setPos(parentPagePosX,parentPagePosY + 11)
    requestDetailsTable:setOnTableElementPressedCallback(self:getOnRequestItemPressed())
    requestDetailsTable:setTableElementsProperties({[ButtonClass.properties.should_center]= true}, false, true)
    self:addElement(requestDetailsTable)

    local InventoryLabel = LabelClass:new(nil, nil, self:getInventoryButtonText() , self.document)
    InventoryLabel:forceWidthSize(parentPageSizeX - 2)
    InventoryLabel:setUpperCornerPos(parentPagePosX + 1, parentPagePosY + parentPageSizeY - 4)
    InventoryLabel:applyDocumentStyle()
    InventoryLabel:setCenterText(true)
    self:addElement(InventoryLabel)
    
    self:applyDocumentStyle()

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

function RequestDetailsPageClass:getInventoryButtonText()

    local currentInventoryKey = self.inventoryKey
    if not currentInventoryKey then
        return "No target inventory!"
    end

    return "Target inventory: " .. currentInventoryKey
end

function RequestDetailsPageClass:getOnRequestItemPressed()
    return function (positionInTable, isKey, requestItem)
        if  isKey then
            return
        end

        if not self.inventoryKey then
            logger.log("Cannot process request item because no inventory", logger.LOGGING_LEVEL.WARNING)
            return
        end

        local meSystem = self.meSystemManager:getDefaultMeSystem()
        if not meSystem then
            logger.log("No me system!", logger.LOGGING_LEVEL.WARNING)
            return
        end
        local action = requestItem:getActionToDo()
        if action == RequestItemClass.ACTIONS.SENDTOEXTERNAL then
            meSystem:exportItem(requestItem:getUniqueKey(), requestItem:getAmountToSendFromMe(),  self.inventoryKey)
        elseif action == RequestItemClass.ACTIONS.CRAFT then
            meSystem:craftItem(requestItem:getUniqueKey(), requestItem:getAmountMissingWithMe())
        end
            end
end

return RequestDetailsPageClass