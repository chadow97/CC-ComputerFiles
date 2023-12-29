local logger = require "UTIL.logger"
local TableFileHandlerClass = require("UTIL.tableFileHandlerClass")

---@class Config
local ConfigClass = {}
ConfigClass.__index = ConfigClass

ConfigClass.configs = 
    {
    data_dir_path ="data_dir_path",
    config_file = "config_file"
    }

function ConfigClass:new()
    ---@class Config
    local o = setmetatable({}, ConfigClass)
    o.configTable = {}

    o:setDefault(ConfigClass.configs.data_dir_path, "./DATA/")
    o:setDefault(ConfigClass.configs.config_file, "config.txt")

    o.tableFileHandler = TableFileHandlerClass:new(o:getConfigPath())

    o:_readSavedConfig()
    

    return o
end

function ConfigClass:setDefault(configKey, configValue)
    if not self.configTable[configKey] then
        self:_changeConfigWithoutSaving(configKey,configValue)
    end
end

function  ConfigClass:get(configKey)
    return self.configTable[configKey]
end

function ConfigClass:set(configKey, configValue)
    self:_changeConfigWithoutSaving(configKey, configValue)
    self:_writeSavedConfigs()
end

function ConfigClass:setDefaults(configTable)
    for key, value in pairs(configTable) do
        self:setDefault(key,value)
    end
end

function ConfigClass:_changeConfigWithoutSaving(configKey, configValue)
    assert(configKey, "no keys to set!")
    self.configTable[configKey] = configValue
end

function ConfigClass:_changeConfigsWithoutSaving(configTable)
    for key, value in pairs(configTable) do
        self:_changeConfigWithoutSaving(key,value)
    end
end

function ConfigClass:getConfigPath()
    return fs.combine(self:get(ConfigClass.configs.data_dir_path),
                      self:get(ConfigClass.configs.config_file))
end

function ConfigClass:_readSavedConfig()
    local configsToSet = self.tableFileHandler:read()
    self:_changeConfigsWithoutSaving(configsToSet)
end

function ConfigClass:_writeSavedConfigs()
    self.tableFileHandler:write(self.configTable)
end

return ConfigClass