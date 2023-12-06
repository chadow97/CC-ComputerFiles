local logger = require("UTIL.logger")

-- Define the RemoteConnectionClass class
local RemoteConnectionClass = {}
RemoteConnectionClass.__index = RemoteConnectionClass
RemoteConnectionClass.connections = {}

-- Constructor function for creating new instances of the class
function RemoteConnectionClass:new(channel, modemName)
    local instance = {}
    setmetatable(instance, RemoteConnectionClass)

    instance.channel = channel
    instance.modemName = modemName

    rednet.open(instance.modemName)
    instance:_registerConnection()

    return instance
end

function RemoteConnectionClass:close()
    local channels = RemoteConnectionClass.connections[self.modemName]
    if (not channels[self.channel]) then
        error("trying to close unregisted connection")
    end
    channels[self.channel] = nil
    if (#channels <= 0) then
        rednet.close(self.modemName)
    end
end

function RemoteConnectionClass:_registerConnection()
    local channels = RemoteConnectionClass.connections[self.modemName]
    if not channels then
        RemoteConnectionClass.connections[self.modemName] = {}
        channels = RemoteConnectionClass.connections[self.modemName]
    end
    if channels[self.channel] then
        error("Trying to open already openned connection!")
    else
        channels[self.channel] = self
    end
end

function RemoteConnectionClass:sendAndReceive(message)

    rednet.send(self.channel, message)
    local senderId, responsePacket = rednet.receive(nil, 5)
    if responsePacket == nil then
        responsePacket = {error = "No packet received"}
    end
    local wasSuccess = false
    if responsePacket.error == nil then
        wasSuccess = true
    end
    local responseOrError = {error = "Unhandled error during reception"}
    if wasSuccess then
        responseOrError = responsePacket.response
    else
        responseOrError = responsePacket
    end
    return wasSuccess, responseOrError
end

return RemoteConnectionClass
