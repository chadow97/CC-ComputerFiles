-- ObClass.lua
DocumentClass = {}
DocumentClass.__index = DocumentClass

-- Constructor for ObClass
function DocumentClass:new()
    local self = setmetatable({}, DocumentClass)
    self.managers = {}
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

return DocumentClass