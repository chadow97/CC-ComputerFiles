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
    o.nickname = nil
    o.active = false
    o.associatedInventory = nil

    return o
end

function RedstoneIntegratorClass:__tostring()
    return stringUtils.UFormat("[Redstone controller: %s]", self.name)
end

-- Overriding GetKeyDisplayString method
function RedstoneIntegratorClass:GetKeyDisplayString()
    return self.uniqueKey
end

function RedstoneIntegratorClass:setState(IsActive)
    self.active = IsActive
    self.per.setOuput("top", IsActive)
end

function RedstoneIntegratorClass:toggleState()
    self:setState(not self.active)
end

-- Overriding GetDisplayString method
function RedstoneIntegratorClass:GetDisplayString()
    local nickname = self.nickname or "No nickname"
    local associatedInventoryKey = "None"
    local displayString = string.format(
[[Redstone integrator
ID : %s
Nickname : %s 
IsActive: %s
Associated Inventory: %s
]],
self.name,
nickname,
tostring(self.active),
associatedInventoryKey)
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