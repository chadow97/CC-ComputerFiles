local logger = require "UTIL.logger"
local stringUtils = require "UTIL.stringUtils"
-- Command.lua
AreaClass = {}
AreaClass.__index = AreaClass

-- Constructor for AreaClass
function AreaClass:new(startX, startY, endX, endY)
    local o = setmetatable({}, AreaClass)
    o.startX = nil
    o.startY = nil
    o.endX = nil
    o.endY = nil
    o:setArea(startX, startY, endX, endY)

    return o
end

function AreaClass:setArea(startX, startY, endX, endY)
assert(startX and startY and endX and endY, "Area cannot have undefined dimensions!")
self.startX = startX
self.startY = startY
self.endX = endX
self.endY = endY
end

function AreaClass:getArea()
    return self.startX, self.startY, self.endX, self.endY
end

function AreaClass:getSize()
    return self:getSizeX(), self:getSizeY()
end

function AreaClass:getSizeX()
    return self.endX - self.startX + 1
end

function AreaClass:getSizeY()
    return self.endY - self.startY + 1
end

function AreaClass:contains(area)
    if self.startX > area.startX then
        return false
    end
    if self.startY > area.startY then
        return false
    end

    if self.endX < area.endX then
        return false
    end

    if self.endY < area.endY then
        return false
    end

    return true
end

function AreaClass:__tostring()
    return stringUtils.UFormat("[$s,%s]",
                                stringUtils.CoordToString(self.startX,self.startY),
                                stringUtils.CoordToString(self.endX, self.endY))
end

return AreaClass