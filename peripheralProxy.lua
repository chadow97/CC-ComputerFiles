local logger = require("UTIL.logger")
logger.init(term.current())

-- Define the PeripheralProxy class
local PeripheralProxy = {}
PeripheralProxy.__index = PeripheralProxy

-- Constructor function for creating new instances of the class
function PeripheralProxy:new(channel, peripheralName)
    local instance = {}
    setmetatable(instance, PeripheralProxy)

    instance.channel = channel
    instance.peripheralName = peripheralName

    if not rednet.isOpen() then
        rednet.open("back")
    end

    return instance
end

-- Method for retrieving the names of all available methods on the peripheral
function PeripheralProxy:getRemoteMethods()
    rednet.send(self.channel, {peripheralName = self.peripheralName, method = "getMethods"})
    local _, response = rednet.receive(nil, 5)
    if response then
        return response
    else
        print("No response!!!")
    end
end

-- Method for calling a specific method on the peripheral
function PeripheralProxy:callMethod(methodName, ...)
    return self:callMethodInternal(methodName,nil, ...)
end


function PeripheralProxy:callMethodInternal(methodName, info, ...)
    print("calling method!" .. methodName)
    if  type(self.peripheralName) =="function" then
        return "Missing peripheral name!"
    end

    if not methodName then
        return "Missing method name!"
    end


    rednet.send(self.channel, {peripheralName = self.peripheralName, method = methodName, args = {...}})
    local _, response = rednet.receive(nil, 5)
    -- check for errors
    if not response then
        return "No response from: " .. self.channel
    end
    if response.error then
        if response.error == "unknown_method" then
            if not info then
                return "Unknown method: " .. methodName
            else
                return "Unknown method (" .. methodName ..") called in file " .. info.source .." on line " .. info.currentline .. "!"
            end
        elseif response.error == "missing_param" then
            return "Missing some parameter"    

        elseif response.error == "unfound_peripheral" then
            return "Could not not find peripheral: " .. self.peripheralName

        elseif response.error == "failed_method_call" then
            return "Method call failed with error:" .. response.errorDesc
        else
            return "Unhandled Error: " .. response.error
        end
    end

    if response then
        return (response)
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
