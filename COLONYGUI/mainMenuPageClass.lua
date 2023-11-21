
local RessourceFetcherClass = require "MODEL.ressourceFetcherClass"
local ObTableClass          = require "GUI.obTableClass"
local LogClass              = require "GUI.logClass"
local ToggleableButtonClass = require "GUI.toggleableButtonClass"
local RessourceClass        = require "MODEL.ressourceClass"
local MeUtils               = require "UTIL.meUtils"
local logger                = require "UTIL.logger"
local WorkOrderPageClass    = require "COLONYGUI.workOrderPageClass"
local BuilderPageClass      = require "COLONYGUI.builderPageClass"
local InventoryManagerClass = require "MODEL.inventoryManagerClass"
local CustomPageClass       = require "GUI.customPageClass"
local ColonyPageClass       = require "COLONYGUI.colonyPageClass"

-- Define constants

local ELEMENT_BACK_COLOR = colors.red
local INNER_ELEMENT_BACK_COLOR = colors.lime
local TEXT_COLOR = colors.yellow


-- Define the RessourcePage Class 
local MainMenuPageClass = {}
MainMenuPageClass.__index = MainMenuPageClass
setmetatable(MainMenuPageClass, {__index = CustomPageClass})

function MainMenuPageClass:new(monitor, parentPage, colonyPeripheral, document)
  self = setmetatable(CustomPageClass:new(monitor, parentPage, document, "MainMenu"), MainMenuPageClass)

  self.colonyPeripheral = colonyPeripheral

  self:buildCustomPage()

  return self
end

function MainMenuPageClass:__tostring() 
  return CustomPageClass.__tostring(self)
end

function MainMenuPageClass:onBuildCustomPage()
  local parentPageSizeX, parentPageSizeY = self.parentPage:getSize()
  local parentPagePosX, parentPagePosY = self.parentPage:getPos()

  local yValueForEntry = parentPagePosY + 1

  local ColonyButton = ToggleableButtonClass:new(1, 1, "General colony information", self.document)
  ColonyButton:forceWidthSize(parentPageSizeX - 2)
  ColonyButton:setUpperCornerPos(parentPagePosX + 1, yValueForEntry)
  ColonyButton:changeStyle(TEXT_COLOR, INNER_ELEMENT_BACK_COLOR)
  ColonyButton:setOnManualToggle(self:getOnColonyPressed())
  ColonyButton:setCenterText(true)

  yValueForEntry = yValueForEntry + 4
 
  local WorkOrdersButton = ToggleableButtonClass:new(parentPageSizeX - 2, 1, "Manage work orders.", self.document)
  WorkOrdersButton:forceWidthSize(parentPageSizeX - 2)
  WorkOrdersButton:setUpperCornerPos(parentPagePosX + 1, yValueForEntry)
  WorkOrdersButton:changeStyle(TEXT_COLOR, INNER_ELEMENT_BACK_COLOR)
  WorkOrdersButton:setOnManualToggle(self:getOnWorkOrdersPressed())
  WorkOrdersButton:setCenterText(true)

  yValueForEntry = yValueForEntry + 4

  local WorkersButton = ToggleableButtonClass:new(parentPageSizeX - 2, 1, "Manage builders and target inventories.", self.document)
  local x,y = self.monitor.getSize()
  WorkersButton:forceWidthSize(parentPageSizeX - 2)
  WorkersButton:setUpperCornerPos(parentPagePosX + 1, yValueForEntry)
  WorkersButton:changeStyle(TEXT_COLOR, INNER_ELEMENT_BACK_COLOR)
  WorkersButton:setOnManualToggle(self:getOnManageBuildersPressed())
  WorkersButton:setCenterText(true)

  
  self:setBackColor(ELEMENT_BACK_COLOR)

  self:addElement(ColonyButton)
  self:addElement(WorkOrdersButton)
  self:addElement(WorkersButton)
end

function MainMenuPageClass:getOnColonyPressed()
    return function()
        self.document:startEdition()
        local ColonyPage = ColonyPageClass:new(self.monitor, self.parentPage, self.document)
        self.parentPage:addElement(ColonyPage)
        self.document:endEdition()
    end
  end

function MainMenuPageClass:getOnWorkOrdersPressed()
  return function()
      self.document:startEdition()
      local WorkOrderPage = WorkOrderPageClass:new(self.monitor, self.parentPage, self.colonyPeripheral, self.document)
      self.parentPage:addElement(WorkOrderPage)
      self.document:endEdition()
  end
end

function MainMenuPageClass:getOnManageBuildersPressed()
  return function()
    self.document:startEdition()
    local BuilderPage = BuilderPageClass:new(self.monitor, self.parentPage, self.document)
    self.parentPage:addElement(BuilderPage)
    self.document:endEdition()
  end
end


return MainMenuPageClass