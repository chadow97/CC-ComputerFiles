local PageClass = require "GUI.pageClass"
local RessourceFetcherClass = require "MODEL.ressourceFetcherClass"
local ObTableClass          = require "GUI.obTableClass"
local LogClass              = require "GUI.logClass"
local ToggleableButtonClass = require "GUI.toggleableButtonClass"
local RessourceClass        = require "MODEL.ressourceClass"
local MeUtils               = require "UTIL.meUtils"
local logger                = require "UTIL.logger"
local WorkOrderPageClass    = require "COLONYGUI.workOrderPageClass"

-- Define constants

local ELEMENT_BACK_COLOR = colors.red
local INNER_ELEMENT_BACK_COLOR = colors.lime
local TEXT_COLOR = colors.yellow


-- Define the RessourcePage Class 
local MainMenuPageClass = {}
MainMenuPageClass.__index = MainMenuPageClass
setmetatable(MainMenuPageClass, {__index = PageClass})



function MainMenuPageClass:new(monitor, parentPage, colonyPeripheral, externalChest)
  self = setmetatable(PageClass:new(monitor), MainMenuPageClass)
  self.monitor = monitor
  self.colonyPeripheral = colonyPeripheral
  self.externalChest = externalChest
  self:buildMainMenuPage(parentPage)
  return self
end

function MainMenuPageClass:buildMainMenuPage(parentPage)
 
  local parentPageSizeX, parentPageSizeY = parentPage:getSize()
  local parentPagePosX, parentPagePosY = parentPage:getPos()
 
  local WorkOrdersButton = ToggleableButtonClass:new(parentPageSizeX - 2, 1, "Manage work orders.")
  WorkOrdersButton:forceWidthSize(parentPageSizeX - 2)
  WorkOrdersButton:setUpperCornerPos(parentPagePosX + 1, parentPagePosY + 1)
  WorkOrdersButton:changeStyle(TEXT_COLOR, INNER_ELEMENT_BACK_COLOR)
  WorkOrdersButton:setOnManualToggle(self:getOnWorkOrdersPressed())


  self:setBlockDraw(true)
  self:setBackColor(ELEMENT_BACK_COLOR)

  self:addElement(WorkOrdersButton)
  self:setBlockDraw(false)
end

function MainMenuPageClass:getOnWorkOrdersPressed()
  return function()      
      local WorkOrderPageClass = WorkOrderPageClass:new(self.monitor, self.parentPage, self.colonyPeripheral, self.externalChest)
      self.parentPage:addElement(WorkOrderPageClass)
  end
end


return MainMenuPageClass