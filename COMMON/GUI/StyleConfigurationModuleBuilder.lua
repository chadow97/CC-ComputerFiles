local LabelClass = require "GUI.LabelClass"
local PageClass  = require "GUI.PageClass"
local ColonyConfigClass = require "COLONY.MODEL.ColonyConfigClass"
local ToggleableButtonClass = require "GUI.ToggleableButtonClass"
local ColorSelectionPageClass = require "GUI.ColorSelectionPageClass"
local logger                  = require "UTIL.logger"

local StyleConfigurationModuleBuilder = {}
local privateFunctions = {}

local StyleModuleClass = {}
StyleModuleClass.__index = StyleModuleClass



function StyleConfigurationModuleBuilder.buildStyleModule(parentPage, targetPage, startingPosition, document, monitor,stylesData)
   return StyleModuleClass:new(parentPage, targetPage, startingPosition, document, monitor,stylesData)
end

function StyleModuleClass:new(parentPage, targetPage, startingPosition, document, monitor, stylesData)
    local styleModule = setmetatable({}, StyleModuleClass)

    styleModule.parentPage = parentPage
    styleModule.targetPage = targetPage
    styleModule.startingPosition = startingPosition
    styleModule.document = document
    styleModule.monitor = monitor
    styleModule.colorLabelMap = {}
    styleModule.stylesData = stylesData
    privateFunctions.createModuleInternal(styleModule)

    return styleModule
end

function StyleModuleClass:getHeight()
    return 3 + (#self.stylesData)
end

function privateFunctions.createModuleInternal(styleModule)
    local stylePage = PageClass:new(styleModule.monitor,2, 2, styleModule.document)

    local parentPagePosX  = styleModule.parentPage:getPos()
    local parentPageWidth = styleModule.parentPage:getSize()
    local insertsWidth = parentPageWidth - 2
    local nextElementYPos = styleModule.startingPosition
    stylePage:setSize(insertsWidth, styleModule:getHeight())
    stylePage:setPos(parentPagePosX + 1, nextElementYPos)
    stylePage:setBackColor(styleModule.document.style.secondary)

    styleModule.targetPage:addElement(stylePage)

    local stylePageInsertsWidth = insertsWidth - 2
    nextElementYPos = nextElementYPos + 1


    local styleTitle = LabelClass:new(nil, nil, "Style: (Press label to change!)" , styleModule.document)
    styleTitle:forceWidthSize(stylePageInsertsWidth)
    styleTitle:setMargin(0)
    styleTitle:setUpperCornerPos(parentPagePosX + 2, nextElementYPos)
    styleTitle:applyDocumentStyle()
    stylePage:addElement(styleTitle)

    for key, data in pairs(styleModule.stylesData) do
        nextElementYPos = nextElementYPos + 1
        privateFunctions.createStyleSubSection(styleModule, stylePage, parentPagePosX + 1, nextElementYPos, data.title, data.config)
    end

    return 
    
end

function privateFunctions.createStyleSubSection(styleModule, stylePage, xPos, yPos, title, configName)
    local label = ToggleableButtonClass:new(nil, nil,"", styleModule.document)
    label:setMargin(0)
    label:setUpperCornerPos(xPos + 1, yPos)
    label:applyDocumentStyle()
    label:setText(title)
    label:setOnManualToggle(privateFunctions.getOnStylePressed(styleModule, configName, title))
    stylePage:addElement(label)

    local colorDisplay = LabelClass:new(nil, nil, " ", styleModule.document)
    colorDisplay:forceWidthSize(3)
    colorDisplay:forceHeightSize(1)
    colorDisplay:setUpperCornerPos(xPos + 11, yPos)
    styleModule.colorLabelMap[configName] = colorDisplay
    privateFunctions.updateColor(styleModule, configName)
    stylePage:addElement(colorDisplay)
end


function privateFunctions.getOnStylePressed(styleModule, configName, title)
    return function(colorDisplay)
        local currentColor = styleModule.document.config:get(configName)
        local page = ColorSelectionPageClass:new(styleModule.monitor,styleModule.parentPage, styleModule.document, title, currentColor)
        styleModule.parentPage:pushPage(page, privateFunctions.getOnStyleModified(styleModule, configName))
    end
end

function privateFunctions.updateColor(styleModule, configName)
    local colorToSet = styleModule.document.config:get(configName)
    local colorDisplay = styleModule.colorLabelMap[configName]
    colorDisplay:setBackColor(colorToSet)
end

function privateFunctions.getOnStyleModified(styleModule, configName)
    return function(color)
        styleModule.document:startEdition()
        styleModule.document.config:set(configName, color)
        privateFunctions.updateColor(styleModule,configName)
        styleModule.document:updateStyleFromConfig()
        styleModule.document:registerEverythingAsDirty()
        styleModule.document:endEdition()
    end

end

return StyleConfigurationModuleBuilder