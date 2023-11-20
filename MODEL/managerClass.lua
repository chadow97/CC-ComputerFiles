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

function ManagerClass:getObs()
    logger.log("getObs should be implemented")
    return {}
end

function ManagerClass:clear()
    logger.log("clear should be implemented")
end

function ManagerClass:getOb(uniqueKey)
    local obList = self:getObs()
    for _,ob in pairs(obList) do
        if ob:getUniqueKey() == uniqueKey then
            return ob
        end
    end
    return nil
end



function ManagerClass:refreshObjects()
    logger.log("refresh should be implemented")
end

return ManagerClass