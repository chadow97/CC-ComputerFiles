
local ToggleableButtonClass = require "GUI.ToggleableButtonClass"
local logger                = require "UTIL.logger"
local WorkOrderPageClass    = require "COLONY.GUI.WorkOrderPageClass"
local BuilderPageClass      = require "COLONY.GUI.BuilderPageClass"
local CustomPageClass       = require "GUI.CustomPageClass"
local ColonyPageClass       = require "COLONY.GUI.ColonyPageClass"
local RequestPageClass      = require "COLONY.GUI.RequestPageClass"
local LabelClass            = require "GUI.LabelClass"
local MeInfoPageClass       = require "COLONY.GUI.MeInfoPageClass"

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

  local ColonyLogoLabel = LabelClass:new(1,1, self:getLogoAsString(), self.document)
  ColonyLogoLabel:setUpperCornerPos(parentPagePosX + (parentPageSizeX - 33)/2, yValueForEntry)
  ColonyLogoLabel:forceWidthSize(33)
  ColonyLogoLabel:forceHeightSize(14)
  ColonyLogoLabel:changeStyle(TEXT_COLOR, INNER_ELEMENT_BACK_COLOR)
  self:addElement(ColonyLogoLabel)

  local yValueForEntry = parentPagePosY + 16

  local ColonyButton = ToggleableButtonClass:new(1, 1, "General colony information", self.document)
  ColonyButton:forceWidthSize(parentPageSizeX - 2)
  ColonyButton:setUpperCornerPos(parentPagePosX + 1, yValueForEntry)
  ColonyButton:changeStyle(TEXT_COLOR, INNER_ELEMENT_BACK_COLOR)
  ColonyButton:setOnManualToggle(self:getOnColonyPressed())
  ColonyButton:setCenterText(true)
  self:addElement(ColonyButton)

  yValueForEntry = yValueForEntry + 4
 
  local WorkOrdersButton = ToggleableButtonClass:new(parentPageSizeX - 2, 1, "Manage work orders", self.document)
  WorkOrdersButton:forceWidthSize(parentPageSizeX - 2)
  WorkOrdersButton:setUpperCornerPos(parentPagePosX + 1, yValueForEntry)
  WorkOrdersButton:changeStyle(TEXT_COLOR, INNER_ELEMENT_BACK_COLOR)
  WorkOrdersButton:setOnManualToggle(self:getOnWorkOrdersPressed())
  WorkOrdersButton:setCenterText(true)
  self:addElement(WorkOrdersButton)

  yValueForEntry = yValueForEntry + 4
 
  local RequestsButton = ToggleableButtonClass:new(parentPageSizeX - 2, 1, "Manage requests", self.document)
  RequestsButton:forceWidthSize(parentPageSizeX - 2)
  RequestsButton:setUpperCornerPos(parentPagePosX + 1, yValueForEntry)
  RequestsButton:changeStyle(TEXT_COLOR, INNER_ELEMENT_BACK_COLOR)
  RequestsButton:setOnManualToggle(self:getOnRequestsPressed())
  RequestsButton:setCenterText(true)
  self:addElement(RequestsButton)

  yValueForEntry = yValueForEntry + 4

  local WorkersButton = ToggleableButtonClass:new(parentPageSizeX - 2, 1, "Manage builders and target inventories", self.document)
  WorkersButton:forceWidthSize(parentPageSizeX - 2)
  WorkersButton:setUpperCornerPos(parentPagePosX + 1, yValueForEntry)
  WorkersButton:changeStyle(TEXT_COLOR, INNER_ELEMENT_BACK_COLOR)
  WorkersButton:setOnManualToggle(self:getOnManageBuildersPressed())
  WorkersButton:setCenterText(true)
  self:addElement(WorkersButton)

  yValueForEntry = yValueForEntry + 4

  local MeInfoButton = ToggleableButtonClass:new(parentPageSizeX - 2, 1, "Me system information", self.document)
  MeInfoButton:forceWidthSize(parentPageSizeX - 2)
  MeInfoButton:setUpperCornerPos(parentPagePosX + 1, yValueForEntry)
  MeInfoButton:changeStyle(TEXT_COLOR, INNER_ELEMENT_BACK_COLOR)
  MeInfoButton:setOnManualToggle(self:getOnMeInfoPressed())
  MeInfoButton:setCenterText(true)
  self:addElement(MeInfoButton)

  self:setBackColor(ELEMENT_BACK_COLOR)

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

function MainMenuPageClass:getOnRequestsPressed()
    return function()
        self.document:startEdition()
        local WorkOrderPage = RequestPageClass:new(self.monitor, self.parentPage, self.document)
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

function MainMenuPageClass:getOnMeInfoPressed()
    return function()
      self.document:startEdition()
      local meInfoPage = MeInfoPageClass:new(self.monitor, self.parentPage, self.document)
      self.parentPage:addElement(meInfoPage)
      self.document:endEdition()
    end
  end

function MainMenuPageClass:getLogoAsString()
    return 
[[
    ~        ==================
       _T    I Colony Manager I
^^    // \   ==================
      ][O]    ^^      ,-~ ~
   /''-I_I         _II____
__/_  /   \       / ''   /'\_,_
  | II--'''' \,  :--..,_/,.-\ 
; '/__\,.--';|   |[] .-.| O |
:' |  | []  -|   ''--:.;[,.''
'  |[]|,.--'' '',   ''-,.    
* ASCII by Steven Maddison
* from https://www.asciiart.eu/
]] 


end


return MainMenuPageClass