local PageClass = require "GUI.pageClass"
local ObTableClass          = require "GUI.obTableClass"
local logger                = require "UTIL.logger"
local RessourcePageClass    = require "COLONYGUI.ressourcePageClass"
local BuilderFetcherClass   = require "MODEL.builderFetcherClass"
local InventoryManagerClass = require "MODEL.inventoryManagerClass"

-- Define constants

local ELEMENT_BACK_COLOR = colors.red
local INNER_ELEMENT_BACK_COLOR = colors.lime
local TEXT_COLOR = colors.yellow

-- Define the RessourcePage Class 
local BuilderPageClass = {}
BuilderPageClass.__index = BuilderPageClass
setmetatable(BuilderPageClass, {__index = PageClass})



function BuilderPageClass:new(monitor, parentPage, colonyPeripheral, document)
  self = setmetatable(PageClass:new(monitor), BuilderPageClass)

  self.ressourceFetcher = BuilderFetcherClass:new(colonyPeripheral)
  self.parentPage = parentPage
  self.colonyPeripheral = colonyPeripheral
  self.document = document
  self:buildBuilderPage(parentPage)
  return self
end

function BuilderPageClass:buildBuilderPage(parentPage)

local parentPageSizeX, parentPageSizeY = parentPage:getSize()
local parentPagePosX, parentPagePosY = parentPage:getPos()
local sizeXForTables = (parentPageSizeX - 1)/2

local workOrderTable = ObTableClass:new(self.monitor, 1,1, "Builders")
workOrderTable:setBlockDraw(true)
workOrderTable:setDataFetcher(self.ressourceFetcher)
workOrderTable:setDisplayKey(false)
workOrderTable.title = nil
workOrderTable:setRowHeight(6)
workOrderTable:changeStyle(ELEMENT_BACK_COLOR, INNER_ELEMENT_BACK_COLOR, TEXT_COLOR)
workOrderTable:setHasManualRefresh(true)
workOrderTable:setSize(sizeXForTables, parentPageSizeY)
workOrderTable:setPos(parentPagePosX,parentPagePosY)
workOrderTable:setOnTableElementPressedCallback(self:getOnBuilderPressed())

local inventoryTable = ObTableClass:new(self.monitor, 1,1, "Inventories")
inventoryTable:setBlockDraw(true)
inventoryTable:setDataFetcher(self.document:getManagerForType(InventoryManagerClass.TYPE))
inventoryTable:setDisplayKey(false)
inventoryTable.title = nil
inventoryTable:setRowHeight(6)
inventoryTable:changeStyle(ELEMENT_BACK_COLOR, INNER_ELEMENT_BACK_COLOR, TEXT_COLOR)
inventoryTable:setHasManualRefresh(true)
inventoryTable:setSize(sizeXForTables, parentPageSizeY)
inventoryTable:setPos(parentPagePosX + sizeXForTables + 1,parentPagePosY)
inventoryTable:setOnTableElementPressedCallback(self:getOnBuilderPressed())

self:setBlockDraw(true)
self:setBackColor(ELEMENT_BACK_COLOR)

self:addElement(workOrderTable)
self:addElement(inventoryTable)

inventoryTable:setBlockDraw(false)
workOrderTable:setBlockDraw(false)
self:setBlockDraw(false)

end

function BuilderPageClass:getOnBuilderPressed()
    return function(positionInTable, isKey, builder)

    end
end

return BuilderPageClass