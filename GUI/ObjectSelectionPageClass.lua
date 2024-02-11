local ObTableClass          = require "GUI.ObTableClass"
local logger                = require "UTIL.logger"
local CustomPageClass       = require "GUI.CustomPageClass"
local RequestManagerClass   = require "COLONY.MODEL.RequestManagerClass"
local RequestDetailsPageClass = require "COLONY.GUI.RequestDetailsPageClass"
local ToggleableButtonClass   = require "GUI.ToggleableButtonClass"
local RequestInventoryHandlerClass = require "COLONY.MODEL.RequestInventoryHandlerClass"
local InventoryManagerClass = require "COMMON.model.inventoryManagerClass"
local ElementClass          = require "GUI.elementClass"

---@class ObjectSelectionPageClass: CustomPage
local ObjectSelectionPageClass = {}
ObjectSelectionPageClass.__index = ObjectSelectionPageClass
setmetatable(ObjectSelectionPageClass, {__index = CustomPageClass})



function ObjectSelectionPageClass:new( parentPage, document, title, objectProvider, currentSelectedKey)
  ---@class ObjectSelectionPageClass: CustomPage
  local o = setmetatable(CustomPageClass:new( parentPage, document, "Object selection page"), ObjectSelectionPageClass)

  o.parentPage = parentPage
  o.objectProvider = objectProvider
  o.currentSelectedKey = currentSelectedKey
  o.currentlySelectedObject = nil
  o.title = title
  
  o:buildCustomPage()
  return o
end

function ObjectSelectionPageClass:__tostring() 
    return CustomPageClass.__tostring(self)
  end

function ObjectSelectionPageClass:onBuildCustomPage()

    local parentPageSizeX, parentPageSizeY = self.parentPage:getSize()
    local parentPagePosX, parentPagePosY = self.parentPage:getPos()

    
    self.objectTable = ObTableClass:new( 1,1, self.title, nil, nil, self.document)
    self.objectTable:setDataFetcher(self.objectProvider)
    self.objectTable:setDisplayKey(false)
    self.objectTable:setRowHeight(6)
    self.objectTable:applyDocumentStyle()
    self.objectTable:setSize(parentPageSizeX, parentPageSizeY)
    self.objectTable:setPos(parentPagePosX,parentPagePosY)
    self.objectTable:setOnTableElementPressedCallback(self:getOnObjectPressed())
    self.objectTable:setTableElementsProperties({[ToggleableButtonClass.properties.automatic_untoggle]= false,
    [ElementClass.properties.on_draw_function] = self:getOnDrawTableElement()})
    

    local currentObject = nil
    if self.currentSelectedKey then
        currentObject = self.objectProvider:getOb(self.currentSelectedKey)
    end
    self:changeSelectedItem(currentObject, false)

    self:applyDocumentStyle()
    self:addElement(self.objectTable)
    
end

function ObjectSelectionPageClass:getOnObjectPressed()
    return function(positionInTable, isKey, object)
        if (isKey) then
            return
        end
        self:changeSelectedItem(object, true)
        self.parentPage:popPage(object)
    end
end

function ObjectSelectionPageClass:changeSelectedItem(selectedObject, buttonsCreated)

    if not selectedObject then
        return
    end
    if not self.currentlySelectedObject or selectedObject:getUniqueKey() ~= self.currentlySelectedObject:getUniqueKey() then
        self.document:startEdition()
        if self.currentlySelectedObject and buttonsCreated then
            self.document:registerCurrentAreaAsDirty(self.objectTable:getButtonFromOb(self.currentlySelectedObject, false))
        end 
        if buttonsCreated then
            self.document:registerCurrentAreaAsDirty(self.objectTable:getButtonFromOb(selectedObject, false))
        end

        self.currentlySelectedObject = selectedObject

        self.document:endEdition()     
    end
end

function ObjectSelectionPageClass:getOnDrawTableElement()
    return function(tableButton)

        local selectedKey
        if self.currentlySelectedObject then
            selectedKey = self.currentlySelectedObject:getUniqueKey()
        end


        local drawnOb = self.objectTable:getObFromButton(tableButton)
        local isASelectedButton = drawnOb:getUniqueKey() == selectedKey

        tableButton:forceToggle(isASelectedButton)
    end
end

return ObjectSelectionPageClass