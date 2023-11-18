local logger = require "UTIL.logger"
-- ObClass.lua
DocumentClass = {}
DocumentClass.__index = DocumentClass

-- Constructor for ObClass
function DocumentClass:new()
    local self = setmetatable({}, DocumentClass)
    self.managers = {}
    self.nEditionStarted = 0
    self.editionListeners = {}
    self.dirtyAreas = {}
    self.completelyDirty = false
    return self
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