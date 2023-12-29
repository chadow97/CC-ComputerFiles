local ObTableClass          = require "GUI.ObTableClass"
local logger                = require "UTIL.logger"
local CustomPageClass       = require "GUI.CustomPageClass"
local RequestManagerClass   = require "COLONY.MODEL.RequestManagerClass"
local RequestDetailsPageClass = require "COLONY.GUI.RequestDetailsPageClass"
local ToggleableButtonClass   = require "GUI.ToggleableButtonClass"
local RequestInventoryHandlerClass = require "COLONY.MODEL.RequestInventoryHandlerClass"
local RequestInventoryPageClass = require "COLONY.GUI.RequestInventoryPageClass"
local ButtonClass               = require "GUI.ButtonClass"

---@class RequestPage: CustomPage
local RequestPageClass = {}
RequestPageClass.__index = RequestPageClass
setmetatable(RequestPageClass, {__index = CustomPageClass})



function RequestPageClass:new(monitor, parentPage, document)
  ---@class RequestPage: CustomPage
  local o = setmetatable(CustomPageClass:new(monitor, parentPage, document, "requestInventoryPage"), RequestPageClass)

  o.parentPage = parentPage
  o.requestInventoryHandler = RequestInventoryHandlerClass:new(document)
  o.requestManager = o.document:getManagerForType(RequestManagerClass.TYPE)
  o.targetInventoryButton = nil

  
  o:buildCustomPage()
  return o
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
    requestTable:applyDocumentStyle()
    requestTable:setHasManualRefresh(true)
    requestTable:setSize(parentPageSizeX, parentPageSizeY - 4)
    requestTable:setPos(parentPagePosX,parentPagePosY)
    requestTable:setOnTableElementPressedCallback(self:getOnRequestPressed())
    requestTable:setTableElementsProperties({[ButtonClass.properties.should_center]= true}, false, true)
    
    self:applyDocumentStyle()
    self:addElement(requestTable)

    self.targetInventoryButton = ToggleableButtonClass:new(1, 1, self:getInventoryButtonText(), self.document)
    self.targetInventoryButton:forceWidthSize(parentPageSizeX - 2)
    self.targetInventoryButton:setUpperCornerPos(parentPagePosX + 1, parentPagePosY + parentPageSizeY - 4)
    self.targetInventoryButton:applyDocumentStyle()
    self.targetInventoryButton:setOnManualToggle(self:getOnTargetInventoryPressed())
    self.targetInventoryButton:setCenterText(true)
    self:addElement(self.targetInventoryButton)
    
end

function RequestPageClass:getOnRequestPressed()
    return function(positionInTable, isKey, request)
        -- todo send all when value is pressed
        if (not isKey) then
            return
        end
        self.document:startEdition()
        local ressourcePage = RequestDetailsPageClass:new(request:getUniqueKey(), self.monitor, self.parentPage, self.document)
        self.parentPage:addElement(ressourcePage)
        self.document:endEdition()
    end
end

function RequestPageClass:getOnTargetInventoryPressed()
    return function()

        self.document:startEdition()
        local RequestInventoryPage = RequestInventoryPageClass:new(self.monitor, self.parentPage, self.document)
        self.parentPage:addElement(RequestInventoryPage)
        self.document:endEdition()

    end
end

function RequestPageClass:getInventoryButtonText()

    local currentInventoryKey = self.requestInventoryHandler:getRequestInventoryKey()
    if not currentInventoryKey then
        return "No target inventory!"  .. " (Press to select a new one)"
    end

    return "Target inventory for all request: " .. currentInventoryKey .. " (Press to change)"
end

function RequestPageClass:onResumeAfterContextLost()
self.document:startEdition()
self.targetInventoryButton:setText(self:getInventoryButtonText())
self.document:registerCurrentAreaAsDirty(self.targetInventoryButton)
CustomPageClass.onResumeAfterContextLost(self)
self.document:endEdition()
end

return RequestPageClass