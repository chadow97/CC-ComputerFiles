local ObTableClass          = require "GUI.ObTableClass"
local logger                = require "UTIL.logger"
local CustomPageClass       = require "GUI.CustomPageClass"
local PeripheralManagerClass    = require "COMMON.MODEL.PeripheralManagerClass"
local PeripheralClass           = require "COMMON.MODEL.PeripheralClass"
local RedstoneIntegratorManagerClass = require "COMMON.MODEL.RedstoneIntegratorManagerClass"
local LabelClass = require "GUI.LabelClass"
local PageClass  = require "GUI.PageClass"
local ColonyConfigClass = require "COLONY.MODEL.ColonyConfigClass"
local ToggleableButtonClass = require "GUI.ToggleableButtonClass"
local TextSelectionPageClass= require "GUI.TextSelectionPageClass"
local ObjectSelectionPageClass = require "GUI.ObjectSelectionPageClass"
local InventoryManagerClass    = require "COMMON.MODEL.InventoryManagerClass"

---@class RedstoneIntegratorDetailPageClass: CustomPage
local RedstoneIntegratorDetailPageClass = {}
RedstoneIntegratorDetailPageClass.__index = RedstoneIntegratorDetailPageClass
setmetatable(RedstoneIntegratorDetailPageClass, {__index = CustomPageClass})

function RedstoneIntegratorDetailPageClass:new( parentPage, document, Ri)
  ---@class RedstoneIntegratorDetailPageClass: CustomPage
  local o = setmetatable(CustomPageClass:new( parentPage, document, "Redstone integrator page"), RedstoneIntegratorDetailPageClass)
  o.inventoryManager = o.document:getManagerForType(InventoryManagerClass.TYPE)

  o.parentPage = parentPage
  o.Ri = Ri
  
  o:buildCustomPage()
  return o
end

function RedstoneIntegratorDetailPageClass:__tostring() 
    return CustomPageClass.__tostring(self)
  end

function RedstoneIntegratorDetailPageClass:onBuildCustomPage()


  local parentPageSizeX, parentPageSizeY = self.parentPage:getSize()
  local parentPagePosX, parentPagePosY = self.parentPage:getPos()

    local containerPage = PageClass:new(2, 2, self.document)

    local containerPageWidth = parentPageSizeX -2
    local insertsWidth = containerPageWidth - 2
    local nextElementYPos = parentPagePosY + 1
    containerPage:setSize(containerPageWidth, 6)
    containerPage:setPos(parentPagePosX + 1, nextElementYPos)

    containerPage:setBackColor(self.document.style.secondary)

    self:addElement(containerPage)

    local InsertsWidth = insertsWidth - 2
    nextElementYPos = nextElementYPos + 1


    local Idlabel = LabelClass:new(nil, nil, self:getIdString() , self.document)
    Idlabel:forceWidthSize(InsertsWidth)
    Idlabel:setMargin(0)
    Idlabel:setUpperCornerPos(parentPagePosX + 2, nextElementYPos)
    Idlabel:applyDocumentStyle()
    containerPage:addElement(Idlabel)

    nextElementYPos = nextElementYPos + 1

    self.NicknameButton = ToggleableButtonClass:new(nil, nil,"", self.document)
    self.NicknameButton:forceWidthSize(InsertsWidth)
    self.NicknameButton:setMargin(0)
    self.NicknameButton:setUpperCornerPos(parentPagePosX + 2, nextElementYPos)
    self.NicknameButton:applyDocumentStyle()
    self.NicknameButton:setText(self:getNicknameString())
    self.NicknameButton:setOnManualToggle(self:getOnNicknamePressed())

    containerPage:addElement(self.NicknameButton)

    nextElementYPos = nextElementYPos + 1

    local StateButton = ToggleableButtonClass:new(nil, nil,"", self.document)
    StateButton:forceWidthSize(InsertsWidth)
    StateButton:setMargin(0)
    StateButton:setUpperCornerPos(parentPagePosX + 2, nextElementYPos)
    StateButton:applyDocumentStyle()
    StateButton:setText(self:getStateString())
    StateButton:setOnManualToggle(self:getOnTogglePressed())
    self.StateButton = StateButton
    containerPage:addElement(StateButton)

    nextElementYPos = nextElementYPos + 1

    self.AssInvButton = ToggleableButtonClass:new(nil, nil,"", self.document)
    self.AssInvButton:forceWidthSize(InsertsWidth)
    self.AssInvButton:setMargin(0)
    self.AssInvButton:setUpperCornerPos(parentPagePosX + 2, nextElementYPos)
    self.AssInvButton:applyDocumentStyle()
    self.AssInvButton:setText(self:getAssociatedInventoryString())
    self.AssInvButton:setOnManualToggle(self:getOnAssociatedInventoryButtonPressed())
    containerPage:addElement(self.AssInvButton)

    self:applyDocumentStyle()
end

function RedstoneIntegratorDetailPageClass:getIdString()
  return "ID: " .. self.Ri.name
end

function RedstoneIntegratorDetailPageClass:getNicknameString()

  local nicknameToDisplay = self.Ri.nickname or "No nickname"

  return "Nickname: " .. nicknameToDisplay .. " (Press to edit)"
end

function RedstoneIntegratorDetailPageClass:getStateString()
  return "State: " .. tostring(self.Ri.active) .. " (Press to toggle)"
end

function RedstoneIntegratorDetailPageClass:getAssociatedInventoryString()

  return "Associated inventory: " .. self.Ri:getAssociatedInventoryName() .. " (Press to edit)"
end

function RedstoneIntegratorDetailPageClass:getOnNicknameModified()
  return function (newNickname)
    self.document:startEdition()
    self.Ri:setNickname(newNickname)
    self.NicknameButton:setText(self:getNicknameString())
    self.document:registerCurrentAreaAsDirty(self.NicknameButton)
    self.document:endEdition()
  end
end

function RedstoneIntegratorDetailPageClass:getOnNicknamePressed()
  return function()
      local page = TextSelectionPageClass:new(self.parentPage, self.document, "New nickname:")
      self.parentPage:pushPage(page, self:getOnNicknameModified())
  end
end

function RedstoneIntegratorDetailPageClass:getOnAssociatedInventoryButtonPressed()
  return function()
      local currentlySelectedKey = nil
      if self.Ri.associatedInventory then
        currentlySelectedKey = self.Ri.associatedInventory:getUniqueKey()
      end
      local page = ObjectSelectionPageClass:new(self.parentPage, self.document, "Select new associated inventory:", self.inventoryManager, currentlySelectedKey)
      self.parentPage:pushPage(page, self:getOnAssociatedInventoryModified())
  end
end

function RedstoneIntegratorDetailPageClass:getOnAssociatedInventoryModified()
  return function (newInventory)
    self.document:startEdition()
    self.Ri:setAssociatedInventory(newInventory)
    self.AssInvButton:setText(self:getAssociatedInventoryString())
    self.document:registerCurrentAreaAsDirty(self.AssInvButton)
    self.document:endEdition()
  end
end

function RedstoneIntegratorDetailPageClass:getOnTogglePressed()
  return function()
      self.document:startEdition()
      self.Ri:toggleState()
      self.StateButton:setText(self:getStateString())
      self.document:registerCurrentAreaAsDirty(self.StateButton)
      self.document:endEdition()
  end
end



return RedstoneIntegratorDetailPageClass