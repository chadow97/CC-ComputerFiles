
local logger                = require "UTIL.logger"
local CustomPageClass       = require "GUI.CustomPageClass"
local LabelClass            = require "GUI.LabelClass"
local PageClass             = require "GUI.pageClass"
local ToggleableButtonClass = require "GUI.ToggleableButtonClass"
local PeripheralManagerClass= require "COMMON.MODEL.PeripheralManagerClass"
local ColonyConfigClass = require("COLONY.MODEL.ColonyConfigClass")
local ColonyManagerClass = require("COLONY.MODEL.ColonyManagerClass")
local NumberSelectionPageClass = require("GUI.NumberSelectionPageClass")
local perTypes                 = require("UTIL.perTypes")
local ColorSelectionPageClass  = require("GUI.ColorSelectionPageClass")

---@class ConfigurationPage: CustomPage
local ConfigurationPageClass = {}
ConfigurationPageClass.__index = ConfigurationPageClass
setmetatable(ConfigurationPageClass, {__index = CustomPageClass})

function ConfigurationPageClass:new(monitor, parentPage, document)
  self = setmetatable(CustomPageClass:new(monitor, parentPage, document, "Configuration"), ConfigurationPageClass)
  self.peripheralManager = document:getManagerForType(PeripheralManagerClass.TYPE)
  self.colonyManager = document:getManagerForType(ColonyManagerClass.TYPE)
  self.colorLabelMap = {}


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
    self.titleLabel:applyDocumentStyle()
    self.titleLabel:setCenterText(true)
    self:addElement(self.titleLabel)
    yValueForEntry = yValueForEntry + 4


    self.remoteConnectionPage = PageClass:new(self.monitor,nil, nil, self.document)
    self.remoteConnectionPage:setSize(parentPageSizeX-2, 7)
    self.remoteConnectionPage:setPos(parentPagePosX + 1, yValueForEntry)
    self.remoteConnectionPage:setBackColor(self.document.style.secondary)
    self.remoteConnectionPage.id= "CONFIG!"
    self.remoteConnectionPage:setOnRefreshCallback(self:getHandleRefreshEvent())
    self:addElement(self.remoteConnectionPage)

    self.connectionLabel = LabelClass:new(nil, nil, "" , self.document)
    self.connectionLabel:forceWidthSize(parentPageSizeX - 4)
    self.connectionLabel:setUpperCornerPos(parentPagePosX + 1, yValueForEntry)
    self.connectionLabel:changeStyle(self.document.style.tertiary, self.document.style.secondary)
    self.connectionLabel:setText(self:getConnectionDetails())
    self.connectionLabel:setMargin(0)
    self.remoteConnectionPage:addElement(self.connectionLabel)

    yValueForEntry = yValueForEntry + 3

    self.channelButton = ToggleableButtonClass:new(nil, nil, "", self.document)
    self.channelButton:applyDocumentStyle()
    self.channelButton:setUpperCornerPos(parentPagePosX + 1, yValueForEntry)
    self.channelButton:setMargin(0)
    self.channelButton:setText(self:getChannelDisplay())
    self.channelButton:setOnManualToggle(self:getOnChannelButtonPressed())

    self.remoteConnectionPage:addElement(self.channelButton)

    yValueForEntry = yValueForEntry + 5

    self.colonyLabel = LabelClass:new(nil, nil, "" , self.document)
    self.colonyLabel:forceWidthSize(parentPageSizeX - 2)
    self.colonyLabel:setUpperCornerPos(parentPagePosX + 1, yValueForEntry)
    self.colonyLabel:applyDocumentStyle()
    self.colonyLabel:setText(self:getColonyDetails())
    self:addElement(self.colonyLabel)

    yValueForEntry = yValueForEntry + 8

    self.meLabel = LabelClass:new(nil, nil, "" , self.document)
    self.meLabel:forceWidthSize(parentPageSizeX - 2)
    self.meLabel:setUpperCornerPos(parentPagePosX + 1, yValueForEntry)
    self.meLabel:applyDocumentStyle()
    self.meLabel:setText(self:getMeDetails())
    self:addElement(self.meLabel)

    yValueForEntry = yValueForEntry + 6

    self.refreshRateButton = ToggleableButtonClass:new(nil, nil,"", self.document)
    self.refreshRateButton:forceWidthSize(parentPageSizeX - 2)
    self.refreshRateButton:setUpperCornerPos(parentPagePosX + 1, yValueForEntry)
    self.refreshRateButton:applyDocumentStyle()
    self.refreshRateButton:setText(self:getRefreshRateDisplay())
    self.refreshRateButton:setOnManualToggle(self:getOnRefreshRateButtonPressed())
    self:addElement(self.refreshRateButton)

    yValueForEntry = yValueForEntry + 4

    self.stylePage = PageClass:new(self.monitor,nil, nil, self.document)
    self.stylePage:setSize(parentPageSizeX-2, 6)
    self.stylePage:setPos(parentPagePosX + 1, yValueForEntry)
    self.stylePage:setBackColor(self.document.style.secondary)
    self.stylePage.id= "STYLE!"
    self.stylePage:setOnRefreshCallback(self:getHandleRefreshEvent())
    self:addElement(self.stylePage)

    yValueForEntry = yValueForEntry + 1

    self.styleTitle = LabelClass:new(nil, nil, "Style: (Press label to change!)" , self.document)
    self.styleTitle:forceWidthSize(parentPageSizeX - 4)
    self.styleTitle:setMargin(0)
    self.styleTitle:setUpperCornerPos(parentPagePosX + 2, yValueForEntry)
    self.styleTitle:applyDocumentStyle()
    self.stylePage:addElement(self.styleTitle)

    yValueForEntry = yValueForEntry + 1
    self:createStyleSubSection(self.stylePage, parentPagePosX + 1, yValueForEntry, "Primary:", ColonyConfigClass.configs.primary_style)
    yValueForEntry = yValueForEntry + 1
    self:createStyleSubSection(self.stylePage, parentPagePosX + 1, yValueForEntry, "Secondary:", ColonyConfigClass.configs.secondary_style)
    yValueForEntry = yValueForEntry + 1
    self:createStyleSubSection(self.stylePage, parentPagePosX + 1, yValueForEntry, "Tertiary:", ColonyConfigClass.configs.tertiary_style)

    self:applyDocumentStyle()
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
        local page = NumberSelectionPageClass:new(self.monitor,self.parentPage, self.document, "New channel:", 0, rednet.MAX_ID_CHANNELS)
        self.parentPage:pushPage(page, self:getOnChannedlModified())
    end
