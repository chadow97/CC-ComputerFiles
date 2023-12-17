
local logger                = require "UTIL.logger"
local CustomPageClass       = require "GUI.CustomPageClass"
local LabelClass            = require "GUI.LabelClass"
local PageClass             = require "GUI.pageClass"
local ToggleableButtonClass = require "GUI.ToggleableButtonClass"
local PeripheralManagerClass= require "COLONY.MODEL.PeripheralManagerClass"
local ColonyConfigClass = require("COLONY.MODEL.ColonyConfigClass")
local ColonyManagerClass = require("COLONY.MODEL.ColonyManagerClass")
local NumberSelectionPageClass = require("GUI.NumberSelectionPageClass")
local perTypes                 = require("UTIL.perTypes")


-- Define constants

local ELEMENT_BACK_COLOR = colors.red
local INNER_ELEMENT_BACK_COLOR = colors.lime
local TEXT_COLOR = colors.yellow


-- Define the RessourcePage Class 
local ConfigurationPageClass = {}
ConfigurationPageClass.__index = ConfigurationPageClass
setmetatable(ConfigurationPageClass, {__index = CustomPageClass})

function ConfigurationPageClass:new(monitor, parentPage, document)
  self = setmetatable(CustomPageClass:new(monitor, parentPage, document, "Configuration"), ConfigurationPageClass)
  self.peripheralManager = document:getManagerForType(PeripheralManagerClass.TYPE)
  self.colonyManager = document:getManagerForType(ColonyManagerClass.TYPE)


  self:buildCustomPage()

  return self
end

function ConfigurationPageClass:__tostring() 
  return CustomPageClass.__tostring(self)
end

function ConfigurationPageClass:onBuildCustomPage()

    local parentPageSizeX, parentPageSizeY = self.parentPage:getSize()
    local parentPagePosX, parentPagePosY = self.parentPage:getPos()

    local yValueForEntry = parentPagePosY + 1

    self.titleLabel = LabelClass:new(nil, nil, "Configuration" , self.document)
    self.titleLabel:forceWidthSize(parentPageSizeX - 2)
    self.titleLabel:setUpperCornerPos(parentPagePosX + 1, yValueForEntry)
    self.titleLabel:changeStyle(TEXT_COLOR, INNER_ELEMENT_BACK_COLOR)
    self.titleLabel:setCenterText(true)
    self:addElement(self.titleLabel)
    yValueForEntry = yValueForEntry + 4


    self.remoteConnectionPage = PageClass:new(self.monitor,nil, nil, self.document)
    self.remoteConnectionPage:setSize(parentPageSizeX-2, 7)
    self.remoteConnectionPage:setPos(parentPagePosX + 1, yValueForEntry)
    self.remoteConnectionPage:setBackColor(INNER_ELEMENT_BACK_COLOR)
    self.remoteConnectionPage.id= "CONFIG!"
    self.remoteConnectionPage:setOnRefreshCallback(self:getHandleRefreshEvent())
    self:addElement(self.remoteConnectionPage)

    self.connectionLabel = LabelClass:new(nil, nil, "" , self.document)
    self.connectionLabel:forceWidthSize(parentPageSizeX - 4)
    self.connectionLabel:setUpperCornerPos(parentPagePosX + 1, yValueForEntry)
    self.connectionLabel:changeStyle(TEXT_COLOR, INNER_ELEMENT_BACK_COLOR)
    self.connectionLabel:setText(self:getConnectionDetails())
    self.connectionLabel:setMargin(0)
    self.remoteConnectionPage:addElement(self.connectionLabel)

    yValueForEntry = yValueForEntry + 3

    self.channelButton = ToggleableButtonClass:new(nil, nil, "", self.document)
    self.channelButton:changeStyle(TEXT_COLOR, INNER_ELEMENT_BACK_COLOR)
    self.channelButton:setUpperCornerPos(parentPagePosX + 1, yValueForEntry)
    self.channelButton:setMargin(0)
    self.channelButton:setText(self:getChannelDisplay())
    self.channelButton:setOnManualToggle(self:getOnChannelButtonPressed())

    self.remoteConnectionPage:addElement(self.channelButton)

    yValueForEntry = yValueForEntry + 5

    self.colonyLabel = LabelClass:new(nil, nil, "" , self.document)
    self.colonyLabel:forceWidthSize(parentPageSizeX - 2)
    self.colonyLabel:setUpperCornerPos(parentPagePosX + 1, yValueForEntry)
    self.colonyLabel:changeStyle(TEXT_COLOR, INNER_ELEMENT_BACK_COLOR)
    self.colonyLabel:setText(self:getColonyDetails())
    self:addElement(self.colonyLabel)

    yValueForEntry = yValueForEntry + 8

    self.meLabel = LabelClass:new(nil, nil, "" , self.document)
    self.meLabel:forceWidthSize(parentPageSizeX - 2)
    self.meLabel:setUpperCornerPos(parentPagePosX + 1, yValueForEntry)
    self.meLabel:changeStyle(TEXT_COLOR, INNER_ELEMENT_BACK_COLOR)
    self.meLabel:setText(self:getMeDetails())
    self:addElement(self.meLabel)

    --Me system connection: status
    --#External inventories: x 
    --(Press to view inventories)

    --Automatic refresh rate:10 (press to change)

    --style:
    --Primary: (color 1)
    --Secondary: (color 2)
    --Third: (color 3)

    self:setBackColor(ELEMENT_BACK_COLOR)
