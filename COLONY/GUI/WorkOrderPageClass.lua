local ObTableClass          = require "GUI.ObTableClass"
local logger                = require "UTIL.logger"
local WorkOrderFetcherClass = require "COLONY.MODEL.WorkOrderFetcherClass"
local RessourcePageClass    = require "COLONY.GUI.RessourcePageClass"
local CustomPageClass       = require "GUI.CustomPageClass"
local InventoryManagerClass = require "COLONY.MODEL.InventoryManagerClass"
local BuilderManagerClass   = require "COLONY.MODEL.BuilderManagerClass"
local PeripheralManagerClass= require "COLONY.MODEL.PeripheralManagerClass"

-- Define constants

local ELEMENT_BACK_COLOR = colors.red
local INNER_ELEMENT_BACK_COLOR = colors.lime
local TEXT_COLOR = colors.yellow

-- Define the RessourcePage Class 
local WorkOrderPageClass = {}
WorkOrderPageClass.__index = WorkOrderPageClass
setmetatable(WorkOrderPageClass, {__index = CustomPageClass})



function WorkOrderPageClass:new(monitor, parentPage, document)
  self = setmetatable(CustomPageClass:new(monitor, parentPage, document, "workOrderPage"), WorkOrderPageClass)
  local peripheralManager = document:getManagerForType(PeripheralManagerClass.TYPE)
  local colonyPeripheral = peripheralManager:getMainColonyPeripheral()

  self.ressourceFetcher = WorkOrderFetcherClass:new(colonyPeripheral)
  self.parentPage = parentPage
  self:buildCustomPage()
  return self
end

function WorkOrderPageClass:__tostring() 
    return CustomPageClass.__tostring(self)
  end

function WorkOrderPageClass:onBuildCustomPage()

    local parentPageSizeX, parentPageSizeY = self.parentPage:getSize()
    local parentPagePosX, parentPagePosY = self.parentPage:getPos()

    local workOrderTable = ObTableClass:new(self.monitor, 1,1, "Work Orders", nil, nil, self.document)
    workOrderTable:setDataFetcher(self.ressourceFetcher)
    workOrderTable:setDisplayKey(false)
    workOrderTable.title = nil
    workOrderTable:setRowHeight(5)
    workOrderTable:changeStyle(ELEMENT_BACK_COLOR, INNER_ELEMENT_BACK_COLOR, TEXT_COLOR)
    workOrderTable:setHasManualRefresh(true)
    workOrderTable:setSize(parentPageSizeX, parentPageSizeY)
    workOrderTable:setPos(parentPagePosX,parentPagePosY)
    workOrderTable:setOnTableElementPressedCallback(self:getOnWorkOrderPressed())

    self:setBackColor(ELEMENT_BACK_COLOR)
    self:addElement(workOrderTable)

end

function WorkOrderPageClass:getOnWorkOrderPressed()
    return function(positionInTable, isKey, workOrder)
        -- do nothing if key, it shouldnt be displayed
        if (isKey) then
            return
        end
        -- get chest to consider!
        local builderId = workOrder.builderID
        local inventoryOb
        if builderId then
            local inventoryManager = self.document:getManagerForType(InventoryManagerClass.TYPE)
            local builderManager = self.document:getManagerForType(BuilderManagerClass.TYPE)
            local builder = builderManager:getOb(builderId)
            assert(builder, "Couldnt find builder associated with work order!")
            local inventoryId = builder:getAssociatedInventory()
            inventoryOb = inventoryManager:getOb(inventoryId)
            assert(inventoryOb, "Couldnt find inventory associated with builder!")
        end
        
        local ressourcePage = RessourcePageClass:new(self.monitor, self.parentPage, workOrder.id, inventoryOb, self.document)
        self.parentPage:addElement(ressourcePage)
    end
end

return WorkOrderPageClass