local logger = require "UTIL.logger"
local DocumentClass = require("MODEL.documentClass")
-- ObClass.lua
ManagerClass = {}
ManagerClass.__index = ManagerClass

-- Constructor for ObClass
function ManagerClass:new(document)
    local self = setmetatable({}, ManagerClass)
    self.type = nil
    self.document = document
    self.refreshDelay = document.config:get(DocumentClass.configs.refresh_delay)
    self.lastRefreshTime = nil
    return self
end

function ManagerClass:_getObsInternal()
    error("internal get ob should be implemented!")
    return {}
end

function ManagerClass:getHandledType()
    return self.type
end

function ManagerClass:_getDelaySinceLastUpdate()
    return (os.epoch("utc") - self.lastRefreshTime) / 1000
end



function ManagerClass:_shouldManagerRefresh()

    if not self.lastRefreshTime then
        return true    
    elseif self:_getDelaySinceLastUpdate() > self.refreshDelay then
        return true
    end

    return false
end

function ManagerClass:getRefreshObs()
    self:forceRefresh()
    return self:getObs()
end

function ManagerClass:forceRefresh()
    self.lastRefreshTime = nil
end

function ManagerClass:_refreshIfNeeded()
    if self:_shouldManagerRefresh() then
        self:_refreshObjects()
    end
end
function ManagerClass:getObs()
    self:_refreshIfNeeded()
    return self:_getObsInternal()
end


function ManagerClass:clear()
    local obTable = self:_getObsInternal()
    for key in pairs(self:_getObsInternal()) do
        obTable[key] = nil
    end
    self.lastRefreshTime = nil
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

function ManagerClass:_refreshObjects()
    self.lastRefreshTime = os.epoch("utc")
    self:_onRefreshObs()

end

function ManagerClass:_onRefreshObs()
    error("refresh should be implemented")
end


return ManagerClass