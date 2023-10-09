local PageClass = require "GUI.pageClass"
local RessourceFetcherClass = require "MODEL.ressourceFetcherClass"
local ObTableClass          = require "GUI.obTableClass"
local LogClass              = require "GUI.logClass"
local ToggleableButtonClass = require "GUI.toggleableButtonClass"
local RessourceClass        = require "MODEL.ressourceClass"
local MeUtils               = require "UTIL.meUtils"
local logger                = require "UTIL.logger"

-- Define constants

local ELEMENT_BACK_COLOR = colors.red
local INNER_ELEMENT_BACK_COLOR = colors.lime
local TEXT_COLOR = colors.yellow
local SEND_ALL_TEXT_COLOR = colors.black

local LOG_HEIGHT = 10

local SEND_ALL_UNTOGGLED_TEXT = "Press to send/craft missing ressources."
local SEND_ALL_TOGGLED_TEXT = "Sending and crafting! Press to stop."

-- Define the RessourcePage Class 
local RessourcePageClass = {}
RessourcePageClass.__index = RessourcePageClass
setmetatable(RessourcePageClass, {__index = PageClass})



function RessourcePageClass:new(monitor, parentPage, colonyPeripheral, workOrderId, externalChest)
  self = setmetatable(PageClass.new(monitor), RessourcePageClass)

  self.ressourceFetcher = RessourceFetcherClass:new(colonyPeripheral, workOrderId, externalChest)
  self.isSendingAll = false;

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
  ressourceTable:SetOnPostRefreshDataCallback(self:getOnPostTableRefreshCallback())
  local _,_,_, ressourceTableEndY = ressourceTable:getArea()
  
  local logElement = LogClass:new(1,1)
  logElement:setUpperCornerPos(parentPagePosY + 1, ressourceTableEndY + 1)
  logElement:forceWidthSize(parentPageSizeX - 2)
  logElement:forceHeightSize(LOG_HEIGHT)
  logElement:changeStyle(nil, INNER_ELEMENT_BACK_COLOR)
  self.logElement = logElement
  
  local SendAllButton = ToggleableButtonClass:new(1, 1, SEND_ALL_UNTOGGLED_TEXT)
  SendAllButton:forceWidthSize(parentPageSizeX - 2)
  SendAllButton:setUpperCornerPos(parentPagePosX + 1, ressourceTableEndY + 1 + LOG_HEIGHT)
  SendAllButton:changeStyle(SEND_ALL_TEXT_COLOR, INNER_ELEMENT_BACK_COLOR, INNER_ELEMENT_BACK_COLOR, SEND_ALL_TEXT_COLOR)
  SendAllButton:setOnManualToggle(self:getOnSendAllPressedCallback())
  SendAllButton:disableAutomaticUntoggle()
  SendAllButton:setOnDrawCallback(self:getOnDrawSendAllButton())

  self:setBlockDraw(true)
  self:setBackColor(ELEMENT_BACK_COLOR)

  self:add(ressourceTable)
  self:add(SendAllButton)
  self:add(logElement)
  self:setBlockDraw(false)
  ressourceTable:setBlockDraw(false)

end

function RessourcePageClass:getOnDrawSendAllButton()
  return function(button)
    if button.toggled then
      button:setText(SEND_ALL_TOGGLED_TEXT)
    else
      button:setText(SEND_ALL_UNTOGGLED_TEXT)
    end
  end

end

function RessourcePageClass:getOnSendAllPressedCallback()
  
  local onSendAllPressedCallback = function()
    self.isSendingAll = not self.isSendingAll
  end
  
  return onSendAllPressedCallback
  
end

function RessourcePageClass:getOnPostTableRefreshCallback()
  return function()
    if not self.isSendingAll then
      return
    end
    local ressources = self.ressourceFetcher:getAllRessourcesWithoutRefreshing()
    local freeCpus = MeUtils.getAllFreeCpus()
    local nextFreeCpu = 1
    local hasFreeCpuLeft = #freeCpus > 0

    -- ressources should be ordered by status and name
    for _, ressource in ipairs(ressources) do
      if ressource.status == RessourceClass.RESSOURCE_STATUSES.no_missing or
         ressource.status == RessourceClass.RESSOURCE_STATUSES.all_in_external_inv or
         ressource.status == RessourceClass.RESSOURCE_STATUSES.missing_not_craftable then
          -- nothing we can do for these status and because its sorted, all the others 
          -- will be the same status so we can stop the loop
          break;
         end
      if ressource.status == RessourceClass.RESSOURCE_STATUSES.all_in_me_or_ex then
        MeUtils.exportItem(ressource.itemId, ressource.missingWithExternalInventory)
        local lineToOutput = string.format("Sent %s %s to externalStorage", ressource.missingWithExternalInventory, ressource.itemId)
        self.logElement:addLine(lineToOutput)
      end
      if ressource.status == RessourceClass.RESSOURCE_STATUSES.craftable then
          if not MeUtils.isItemBeingCrafted(ressource.itemId) and hasFreeCpuLeft then
            MeUtils.craftItem(ressource.itemId, ressource.missingWithExternalInventoryAndMe)
            local lineToOutput = string.format("Crafting %s %s", ressource.missingWithExternalInventoryAndMe, ressource.itemId)
            self.logElement:addLine(lineToOutput)
            nextFreeCpu = nextFreeCpu + 1
            hasFreeCpuLeft = #freeCpus >= nextFreeCpu
          end
      end
    end
  end
end

-- Define static functions 
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

return RessourcePageClass