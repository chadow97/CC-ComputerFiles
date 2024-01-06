local ObTableClass          = require "GUI.ObTableClass"
local logger                = require "UTIL.logger"
local CustomPageClass       = require "GUI.CustomPageClass"
local PeripheralManagerClass    = require "COMMON.MODEL.PeripheralManagerClass"
local PeripheralClass           = require "COMMON.MODEL.PeripheralClass"

---@class PeripheralPageClass: CustomPage
local PeripheralPageClass = {}
PeripheralPageClass.__index = PeripheralPageClass
setmetatable(PeripheralPageClass, {__index = CustomPageClass})

function PeripheralPageClass:new(monitor, parentPage, document)
  ---@class PeripheralPageClass: CustomPage
  local o = setmetatable(CustomPageClass:new(monitor, parentPage, document, "PeripheralPage"), PeripheralPageClass)

  o.parentPage = parentPage
  o.peripheralManager = o.document:getManagerForType(PeripheralManagerClass.TYPE)
  o.targetInventoryButton = nil

  
  o:buildCustomPage()
  return o
end

function PeripheralPageClass:__tostring() 
    return CustomPageClass.__tostring(self)
  end

function PeripheralPageClass:onBuildCustomPage()

    local parentPageSizeX, parentPageSizeY = self.parentPage:getSize()
    local parentPagePosX, parentPagePosY = self.parentPage:getPos()

    
    local peripheralTable = ObTableClass:new(self.monitor, 1,1, "Peripherals", nil, nil, self.document)
    -- make sure inventories are displayed as peripherals in this context:
    peripheralTable.getStringToDisplayForElement = function(table, data, isKey, position)
            return PeripheralClass.GetDisplayString(table.obList[position])
        end

    peripheralTable:setDataFetcher(self.peripheralManager)
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



return PeripheralPageClass