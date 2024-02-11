local ObTableClass          = require "GUI.ObTableClass"
local logger                = require "UTIL.logger"
local CustomPageClass       = require "GUI.CustomPageClass"
local PeripheralManagerClass    = require "COMMON.MODEL.PeripheralManagerClass"
local PeripheralClass           = require "COMMON.MODEL.PeripheralClass"
local RedstoneIntegratorManagerClass = require "COMMON.MODEL.RedstoneIntegratorManagerClass"
local RedstoneIntegratorDetailPageClass = require "COMMON.GUI.RedstoneIntegratorDetailPageClass"

---@class RedstoneControlPageClass: CustomPage
local RedstoneControlPageClass = {}
RedstoneControlPageClass.__index = RedstoneControlPageClass
setmetatable(RedstoneControlPageClass, {__index = CustomPageClass})

function RedstoneControlPageClass:new( parentPage, document)
  ---@class RedstoneControlPageClass: CustomPage
  local o = setmetatable(CustomPageClass:new(parentPage, document, "Redstone page"), RedstoneControlPageClass)

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

    
    local RiTable = ObTableClass:new(1,1, "Redstone controllers", nil, nil, self.document)


    RiTable:setDataFetcher(self.RiManager)
    RiTable:setDisplayKey(false)
    RiTable:setRowHeight(6)
    RiTable:setColumnCount(3)
    RiTable:applyDocumentStyle()
    RiTable:setHasManualRefresh(true)
    RiTable:setSize(parentPageSizeX, parentPageSizeY)
    RiTable:setPos(parentPagePosX,parentPagePosY) 
    RiTable:setOnTableElementPressedCallback(self:getOnRiPressed())   
    self:addElement(RiTable)

    self:applyDocumentStyle()
end

function RedstoneControlPageClass:getOnRiPressed()
  return function(positionInTable, isKey, Ri)

      if (isKey) then
          return
      end
      self.document:startEdition()
      local ressourcePage = RedstoneIntegratorDetailPageClass:new( self.parentPage, self.document, Ri)
      self.parentPage:addElement(ressourcePage)
      self.document:endEdition()
  end
end



return RedstoneControlPageClass