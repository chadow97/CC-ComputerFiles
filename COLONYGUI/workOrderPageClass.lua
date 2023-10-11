local PageClass = require "GUI.pageClass"
local ObTableClass          = require "GUI.obTableClass"
local logger                = require "UTIL.logger"
local WorkOrderFetcherClass = require "MODEL.workOrderFetcherClass"
local RessourcePageClass    = require "COLONYGUI.ressourcePageClass"

-- Define constants

local ELEMENT_BACK_COLOR = colors.red
local INNER_ELEMENT_BACK_COLOR = colors.lime
local TEXT_COLOR = colors.yellow

-- Define the RessourcePage Class 
local WorkOrderPageClass = {}
WorkOrderPageClass.__index = WorkOrderPageClass
setmetatable(WorkOrderPageClass, {__index = PageClass})



function WorkOrderPageClass:new(monitor, parentPage, colonyPeripheral, externalChest)
  self = setmetatable(PageClass:new(monitor), WorkOrderPageClass)

  self.ressourceFetcher = WorkOrderFetcherClass:new(colonyPeripheral)
  self.parentPage = parentPage
  self.colonyPeripheral = colonyPeripheral
  self:buildWorkOrderPage(parentPage)
  self.externalChest = externalChest
  return self
end

function WorkOrderPageClass:buildWorkOrderPage(parentPage)

local parentPageSizeX, parentPageSizeY = parentPage:getSize()
local parentPagePosX, parentPagePosY = parentPage:getPos()

local workOrderTable = ObTableClass:new(self.monitor, 1,1, "Work Orders")
workOrderTable:setBlockDraw(true)
workOrderTable:setDataFetcher(self.ressourceFetcher)
workOrderTable:setDisplayKey(false)
workOrderTable.title = nil
workOrderTable:setRowHeight(5)
workOrderTable:changeStyle(ELEMENT_BACK_COLOR, INNER_ELEMENT_BACK_COLOR, TEXT_COLOR)
workOrderTable:setHasManualRefresh(true)
workOrderTable:setSize(parentPageSizeX, parentPageSizeY)
workOrderTable:setPos(parentPagePosX,parentPagePosY)
workOrderTable:setOnTableElementPressedCallback(self:getOnWorkOrderPressed())

self:setBlockDraw(true)
self:setBackColor(ELEMENT_BACK_COLOR)


workOrderTable:setBlockDraw(false)
self:addElement(workOrderTable)
self:setBlockDraw(false)

end

-- Define static functions 
function WorkOrderPageClass:getOnWorkOrderPressed()
    return function(positionInTable, isKey, workOrder)
        -- do nothing if key, it shouldnt be displayed
        if (isKey) then
            return
        end
        
        local ressourcePage = RessourcePageClass:new(self.monitor, self.parentPage, self.colonyPeripheral, workOrder.id, self.externalChest)
        self.parentPage:addElement(ressourcePage)
    end
end

return WorkOrderPageClass