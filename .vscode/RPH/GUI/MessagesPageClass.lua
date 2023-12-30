local ObTableClass          = require "GUI.ObTableClass"
local logger                = require "UTIL.logger"
local CustomPageClass       = require "GUI.CustomPageClass"
local PeripheralManagerClass    = require "COLONY.MODEL.PeripheralManagerClass"
local PeripheralClass           = require "COLONY.MODEL.PeripheralClass"

---@class MessagesPage: CustomPage
local MessagesPageClass = {}
MessagesPageClass.__index = MessagesPageClass
setmetatable(MessagesPageClass, {__index = CustomPageClass})

function MessagesPageClass:new(monitor, parentPage, document)
  ---@class MessagesPageClass: CustomPage
  local o = setmetatable(CustomPageClass:new(monitor, parentPage, document, "PeripheralPage"), MessagesPageClass)

  o.parentPage = parentPage
  --o.peripheralManager = o.document:getManagerForType(PeripheralManagerClass.TYPE)
  
  o:buildCustomPage()
  return o
end

function MessagesPageClass:__tostring() 
    return CustomPageClass.__tostring(self)
  end

function MessagesPageClass:onBuildCustomPage()

    local parentPageSizeX, parentPageSizeY = self.parentPage:getSize()
    local parentPagePosX, parentPagePosY = self.parentPage:getPos()

    
    local peripheralTable = ObTableClass:new(self.monitor, 1,1, "Messages", nil, nil, self.document)

    --peripheralTable:setDataFetcher()
    
    peripheralTable:setDisplayKey(false)
    peripheralTable:setRowHeight(5)
    peripheralTable:setColumnCount(3)
    peripheralTable:applyDocumentStyle()
    peripheralTable:setHasManualRefresh(true)
    peripheralTable:setSize(parentPageSizeX, parentPageSizeY)
    peripheralTable:setPos(parentPagePosX,parentPagePosY)    
    self:addElement(peripheralTable)

    self:applyDocumentStyle()
end



return MessagesPageClass