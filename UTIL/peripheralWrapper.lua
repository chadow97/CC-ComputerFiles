local logger = require("UTIL.logger")
logger.init(term.current())

-- Define the PeripheralWrapper class
local PeripheralWrapper = {}
PeripheralWrapper.__index = PeripheralWrapper

-- Constructor function for creating new instances of the class
function PeripheralWrapper:new(peripheralNameOrType)
    local instance = {}
    setmetatable(instance, PeripheralWrapper)
    -- assume type was passed
    local per = peripheral.find(peripheralNameOrType)
    -- if type didnt work, try as a name
    if not per then
        peripheral.wrap(peripheralNameOrType)
    end
    if not per then
        return nil
    end
    instance.per = per
    instance.name = peripheral.getName(per)
    instance.type = peripheral.getType(per)

    return instance
end

-- Method for calling a specific method on the peripheral
function PeripheralWrapper:callMethod(methodName, ...)
    return self:callMethodInternal(methodName,nil, ...)
end

function PeripheralWrapper:getName()
    return self.name
end

function PeripheralWrapper:getType()
    return self.type
end


function PeripheralWrapper:callMethodInternal(methodName, info, ...)
    
    if not methodName then
        return "Missing method name!"
    end
    
    return self.per[methodName](...)
end

function PeripheralWrapper:__index(key)
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


return PeripheralWrapper