local logger = require("UTIL.logger")

-- Define the RemoteComputerClass class
local RemoteComputerClass = {}
RemoteComputerClass.__index = RemoteComputerClass

-- Constructor function for creating new instances of the class
function RemoteComputerClass:new(connection)
    local instance = {}
    setmetatable(instance, RemoteComputerClass)

    instance.connection = connection
    return instance
end

function RemoteComputerClass:runCode(code)
    local message = {peripheralName = "host_computer", method = code}
    local success, responseOrError = self.connection:sendAndReceive(message)
    if success then
        return responseOrError
    end

    error(responseOrError.error)
    return nil
end

function RemoteComputerClass:getPeripherals()
    return self:runCode("return peripheral.getNames()")
end

function RemoteComputerClass:getType(perName)

local code = string.format(
[[
return peripheral.getType("%s")
]],perName)

return self:runCode(code)
end

return RemoteComputerClass