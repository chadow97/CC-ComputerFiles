local PageClass = require "GUI.pageClass"
local RessourceFetcherClass = require "MODEL.ressourceFetcherClass"
local ObTableClass          = require "GUI.obTableClass"
local LogClass              = require "GUI.logClass"
local ToggleableButtonClass = require "GUI.toggleableButtonClass"
local RessourceClass        = require "MODEL.ressourceClass"
local MeUtils               = require "UTIL.meUtils"

-- Define constants

local ELEMENT_BACK_COLOR = colors.red
local INNER_ELEMENT_BACK_COLOR = colors.lime
local TEXT_COLOR = colors.yellow
local LOG_HEIGHT = 10

-- Define the RessourcePage Class 
local RessourcePageClass = {}
RessourcePageClass.__index = RessourcePageClass
setmetatable(RessourcePageClass, {__index = PageClass})



function RessourcePageClass:new(monitor, parentPage, colonyPeripheral, workOrderId, externalChest)
  self = setmetatable(PageClass.new(monitor), RessourcePageClass)

  self.ressourceFetcher = RessourceFetcherClass:new(colonyPeripheral, workOrderId, externalChest)
  


  self:buildRessourcePage(parentPage)
  return self
end

function RessourcePageClass:buildRessourcePage(parentPage)
 
  local parentPageSizeX, parentPageSizeY = parentPage:getSize()
  local parentPagePosX, parentPagePosY = parentPage:getPosition()

  local ressourceTable = ObTableClass:new(self.monitor, 1,1, "ressource")
  ressourceTable:setBlockDraw(true)
  ressourceTable:setDataFetcher(self.ressourceFetcher)
  ressourceTable:setDisplayKey(false)
  ressourceTable:setRowHeight(8)
  ressourceTable:changeStyle(ELEMENT_BACK_COLOR, INNER_ELEMENT_BACK_COLOR, TEXT_COLOR)
  ressourceTable:setColumnCount(3)
  ressourceTable:setHasManualRefresh(true)
  ressourceTable:setSize(parentPageSizeX, parentPageSizeY - 4 - LOG_HEIGHT)
  ressourceTable:setPosition(parentPagePosX,parentPagePosY)
  ressourceTable:setOnPressFunc(RessourcePageClass.onRessourcePressed)
  local _,_,_, ressourceTableEndY = ressourceTable:getArea()
  
  local logElement = LogClass:new(1,1,"")
  logElement:setUpperCornerPos(parentPagePosY + 1, ressourceTableEndY + 1)
  logElement:forceWidthSize(parentPageSizeX - 2)
  logElement:forceHeightSize(LOG_HEIGHT)
  logElement:changeStyle(nil, INNER_ELEMENT_BACK_COLOR)
  
  local SendAllButton = ToggleableButtonClass:new(1, 1, "Send/Craft ALL!")
  SendAllButton:forceWidthSize(parentPageSizeX - 2)
  SendAllButton:setUpperCornerPos(parentPagePosX + 1, ressourceTableEndY + 1 + LOG_HEIGHT)
  SendAllButton:changeStyle(nil, INNER_ELEMENT_BACK_COLOR)
  SendAllButton:setOnManualToggle(RessourcePageClass.onSendAllPressed)

  self:setBlockDraw(true)
  self:setBackColor(ELEMENT_BACK_COLOR)

  self:add(ressourceTable)
  self:add(SendAllButton)
  self:add(logElement)
  self:setBlockDraw(false)
  ressourceTable:setBlockDraw(false)

end

function RessourcePageClass.onRessourcePressed(positionInTable, isKey, ressource)
  -- do nothing if key, it shouldnt be displayed
  if  isKey then
      return
  end
  local actionToDo = ressource:getActionToDo()
  if actionToDo == RessourceClass.ACTIONS.SENDTOEXTERNAL then
      MeUtils.exportItem(ressource.itemId, ressource.missingWithExternalInventory)
  elseif actionToDo == RessourceClass.ACTIONS.CRAFT then
      MeUtils.craftItem(ressource.itemId, ressource.missingWithExternalInventoryAndMe)
  end
end

function RessourcePageClass.onSendAllPressed()

end

return RessourcePageClass


-- STATIC FUNCTIONS
