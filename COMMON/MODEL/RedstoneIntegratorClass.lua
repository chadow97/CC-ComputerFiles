-- RedstoneIntegratorClass.lua
local ObClass = require("MODEL.ObClass")  -- Adjust the path if necessary
local stringUtils = require("UTIL.stringUtils")
local PeripheralClass = require("COMMON.MODEL.PeripheralClass")
local logger          = require("UTIL.logger")


local RedstoneIntegratorClass = {}
RedstoneIntegratorClass.__index = RedstoneIntegratorClass
setmetatable(RedstoneIntegratorClass, { __index = PeripheralClass })

-- Constructor for RedstoneIntegratorClass
function RedstoneIntegratorClass:new(redstoneIntegratorPeripheral)
    local o = setmetatable(PeripheralClass:new(redstoneIntegratorPeripheral), RedstoneIntegratorClass)

    o.name = o.uniqueKey

    return o
end

function RedstoneIntegratorClass:__tostring()
    return stringUtils.UFormat("[Redstone controller: %s]", self.name)
end

-- Overriding GetKeyDisplayString method
function RedstoneIntegratorClass:GetKeyDisplayString()
    return self.uniqueKey
end

-- Overriding GetDisplayString method
function RedstoneIntegratorClass:GetDisplayString()
    local displayString = string.format(self.uniqueKey)
    return displayString
end


function RedstoneIntegratorClass:__index(key)
    if RedstoneIntegratorClass[key] then
        return RedstoneIntegratorClass[key]
    elseif PeripheralClass[key] then
        return PeripheralClass[key]
    elseif ObClass[key] then
        return ObClass[key]
    else
        return self.per[key]
    end
end


return RedstoneIntegratorClass