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

---@class RedstoneIntegratorDetailPageClass: CustomPage
local RedstoneIntegratorDetailPageClass = {}
RedstoneIntegratorDetailPageClass.__index = RedstoneIntegratorDetailPageClass
setmetatable(RedstoneIntegratorDetailPageClass, {__index = CustomPageClass})

function RedstoneIntegratorDetailPageClass:new(monitor, parentPage, document, Ri)
  ---@class RedstoneIntegratorDetailPageClass: CustomPage
  local o = setmetatable(CustomPageClass:new(monitor, parentPage, document, "Redstone integrator page"), RedstoneIntegratorDetailPageClass)

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

    local containerPage = PageClass:new(self.monitor,2, 2, self.document)

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

    local NicknameButton = ToggleableButtonClass:new(nil, nil,"", self.document)
    NicknameButton:forceWidthSize(InsertsWidth)
    NicknameButton:setMargin(0)
    NicknameButton:setUpperCornerPos(parentPagePosX + 2, nextElementYPos)
    NicknameButton:applyDocumentStyle()
    NicknameButton:setText(self:getNicknameString())
    NicknameButton:setOnManualToggle(self:getOnNicknamePressed())

    containerPage:addElement(NicknameButton)

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

    local AssInvButton = ToggleableButtonClass:new(nil, nil,"", self.document)
    AssInvButton:forceWidthSize(InsertsWidth)
    AssInvButton:setMargin(0)
    AssInvButton:setUpperCornerPos(parentPagePosX + 2, nextElementYPos)
    AssInvButton:applyDocumentStyle()
    AssInvButton:setText(self:getAssociatedInventoryString())
    AssInvButton:setOnManualToggle()
    containerPage:addElement(AssInvButton)

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
  local assInventory = self.Ri.associatedInventory or "No associated inventory"
  return "Associated inventory: " .. assInventory .. " (Press to edit)"
end

function RedstoneIntegratorDetailPageClass:getOnNicknamePressed()
  return function()
      self.document:startEdition()
      --TODO
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