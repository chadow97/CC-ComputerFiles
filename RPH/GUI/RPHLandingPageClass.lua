local ObTableClass          = require "GUI.ObTableClass"
local logger                = require "UTIL.logger"
local CustomPageClass       = require "GUI.CustomPageClass"
local MessageManagerClass   = require "RPH.MODEL.MessageManagerClass"

---@class RPHLandingPage: CustomPage
local RPHLandingPageClass = {}
RPHLandingPageClass.__index = RPHLandingPageClass
setmetatable(RPHLandingPageClass, {__index = CustomPageClass})

function RPHLandingPageClass:new( parentPage, document)
  ---@class RPHLandingPage: CustomPage
  local o = setmetatable(CustomPageClass:new(parentPage, document, "RPHLandingPage"), RPHLandingPageClass)

  o.parentPage = parentPage
  o.messageManager = o.document:getManagerForType(MessageManagerClass.TYPE)

  
  o:buildCustomPage()
  return o
end

function RPHLandingPageClass:__tostring() 
    return CustomPageClass.__tostring(self)
  end

function RPHLandingPageClass:onBuildCustomPage()

    local parentPageSizeX, parentPageSizeY = self.parentPage:getSize()
    local parentPagePosX, parentPagePosY = self.parentPage:getPos()

    --[[
    # Request Received:X
    Average request response time: x
    Last request received at: xxhxxs
    Connected Peripherals: x (Press to view all)
    Last request info: 

    Configuaration
    ]]

    self:applyDocumentStyle()
end

return RPHLandingPageClass