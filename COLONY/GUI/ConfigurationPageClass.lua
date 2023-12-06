
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
local ConfigurationPageClass = {}
ConfigurationPageClass.__index = ConfigurationPageClass
setmetatable(ConfigurationPageClass, {__index = CustomPageClass})

function ConfigurationPageClass:new(monitor, parentPage, colonyPeripheral, document)
  self = setmetatable(CustomPageClass:new(monitor, parentPage, document, "MainMenu"), ConfigurationPageClass)

  self.colonyPeripheral = colonyPeripheral

  self:buildCustomPage()

  return self
end

function ConfigurationPageClass:__tostring() 
  return CustomPageClass.__tostring(self)
end

function ConfigurationPageClass:onBuildCustomPage()
    --Remote connection: 
    --# of available wireless peripherals: 
    --Using wireless peripheral: name 
    --Channel: x (press to change)
    --Status: status

    --Colony connection:
    --# of avaible colonies:
    --Using peripheral: name
    --IsRemote: false

    --Me system connection: status
    --#External inventories: x 
    --(Press to view inventories)

    --Automatic refresh rate:10 (press to change)

    --style:
    --Primary: (color 1)
    --Secondary: (color 2)
    --Third: (color 3)

end




return ConfigurationPageClass