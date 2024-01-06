local logger = require "UTIL.logger"
local ColonyConfigClass     = require("COLONY.MODEL.ColonyConfigClass")
local ConnectionProviderClass = require("MODEL.ConnectionProviderClass")

---@class ColonyConnectionProvider: ConnectionProvider
local ColonyConnectionProviderClass = {}
ColonyConnectionProviderClass.__index = ColonyConnectionProviderClass

setmetatable(ColonyConnectionProviderClass, { __index = ConnectionProviderClass })

function ColonyConnectionProviderClass:new(document)
    ---@class ColonyConnectionProvider: ConnectionProvider
    local o = setmetatable(ConnectionProviderClass:new(nil), ColonyConnectionProviderClass)
    o.document = document
    o.connection = nil
    

    return o
end

function ColonyConnectionProviderClass:getCurrentChannel()
    logger.db(self.document)
    return self.document.config:get(ColonyConfigClass.configs.proxy_peripherals_channel)
end

return ColonyConnectionProviderClass