end

function ConfigurationPageClass:getHandleRefreshEvent()
    return function (connectionPage, eventName, ...)

        self.document:startEdition()
        self.peripheralManager:forceCompleteRefresh()

        self.connectionLabel:setText(self:getConnectionDetails())
        self.channelButton:setText(self:getChannelDisplay())
        self.document:registerCurrentAreaAsDirty(connectionPage)
        self.document:endEdition()
        return false
    end
end

function ConfigurationPageClass:getConnectionDetails()
    local connectionPeripherals = self.peripheralManager:getLocalWirelessPeripherals()
    local nAvail = 0
    local name = "No available peripheral"
    local status = "Error"

    if connectionPeripherals then
        nAvail = #connectionPeripherals
        if nAvail >= 1 then
            name = connectionPeripherals[1].name
            if self.peripheralManager:isRemoteConnectionValid() then
                status = "Valid!"
            end
        end
    end
    
    return string.format(
[[
Remote connection: 
# of available wireless peripherals: %s
Using wireless peripheral: %s

Status: %s
]],
nAvail,
name,
status
        )
end

function ConfigurationPageClass:getColonyDetails()
    local colonyPers = self.peripheralManager:getPeripherals(perTypes.colony_integrator)
    local nAvail = 0
    local name = "Unknown name"
    local id = "No colony peripheral"
    local status = "Error"

    if colonyPers then
        nAvail = #colonyPers
        if nAvail >= 1 then
            local mainColonyPer = self.colonyManager:getColony()
            name = mainColonyPer.name
            id = colonyPers[1]:getUniqueKey()
            if not mainColonyPer then
                status = "No colony peripherals"
            elseif mainColonyPer.isActive then
                status = "Valid!"
            end
        end
    end
    
    return string.format(
[[
Colony information: 
# of colony peripherals: %s
Using : %s
Colony name: %s
Status: %s
]],
nAvail,
id,
name,
status)
end

function ConfigurationPageClass:getMeDetails()
    local MePers = self.peripheralManager:getPeripherals(perTypes.me_bridge)
    local nAvail = 0
    local name = "Unknown name"

    if MePers then
        nAvail = #MePers
        if nAvail >= 1 then
            local mainMePer = MePers[1]
            name = mainMePer.name
        end
    end
    
    return string.format(
[[
Me system information: 
# of Me peripherals: %s
Using : %s
]],
nAvail,
name)
end

function ConfigurationPageClass:getChannelDisplay()
    local channel = self.document.config:get(ColonyConfigClass.configs.proxy_peripherals_channel)
    return string.format("Channel: %s (Press to change!)", channel)
end

function ConfigurationPageClass:getOnChannelButtonPressed()
    return function()
        self.parentPage:addElement(NumberSelectionPageClass:new(self.monitor,self.parentPage, self.document, "New channel:", 0, rednet.MAX_ID_CHANNELS))
    end
end

function ConfigurationPageClass:onResumeAfterContextLost(newChannel)
    self.document:startEdition()
    self.peripheralManager:forceCompleteRefresh()
    self.document.config:set(ColonyConfigClass.configs.proxy_peripherals_channel, newChannel)
    self.connectionLabel:setText(self:getConnectionDetails())
    self.channelButton:setText(self:getChannelDisplay())
    self.document:registerCurrentAreaAsDirty(self.remoteConnectionPage)
    CustomPageClass.onResumeAfterContextLost(self)
    self.document:endEdition()
end

return ConfigurationPageClass