local logger = require "UTIL.logger"
local DocumentClass = require("MODEL.DocumentClass")

---@class Manager
ManagerClass = {}
ManagerClass.__index = ManagerClass

-- Constructor for ObClass
function ManagerClass:new(document)
    ---@class Manager
    local o = setmetatable({}, ManagerClass)
    o.type = nil
    o.document = document
    o.refreshDelay = document.config:get(DocumentClass.configs.refresh_delay)
    o.lastRefreshTime = nil
    o.modificationListeners = {}
    return o
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

function ManagerClass:addNewOb(ob)
    error("should be implemented")
end

function ManagerClass:registerModificationListener(listener)
    table.insert(self.modificationListeners, listener)
end

function ManagerClass:_obModified(ob)
    for _, listener in ipairs(self.modificationListeners) do
        listener:onObModified(ob)
    end
end

function ManagerClass:handleEvent(eventName, ...)

end


return ManagerClass