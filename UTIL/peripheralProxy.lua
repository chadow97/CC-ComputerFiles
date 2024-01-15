local logger = require("UTIL.logger")

-- Define the PeripheralProxy class
local PeripheralProxy = {}
PeripheralProxy.__index = PeripheralProxy

-- Constructor function for creating new instances of the class
function PeripheralProxy:new(connection, peripheralName)
    local instance = {}
    setmetatable(instance, PeripheralProxy)

    instance.connection = connection
    assert(connection, "No connection!")
    instance.peripheralName = peripheralName

    return instance
end

-- Method for retrieving the names of all available methods on the peripheral
function PeripheralProxy:getMethods()
    local success, responseOrError = self.connection:sendAndReceive({peripheralName = self.peripheralName, method = "getMethods"})
    if success then
        return responseOrError
    else
        print(responseOrError.error)
    end
end

-- Method for calling a specific method on the peripheral
function PeripheralProxy:callMethod(methodName, ...)
    return self:callMethodInternal(methodName,nil, ...)
end


function PeripheralProxy:callMethodInternal(methodName, info, ...)
    logger.log("Calling method: ".. methodName, logger.LOGGING_LEVEL.INFO)
    if  type(self.peripheralName) =="function" then
        return "Missing peripheral name!"
    end

    if not methodName then
        return "Missing method name!"
    end
    local success, responseOrError = self.connection:sendAndReceive({peripheralName = self.peripheralName, method = methodName, args = {...}})
    if success then
        return responseOrError
    end
    local error = responseOrError.error
    if error == "unknown_method" then
        if not info then
            return "Unknown method: " .. methodName
        else
            return "Unknown method (" .. methodName ..") called in file " .. info.source .." on line " .. info.currentline .. "!"
        end
    elseif error == "missing_param" then
        return "Missing some parameter"    

    elseif error == "unfound_peripheral" then
        return "Could not not find peripheral: " .. self.peripheralName

    elseif error == "failed_method_call" then
        return "Method call failed with error:" .. responseOrError.errorDesc
    else
        return "Unhandled Error: " .. error
    end

end

function PeripheralProxy:__index(key)
    --save debug info!
    local info = debug.getinfo(2, "Sl")




    local mt = getmetatable(self)
    if rawget(self, key) ~= nil or mt[key] ~= nil then
      return rawget(self, key) or mt[key]
    else
      local func = function(_, ...)
        return self:callMethodInternal(key, info, ...)
      end
      return func
    end
  end


return PeripheralProxy
