-- WorkOrderClass.lua
local ObClass = require("MODEL.ObClass")  -- Adjust the path if necessary
local logger  = require("UTIL.logger")
local stringUtils = require("UTIL.stringUtils")
local perTypes    = require("UTIL.perTypes")


local PeripheralClass = {}

-- Constructor for WorkOrderClass
function PeripheralClass:new(per)
    local uniqueKey = peripheral.getName(per)
    
    local o = setmetatable(ObClass:new(uniqueKey), PeripheralClass)
    o.name = uniqueKey
    o.type = peripheral.getType(per)
    o.per = per
    o.isDistant = false
    o._isWirelessModem = -1 -- do this because otherwise will return function
    

    return o
end

function PeripheralClass:newFromProxy(perProxy, type)
    local uniqueKey = perProxy.peripheralName .. "_proxy"
    local o = setmetatable(ObClass:new(uniqueKey), PeripheralClass)
    o.name = perProxy.peripheralName
    o.type = type
    o.per = perProxy
    o.isDistant = true
    o._isWirelessModem = -1 
    assert(o.type, "no type!!")
    return o
end

-- Overriding GetKeyDisplayString method
function PeripheralClass:GetKeyDisplayString()
    return self:getUniqueKey()
end

-- Overriding GetDisplayString method
function PeripheralClass:GetDisplayString()
    return string.format(
    [[
Name: %s
Type: %s
Connection type: %s
    ]],
self.name,
self:getTypeForUser(),
self:getConnectionType()  
)
end

function PeripheralClass:getConnectionType()
    if self.isDistant then
        return "Wireless"
    else
        return "Connected"
    end
end

function PeripheralClass:isWirelessModem()
    if self.type ~= perTypes.wired_modem then
        error("Should only call on modems!")
    end
    if self._isWirelessModem == -1 then
        self._isWirelessModem = self.isWireless()
    end
    return self._isWirelessModem
end

function PeripheralClass:getTypeForUser()

    if self.type ~= perTypes.wired_modem then
        return self.type
    else
        if self:isWirelessModem()  then
            return "Wireless Modem"
        else
            return "Wired Modem"
        end
    end

end

function PeripheralClass:__index(key)
    if PeripheralClass[key] then
        return PeripheralClass[key]
    elseif ObClass[key] then
        return ObClass[key]
    else
        return self.per[key]
    end
end


return PeripheralClass