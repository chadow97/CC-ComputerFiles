local logger = require "UTIL.logger"
local ConfigClass = require "MODEL.ConfigClass"
-- ObClass.lua
DocumentClass = {}
DocumentClass.__index = DocumentClass

DocumentClass.configs = {refresh_delay ="refresh_delay"}

-- Constructor for ObClass
function DocumentClass:new(config)
    local o = setmetatable({}, DocumentClass)
    o.managers = {}
    o.nEditionStarted = 0
    o.editionListeners = {}
    o.dirtyAreas = {}
    o.completelyDirty = false

    o.config = config or ConfigClass:new()
    
    -- setup default configs
    local defaultConfigs = {
        [DocumentClass.configs.refresh_delay] = 10
        }
    o.config:setValues(defaultConfigs)

    return o
end

function DocumentClass:getHandledObs()
    local types = {}
    for type, _ in pairs(self.managers) do
        table.insert(types,type)
    end
    return types
end

function DocumentClass:getObs(type)
    return self:getManagerForType(type):getObs()
end

function DocumentClass:registerManager(manager)
    self.managers[manager:getHandledType()] = manager
end

function DocumentClass:removeManager(manager)
    table.remove(self.managers[manager:getHandledType()])
end

function DocumentClass:getManagerForType(type)
    local mgr = self.managers[type]
    assert(mgr, "No manager found for type ".. type .. "!")
    return self.managers[type]
end

function DocumentClass:startEdition()
    self.nEditionStarted = self.nEditionStarted + 1
end

function DocumentClass:endEdition()
    self.nEditionStarted = self.nEditionStarted - 1
    assert(self.nEditionStarted >= 0, "start/end edition not balanced")
    if self.nEditionStarted == 0 then
        self:handleEditionEnded()
    end
end

function DocumentClass:registerCurrentAreaAsDirty(element)
    self:registerAreaAsDirty(element:getAreaAsObject())
end

function DocumentClass:registerAreaAsDirty(area)
    if self.completelyDirty then
        return
    end
    for index, dirtyArea in ipairs(self.dirtyAreas) do
        if dirtyArea:contains(area) then
            return
        end
        if (area:contains(dirtyArea)) then
            table.remove(self.dirtyAreas, index)
        end
    end
    table.insert(self.dirtyAreas, area)
end

function DocumentClass:registerEverythingAsDirty()
    self.completelyDirty = true
end

function DocumentClass:clean()
    self.completelyDirty = false
    self.dirtyAreas = {}
end

function DocumentClass:getElementsToDraw(rootElement)
    if self.completelyDirty then
        return {rootElement}
    end
    local elementsToDraw = {}
    for _, dirtyArea in ipairs(self.dirtyAreas) do
        if not rootElement:getAreaAsObject():contains(dirtyArea) then
            assert(false, "Too dirty! Cannot clean!!!")
        end
        local smallestElement = self:getSmallestElementToDraw(rootElement, dirtyArea)
        table.insert(elementsToDraw, smallestElement)       
    end
    return elementsToDraw
end

function DocumentClass:getSmallestElementToDraw(element, dirtyArea)
    local childToDraw = nil
    if not element:getChildElements() then
        logger.callStackToFile()
        logger.logObToFile("Ob returned no childs!!!" .. tostring(element))
    end
    for _, child in ipairs(element:getChildElements()) do

        if child:getAreaAsObject():contains(dirtyArea) and 
           element:canTryToOnlyDrawChild(dirtyArea, child) then
            -- found a smaller child to draw!
            childToDraw = self:getSmallestElementToDraw(child, dirtyArea)
            break
        end
    end
    if not childToDraw then
        return element
    end
    return childToDraw

end

function DocumentClass:addEditionListener(listener)
    table.insert(self.editionListeners, listener)
end

function DocumentClass:removeEditionListener(listener)
    table.remove(self.editionListeners, listener)
end

function DocumentClass:handleEditionEnded()
    for _, listener in ipairs(self.editionListeners) do
        if listener.onEditionEnded then
            listener:onEditionEnded()
        end
    end
end

return DocumentClass