end

function ConfigurationPageClass:getOnRefreshRateButtonPressed()
    return function()
        local page = NumberSelectionPageClass:new(self.monitor,self.parentPage, self.document, "New refresh delay:", 0, 9999999)
        self.parentPage:pushPage(page, self:getOnRefreshRateModified())
    end
end

function ConfigurationPageClass:getOnStylePressed(configName, title)
    return function(colorDisplay)
        local currentColor = self.document.config:get(configName)
        local page = ColorSelectionPageClass:new(self.monitor,self.parentPage, self.document, title, currentColor)
        self.parentPage:pushPage(page, self:getOnStyleModified(configName))
    end
end

function ConfigurationPageClass:getRefreshRateDisplay()
        local refreshDelay = self.document.config:get(DocumentClass.configs.refresh_delay)
        return string.format("Automatic refresh delay:%s seconds (press to change)", refreshDelay)
end

function ConfigurationPageClass:getOnChannedlModified()
    return function(newChannel)
        self.document:startEdition()
        self.peripheralManager:forceCompleteRefresh()
        self.document.config:set(ColonyConfigClass.configs.proxy_peripherals_channel, newChannel)
        self.connectionLabel:setText(self:getConnectionDetails())
        self.channelButton:setText(self:getChannelDisplay())
        self.document:registerCurrentAreaAsDirty(self.remoteConnectionPage)
        self.document:endEdition()
    end
end

function ConfigurationPageClass:getOnRefreshRateModified()
    return function(refreshRate)
        self.document:startEdition()

        self.document.config:set(DocumentClass.configs.refresh_delay, refreshRate)
        self.refreshRateButton:setText(self:getRefreshRateDisplay())
        self.document:registerCurrentAreaAsDirty(self.refreshRateButton)

        self.document:endEdition()
    end
end

function ConfigurationPageClass:getOnStyleModified(configName)
    return function(color)
        self.document:startEdition()
        self.document.config:set(configName, color)
        self:updateColor(configName)
        self.document:updateStyleFromConfig()
        self.document:registerEverythingAsDirty()
        self.document:endEdition()
    end
end

function ConfigurationPageClass:createStyleSubSection(stylePage, xPos, yPos, title, configName)
    local label = ToggleableButtonClass:new(nil, nil,"", self.document)
    label:setMargin(0)
    label:setUpperCornerPos(xPos + 1, yPos)
    label:applyDocumentStyle()
    label:setText(title)
    label:setOnManualToggle(self:getOnStylePressed(configName, title))
    stylePage:addElement(label)

    local colorDisplay = LabelClass:new(nil, nil, " ", self.document)
    colorDisplay:forceWidthSize(3)
    colorDisplay:forceHeightSize(1)
    colorDisplay:setUpperCornerPos(xPos + 11, yPos)
    self.colorLabelMap[configName] = colorDisplay
    self:updateColor(configName)
    stylePage:addElement(colorDisplay)
end

function ConfigurationPageClass:updateColor(configName)
    local colorToSet = self.document.config:get(configName)
    local colorDisplay = self.colorLabelMap[configName]
    colorDisplay:setBackColor(colorToSet)
end

return ConfigurationPageClass