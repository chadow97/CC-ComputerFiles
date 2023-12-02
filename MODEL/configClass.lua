local logger = require "UTIL.logger"

local ConfigClass = {}
ConfigClass.__index = ConfigClass

function ConfigClass:new()
    local o = setmetatable({}, ConfigClass)
    o.configs = {}
    return o
end

function ConfigClass:set(configKey, configValue)
    self.configs[configKey] = configValue
end

function  ConfigClass:get(configKey)
    return self.configs[configKey]
end

function ConfigClass:setValues(configTable)
    for key, value in pairs(configTable) do
        self:set(key,value)
    end
end


return ConfigClass