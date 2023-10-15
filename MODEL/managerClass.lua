local logger = require "UTIL.logger"
-- ObClass.lua
ManagerClass = {}
ManagerClass.__index = ManagerClass

-- Constructor for ObClass
function ManagerClass:new()
    local self = setmetatable({}, ManagerClass)
    self.type = nil
    return self
end

function ManagerClass:getHandledType()
    return self.type
end

-- allows managers to be used as data fetchers
function ManagerClass:getData()
    return self:getObs()
end

function ManagerClass:getObs(type)
    logger.log("getObs should be implemented")
end

function ManagerClass:clear()
    logger.log("clear should be implemented")
end



function ManagerClass:refreshObjects()
end

return ManagerClass