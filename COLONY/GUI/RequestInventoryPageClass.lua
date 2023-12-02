local ObTableClass          = require "GUI.ObTableClass"
local logger                = require "UTIL.logger"
local CustomPageClass       = require "GUI.CustomPageClass"
local RequestManagerClass   = require "COLONY.MODEL.RequestManagerClass"
local RequestDetailsPageClass = require "COLONY.GUI.RequestDetailsPageClass"
local ToggleableButtonClass   = require "GUI.ToggleableButtonClass"
local RequestInventoryHandlerClass = require "COLONY.MODEL.RequestInventoryHandlerClass"
local InventoryManagerClass = require "COLONY.MODEL.InventoryManagerClass"
local ElementClass          = require "GUI.elementClass"

-- Define constants

local ELEMENT_BACK_COLOR = colors.red
local INNER_ELEMENT_BACK_COLOR = colors.lime
local TEXT_COLOR = colors.yellow

local RequestInventoryPageClass = {}
RequestInventoryPageClass.__index = RequestInventoryPageClass
setmetatable(RequestInventoryPageClass, {__index = CustomPageClass})



function RequestInventoryPageClass:new(monitor, parentPage, document)
  local o = setmetatable(CustomPageClass:new(monitor, parentPage, document, "requestPage"), RequestInventoryPageClass)

  o.parentPage = parentPage
  o.requestInventoryHandler = RequestInventoryHandlerClass:new(o.document)
  o.inventoryManager = o.document:getManagerForType(InventoryManagerClass.TYPE)
  o.selectedInventory = nil
  o.inventoryTable = nil
  
  o:buildCustomPage()
  return o
end

function RequestInventoryPageClass:__tostring() 
    return CustomPageClass.__tostring(self)
  end

function RequestInventoryPageClass:onBuildCustomPage()

    local parentPageSizeX, parentPageSizeY = self.parentPage:getSize()
    local parentPagePosX, parentPagePosY = self.parentPage:getPos()

    
    self.inventoryTable = ObTableClass:new(self.monitor, 1,1, "Available inventories", nil, nil, self.document)
    self.inventoryTable:setDataFetcher(self.inventoryManager)
    self.inventoryTable:setDisplayKey(false)
    self.inventoryTable:setRowHeight(6)
    self.inventoryTable:changeStyle(ELEMENT_BACK_COLOR, INNER_ELEMENT_BACK_COLOR, TEXT_COLOR)
    self.inventoryTable:setSize(parentPageSizeX, parentPageSizeY)
    self.inventoryTable:setPos(parentPagePosX,parentPagePosY)
    self.inventoryTable:setOnTableElementPressedCallback(self:getOnTargetInventoryPressed())
    self.inventoryTable:setTableElementsProperties({[ToggleableButtonClass.properties.automatic_untoggle]= false,
    [ElementClass.properties.on_draw_function] = self:getOnDrawTableElement()})
    
    local currentInventoryKey = self.requestInventoryHandler:getRequestInventoryKey()
    local currentInventory = self.inventoryManager:getOb(currentInventoryKey)
    self:changeSelectedItem(currentInventory, false)

    self:setBackColor(ELEMENT_BACK_COLOR)
    self:addElement(self.inventoryTable)
    
end

function RequestInventoryPageClass:getOnTargetInventoryPressed()
    return function(positionInTable, isKey, inventory)
        if (isKey) then
            return
        end
        self.requestInventoryHandler:setRequestInventoryKey(inventory:getUniqueKey())
        self:changeSelectedItem(inventory, true)
        self.parentPage:popPage()
    end
end

function RequestInventoryPageClass:changeSelectedItem(selectedInventory, buttonsCreated)

    if not selectedInventory then
        return
    end
    if not self.currentlySelectedInventory or 
    selectedInventory:getUniqueKey() ~= self.currentlySelectedInventory:getUniqueKey() then
        self.document:startEdition()
        if self.currentlySelectedInventory and buttonsCreated then
            self.document:registerCurrentAreaAsDirty(self.inventoryTable:getButtonFromOb(self.currentlySelectedInventory, false))
        end 
        if buttonsCreated then
            self.document:registerCurrentAreaAsDirty(self.inventoryTable:getButtonFromOb(selectedInventory, false))
        end

        self.currentlySelectedInventory = selectedInventory

        self.document:endEdition()     
    end
end

function RequestInventoryPageClass:getOnDrawTableElement()
    return function(tableButton)

        local selectedKey
        if self.currentlySelectedInventory then
            selectedKey = self.currentlySelectedInventory:getUniqueKey()
        end


        local drawnOb = self.inventoryTable:getObFromButton(tableButton)
        local isASelectedButton = drawnOb:getUniqueKey() == selectedKey

        tableButton:forceToggle(isASelectedButton)
    end
end

return RequestInventoryPageClass