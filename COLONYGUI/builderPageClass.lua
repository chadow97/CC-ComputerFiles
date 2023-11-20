local ObTableClass          = require "GUI.obTableClass"
local logger                = require "UTIL.logger"
local RessourcePageClass    = require "COLONYGUI.ressourcePageClass"
local BuilderManagerClass   = require "MODEL.builderManagerClass"
local InventoryManagerClass = require "MODEL.inventoryManagerClass"
local CustomPageClass       = require "GUI.customPageClass"
local ToggleableButtonClass = require "GUI.toggleableButtonClass"
local ElementClass          = require "GUI.elementClass"

-- Define constants

local ELEMENT_BACK_COLOR = colors.red
local INNER_ELEMENT_BACK_COLOR = colors.lime
local TEXT_COLOR = colors.yellow

-- Define the RessourcePage Class 
local BuilderPageClass = {}
BuilderPageClass.__index = BuilderPageClass
setmetatable(BuilderPageClass, {__index = CustomPageClass})



function BuilderPageClass:new(monitor, parentPage, document)
  self = setmetatable(CustomPageClass:new(monitor, parentPage, document, "BuilderPage"), BuilderPageClass)

  self.builderTable = nil
  self.inventoryTable = nil
  self.currentlySelectedBuilder = nil
  self.currentlySelectedInventory = nil
  self.inventoryManager = self.document:getManagerForType(InventoryManagerClass.TYPE)

  self:buildCustomPage()
  return self
end

function BuilderPageClass:onBuildCustomPage()

local parentPageSizeX, parentPageSizeY = self.parentPage:getSize()
local parentPagePosX, parentPagePosY = self.parentPage:getPos()
local sizeXForTables = (parentPageSizeX - 1)/2

local builderTable = ObTableClass:new(self.monitor, 1,1, "Builders", nil, nil, self.document)
builderTable:setDataFetcher(self.document:getManagerForType(BuilderManagerClass.TYPE))
builderTable:setDisplayKey(false)
builderTable.title = nil
builderTable:setRowHeight(7)
builderTable:changeStyle(ELEMENT_BACK_COLOR, INNER_ELEMENT_BACK_COLOR, TEXT_COLOR)
builderTable:setHasManualRefresh(true)
builderTable:setSize(sizeXForTables, parentPageSizeY)
builderTable:setPos(parentPagePosX,parentPagePosY)
builderTable:setTableElementsProperties({[ToggleableButtonClass.properties.automatic_untoggle]= false,
                                         [ElementClass.properties.on_draw_function] = self:getOnDrawTableElement(true)})
builderTable:setOnTableElementPressedCallback(self:getOnBuilderPressed())
self.builderTable = builderTable

local inventoryTable = ObTableClass:new(self.monitor, 1,1, "Inventories", nil, nil, self.document)
inventoryTable:setDataFetcher(self.inventoryManager)
inventoryTable:setDisplayKey(false)
inventoryTable.title = nil
inventoryTable:setRowHeight(6)
inventoryTable:changeStyle(ELEMENT_BACK_COLOR, INNER_ELEMENT_BACK_COLOR, TEXT_COLOR)
inventoryTable:setHasManualRefresh(true)
inventoryTable:setSize(sizeXForTables, parentPageSizeY)
inventoryTable:setPos(parentPagePosX + sizeXForTables + 1,parentPagePosY)
inventoryTable:setTableElementsProperties({[ToggleableButtonClass.properties.automatic_untoggle]= false,
                                           [ElementClass.properties.on_draw_function] = self:getOnDrawTableElement(false)})
inventoryTable:setOnTableElementPressedCallback(self:getOnInventoryPressed())
self.inventoryTable = inventoryTable

self:setBackColor(ELEMENT_BACK_COLOR)

self:addElement(builderTable)
self:addElement(inventoryTable)
end

function BuilderPageClass:__tostring() 
  return CustomPageClass.__tostring(self)
end

function BuilderPageClass:getOnBuilderPressed()
    return function(positionInTable, isKey, builderOb)
        if isKey then
            return
        end
        
        self:changeSelectedItem(true, builderOb)
        local associatedInventoryName = builderOb:getAssociatedInventory()
        local inventoryOb
        if  associatedInventoryName then
            inventoryOb = self.inventoryManager:getOb(associatedInventoryName)
        end
        

        self:changeSelectedItem(false, inventoryOb)
    end
end

function BuilderPageClass:getOnInventoryPressed()
    return function(positionInTable, isKey, inventoryOb)

        if isKey then
            return
        end

        if not self.currentlySelectedBuilder then
            logger.logToFile("No selected builder!")
            return
        end
        self.document:startEdition()
        self:changeSelectedItem(false, inventoryOb)
        logger.logToFile(self.currentlySelectedBuilder)
        self.currentlySelectedBuilder:setAssociatedInventory(self.currentlySelectedInventory:getUniqueKey())
        self.builderTable.areButtonsDirty = true; --TODO table should recognize on of its ob was modified on its own!
        self.document:registerCurrentAreaAsDirty(self.builderTable) --TODO ideally, we would only have to redraw that specific builder
        self.document:endEdition()

    end
end

function BuilderPageClass:getOnDrawTableElement(isForBuilder)
    return function(tableButton)
        local tableToConsider
        local selectedToConsider
        if isForBuilder then
            tableToConsider = self.builderTable
            selectedToConsider = self.currentlySelectedBuilder
 
        else
            tableToConsider = self.inventoryTable
            selectedToConsider = self.currentlySelectedInventory
        end
        local selectedKey
        if selectedToConsider then
            selectedKey = selectedToConsider:getUniqueKey()
        end


        local drawnOb = tableToConsider:getObFromButton(tableButton)
        local isASelectedButton = drawnOb:getUniqueKey() == selectedKey

        tableButton:forceToggle(isASelectedButton)
    end
end

function BuilderPageClass:changeSelectedItem(isForBuilder, newSelectedOb)
    local tableToConsider
    local selectedToConsider
    if isForBuilder then
        tableToConsider = self.builderTable
        selectedToConsider = self.currentlySelectedBuilder

    else
        tableToConsider = self.inventoryTable
        selectedToConsider = self.currentlySelectedInventory
    end 
    local newSelectedObKey
    if newSelectedOb then
        newSelectedObKey = newSelectedOb:getUniqueKey()
    end  

    if not selectedToConsider or 
        newSelectedObKey ~= selectedToConsider:getUniqueKey() then
        self.document:startEdition()
        if selectedToConsider then
            -- we need to redraw old builder
            self.document:registerCurrentAreaAsDirty(tableToConsider:getButtonFromOb(selectedToConsider, false))
        end
        if newSelectedOb then           
            self.document:registerCurrentAreaAsDirty(tableToConsider:getButtonFromOb(newSelectedOb, false))
        end
        if isForBuilder then
            self.currentlySelectedBuilder = newSelectedOb
        else
            self.currentlySelectedInventory = newSelectedOb
        end
        self.document:endEdition()      
    end
end

return BuilderPageClass