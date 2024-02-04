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

    local parentPagePosX, parentPagePosY = self.parentPage:getPos()

    local containerPage = PageClass:new(self.monitor,2, 2, self.document)

    local parentPagePosX  = parentPagePosX
    local parentPageWidth = self.parentPage:getSize()
    local insertsWidth = parentPageWidth - 2
    local nextElementYPos = parentPagePosY
    containerPage:setSize(insertsWidth, 6)
    containerPage:setPos(parentPagePosX + 1, nextElementYPos)
    containerPage:setBackColor(self.document.style.secondary)

    self.parentPage:addElement(containerPage)

    local InsertsWidth = insertsWidth - 2
    nextElementYPos = nextElementYPos + 1


    local Idlabel = LabelClass:new(nil, nil, self:getIDstring() , self.document)
    Idlabel:forceWidthSize(InsertsWidth)
    Idlabel:setMargin(0)
    Idlabel:setUpperCornerPos(parentPagePosX + 2, nextElementYPos)
    Idlabel:applyDocumentStyle()
    containerPage:addElement(Idlabel)

    --[[
      ID:
      Nickame: (Press to edit)
      State: (Press to toggle)
      Associated inventory: (Press to change)
    ]]  


    self:applyDocumentStyle()
end

function RedstoneIntegratorDetailPageClass:getIDstring()
  return "ID: " .. self.Ri.name
end



return RedstoneIntegratorDetailPageClass