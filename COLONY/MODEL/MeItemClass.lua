-- MeItemClass.lua
local ObClass = require("MODEL.ObClass")  -- Adjust the path if necessary
local logger  = require("UTIL.logger")

local MeItemClass = {}
MeItemClass.__index = MeItemClass
setmetatable(MeItemClass, { __index = ObClass })

-- Constructor for MeItemClass
function MeItemClass:new(meItemData)
    local uniqueKey = meItemData.name
    local o = setmetatable(ObClass:new(uniqueKey), MeItemClass)

    o.tags = meItemData.tags
    o.name = meItemData.name
    o.amount = meItemData.amount
    o.fingerprint = meItemData.fingerprint
    o.isCraftable = meItemData.isCraftable
    o.nbt = meItemData.nbt
    o.displayName = meItemData.displayName

    return o
end

function MeItemClass:createMissingItem(name)
    local uniqueKey = name
    local o = setmetatable(ObClass:new(uniqueKey), MeItemClass)

    o.tags = {}
    o.name = name
    o.amount = 0
    o.fingerprint = nil
    o.isCraftable = false
    o.nbt = nil
    o.displayName = nil
    return o
end

-- Overriding GetKeyDisplayString method
function MeItemClass:GetKeyDisplayString()
    return string.format(
[[
ME_ITEM_KEY
]])
end

-- Overriding GetDisplayString method
function MeItemClass:GetDisplayString()
    return string.format(--hack to center inside button..
[[
%s
Amount: %s
Craftable: %s
]], self.displayName, self.amount, tostring(self.isCraftable))
end


return MeItemClass