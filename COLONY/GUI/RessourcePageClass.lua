local RessourceFetcherClass = require "MODEL.RessourceFetcherClass"
local ObTableClass          = require "GUI.ObTableClass"
print("ressource page")
local LogClass              = require "GUI.LogClass"
local ToggleableButtonClass = require "GUI.ToggleableButtonClass"
local RessourceClass        = require "COLONY.MODEL.RessourceClass"
local MeUtils               = require "UTIL.meUtils"
local logger                = require "UTIL.logger"
local CustomPageClass       = require "GUI.CustomPageClass"
local PeripheralManagerClass= require "COMMON.MODEL.PeripheralManagerClass"

local LOG_HEIGHT = 10

local SEND_ALL_UNTOGGLED_TEXT = "Press to send/craft missing ressources."
local SEND_ALL_TOGGLED_TEXT = "Sending and crafting! Press to stop."

---@class RessourcePage: CustomPage
local RessourcePageClass = {}
RessourcePageClass.__index = RessourcePageClass
setmetatable(RessourcePageClass, {__index = CustomPageClass})

function RessourcePageClass:new(monitor, parentPage, workOrderId, inventoryOb, document)
  self = setmetatable(CustomPageClass:new(monitor, parentPage, document, "ressourcePage"), RessourcePageClass)

  local peripheralManager = document:getManagerForType(PeripheralManagerClass.TYPE)
  local colonyPeripheral = peripheralManager:getMainColonyPeripheral()

  self.ressourceFetcher = RessourceFetcherClass:new(colonyPeripheral, workOrderId, inventoryOb, document)
  self.isSendingAll = false;
  self.inventoryOb = inventoryOb
  self.logElement = nil

  self:buildCustomPage()
  self.logElement:addLine("Sending to: " .. tostring(inventoryOb))
  return self
end

function RessourcePageClass:__tostring() 
  return CustomPageClass.__tostring(self)
end

function RessourcePageClass:onBuildCustomPage()
 
  local parentPageSizeX, parentPageSizeY = self.parentPage:getSize()
  local parentPagePosX, parentPagePosY = self.parentPage:getPos()

  local ressourceTable = ObTableClass:new(self.monitor, 1,1, "ressource", nil, nil, self.document)
  ressourceTable:setDataFetcher(self.ressourceFetcher)
  ressourceTable:setDisplayKey(false)
  ressourceTable:setRowHeight(8)
  ressourceTable:applyDocumentStyle()
  ressourceTable:setColumnCount(3)
  ressourceTable:setHasManualRefresh(true)
  ressourceTable:setSize(parentPageSizeX, parentPageSizeY - 4 - LOG_HEIGHT)
  ressourceTable:setPos(parentPagePosX,parentPagePosY)
  ressourceTable:setOnTableElementPressedCallback(self:getOnRessourcePressed())
  ressourceTable:setOnPostRefreshDataCallback(self:getOnPostTableRefreshCallback())
  local _,_,_, ressourceTableEndY = ressourceTable:getArea()
  
  local logElement = LogClass:new(1,1,"", self.document)
  logElement:setUpperCornerPos(parentPagePosY + 1, ressourceTableEndY + 1)
  logElement:forceWidthSize(parentPageSizeX - 2)
  logElement:forceHeightSize(LOG_HEIGHT)
  logElement:applyDocumentStyle()
  self.logElement = logElement
  
  local SendAllButton = ToggleableButtonClass:new(1, 1, SEND_ALL_UNTOGGLED_TEXT, self.document)
  SendAllButton:forceWidthSize(parentPageSizeX - 2)
  SendAllButton:setUpperCornerPos(parentPagePosX + 1, ressourceTableEndY + 1 + LOG_HEIGHT)

  SendAllButton:applyDocumentStyle()
  SendAllButton:setOnManualToggle(self:getOnSendAllPressedCallback())
  SendAllButton:disableAutomaticUntoggle()
  SendAllButton:setOnDrawCallback(self:getOnDrawSendAllButton())

  self:applyDocumentStyle()

  self:addElement(ressourceTable)
  self:addElement(SendAllButton)
  self:addElement(logElement)

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
        MeUtils.exportItem(ressource.itemId, ressource.missingWithExternalInventory, self.inventoryOb:getUniqueKey())
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

function RessourcePageClass:getOnRessourcePressed()
    local ressourcePage = self
    return function (positionInTable, isKey, ressource)
          -- do nothing if key, it shouldnt be displayed
        if  isKey then
            return
        end
        local actionToDo = ressource:getActionToDo()
        if actionToDo == RessourceClass.ACTIONS.SENDTOEXTERNAL then
            MeUtils.exportItem(ressource.itemId, ressource.missingWithExternalInventory,  ressourcePage.inventoryOb:getUniqueKey())
        elseif actionToDo == RessourceClass.ACTIONS.CRAFT then
            MeUtils.craftItem(ressource.itemId, ressource.missingWithExternalInventoryAndMe)
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