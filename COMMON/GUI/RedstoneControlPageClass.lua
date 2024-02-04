local ObTableClass          = require "GUI.ObTableClass"
local logger                = require "UTIL.logger"
local CustomPageClass       = require "GUI.CustomPageClass"
local PeripheralManagerClass    = require "COMMON.MODEL.PeripheralManagerClass"
local PeripheralClass           = require "COMMON.MODEL.PeripheralClass"
local RedstoneIntegratorManagerClass = require "COMMON.MODEL.RedstoneIntegratorManagerClass"

---@class RedstoneControlPageClass: CustomPage
local RedstoneControlPageClass = {}
RedstoneControlPageClass.__index = RedstoneControlPageClass
setmetatable(RedstoneControlPageClass, {__index = CustomPageClass})

function RedstoneControlPageClass:new(monitor, parentPage, document)
  ---@class RedstoneControlPageClass: CustomPage
  local o = setmetatable(CustomPageClass:new(monitor, parentPage, document, "Redstone page"), RedstoneControlPageClass)

  o.parentPage = parentPage
  o.RiManager = o.document:getManagerForType(RedstoneIntegratorManagerClass.TYPE)
  
  o:buildCustomPage()
  return o
end

function RedstoneControlPageClass:__tostring() 
    return CustomPageClass.__tostring(self)
  end

function RedstoneControlPageClass:onBuildCustomPage()

    local parentPageSizeX, parentPageSizeY = self.parentPage:getSize()
    local parentPagePosX, parentPagePosY = self.parentPage:getPos()

    
    local peripheralTable = ObTableClass:new(self.monitor, 1,1, "Redstone controllers", nil, nil, self.document)


    peripheralTable:setDataFetcher(self.RiManager)
    peripheralTable:setDisplayKey(false)
    peripheralTable:setRowHeight(6)
    peripheralTable:setColumnCount(3)
    peripheralTable:applyDocumentStyle()
    peripheralTable:setHasManualRefresh(true)
    peripheralTable:setSize(parentPageSizeX, parentPageSizeY)
    peripheralTable:setPos(parentPagePosX,parentPagePosY)    
    self:addElement(peripheralTable)

    self:applyDocumentStyle()
end



return RedstoneControlPageClass