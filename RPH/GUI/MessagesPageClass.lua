local ObTableClass          = require "GUI.ObTableClass"
local logger                = require "UTIL.logger"
local CustomPageClass       = require "GUI.CustomPageClass"
local MessageManagerClass   = require "RPH.MODEL.MessageManagerClass"

---@class MessagesPage: CustomPage
local MessagesPageClass = {}
MessagesPageClass.__index = MessagesPageClass
setmetatable(MessagesPageClass, {__index = CustomPageClass})

function MessagesPageClass:new(monitor, parentPage, document)
  ---@class MessagesPage: CustomPage
  local o = setmetatable(CustomPageClass:new(monitor, parentPage, document, "PeripheralPage"), MessagesPageClass)

  o.parentPage = parentPage
  o.messageManager = o.document:getManagerForType(MessageManagerClass.TYPE)
  
  o:buildCustomPage()
  return o
end

function MessagesPageClass:__tostring() 
    return CustomPageClass.__tostring(self)
  end

function MessagesPageClass:onBuildCustomPage()

    local parentPageSizeX, parentPageSizeY = self.parentPage:getSize()
    local parentPagePosX, parentPagePosY = self.parentPage:getPos()

    
    self.messageTable = ObTableClass:new(self.monitor, 1,1, "Messages", nil, nil, self.document)

    self.messageTable:setDataFetcher(self.messageManager)
    
    self.messageTable:setDisplayKey(false)
    self.messageTable:setRowHeight(3)
    self.messageTable:setColumnCount(1)
    self.messageTable:applyDocumentStyle()
    self.messageTable:setHasManualRefresh(true)
    self.messageTable:setSize(parentPageSizeX, parentPageSizeY)
    self.messageTable:setPos(parentPagePosX,parentPagePosY)    
    self:addElement(self.messageTable)
    
    self.messageManager:registerModificationListener(self.messageTable)

    self:applyDocumentStyle()
end

return MessagesPageClass