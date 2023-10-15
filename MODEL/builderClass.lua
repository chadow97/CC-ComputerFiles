-- WorkOrderClass.lua
local ObClass = require("MODEL.obClass")  -- Adjust the path if necessary


local BuilderClass = {}
BuilderClass.__index = BuilderClass
setmetatable(BuilderClass, { __index = ObClass })

-- Constructor for WorkOrderClass
function BuilderClass:new(builderData)
    local uniqueKey = builderData.id
    self = setmetatable(ObClass:new(uniqueKey), BuilderClass)
    self.id = self.uniqueKey


    self.name = builderData.name
    if builderData.work then
        self.builderHutLocation = builderData.work.location
        self.builderHutLevel = builderData.work.level
    end
    self.state = builderData.state

    return self
end

-- Overriding GetKeyDisplayString method
function BuilderClass:GetKeyDisplayString()
    return self.uniqueKey
end

-- Overriding GetDisplayString method
function BuilderClass:GetDisplayString()
    return string.format("ID:%s \nName: %s\nHut level:%s\nStatus:%s", self.id, self.name, self.builderHutLevel, self.state)
end


return BuilderClass