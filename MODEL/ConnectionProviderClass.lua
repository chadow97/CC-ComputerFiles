local logger = require "UTIL.logger"
local TableFileHandlerClass = require("UTIL.tableFileHandlerClass")
local RemoteConnectionClass = require("UTIL.RemoteConnectionClass")

---@class ConnectionProvider
local ConnectionProviderClass = {}
ConnectionProviderClass.__index = ConnectionProviderClass


function ConnectionProviderClass:new(channel)
    ---@class ConnectionProvider
    local o = setmetatable({}, ConnectionProviderClass)
    o.channel = channel
    

    return o
end

function ConnectionProviderClass:getCurrentChannel()
    return self.channel
end

function ConnectionProviderClass:getConnection(wirelessModem)

    local proxyPerChannel = self:getCurrentChannel()
    local wirelessModemName = nil
    if wirelessModem then
        wirelessModemName = wirelessModem.name
    end
    if self.connection then
        if not self.connection:isTo(wirelessModemName, proxyPerChannel) then
            self.connection:close()
            self.connection = nil
        end
    end
    if not self.connection then
        self.connection = RemoteConnectionClass:new(proxyPerChannel, wirelessModemName)
    end
    return self.connection

end

return ConnectionProviderClass