local ObTableClass          = require "GUI.obTableClass"
local logger                = require "UTIL.logger"
local WorkOrderFetcherClass = require "MODEL.workOrderFetcherClass"
local RessourcePageClass    = require "COLONYGUI.ressourcePageClass"
local CustomPageClass       = require "GUI.customPageClass"

-- Define constants

local ELEMENT_BACK_COLOR = colors.red
local INNER_ELEMENT_BACK_COLOR = colors.lime
local TEXT_COLOR = colors.yellow

-- Define the RessourcePage Class 
local WorkOrderPageClass = {}
WorkOrderPageClass.__index = WorkOrderPageClass
setmetatable(WorkOrderPageClass, {__index = CustomPageClass})



function WorkOrderPageClass:new(monitor, parentPage, colonyPeripheral, externalChest, document)
  self = setmetatable(CustomPageClass:new(monitor, parentPage, document, "workOrderPage"), WorkOrderPageClass)

  self.ressourceFetcher = WorkOrderFetcherClass:new(colonyPeripheral)
  self.parentPage = parentPage
  self.colonyPeripheral = colonyPeripheral
  self.externalChest = externalChest
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
        
        local ressourcePage = RessourcePageClass:new(self.monitor, self.parentPage, self.colonyPeripheral, workOrder.id, self.externalChest, self.document)
        self.parentPage:addElement(ressourcePage)
    end
end

return WorkOrderPageClass