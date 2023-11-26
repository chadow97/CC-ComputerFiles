-- WorkOrderClass.lua
local ObClass = require("MODEL.ObClass")  -- Adjust the path if necessary
local logger  = require("UTIL.logger")


local RequestItemClass = {}
RequestItemClass.__index = RequestItemClass
setmetatable(RequestItemClass, { __index = ObClass })

-- Constructor for WorkOrderClass
function RequestItemClass:new(requestItemData, requestOb, manager)
    local uniqueKey = requestItemData.name
    self = setmetatable(ObClass:new(uniqueKey), RequestItemClass)
    self.name = self.uniqueKey
    self.displayName = requestItemData.displayName
    self.nbt = requestItemData.nbt
    self.maxStackSize = requestItemData.maxStackSize
    self.tags = requestItemData.tags
    self.manager = manager
    self.requestOb = requestOb
    self.count = requestItemData.count

    return self
end

function RequestItemClass:getRequestKey()
    return self.requestOb:getUniqueKey()
end

-- Overriding GetKeyDisplayString method
function RequestItemClass:GetKeyDisplayString()
    return string.format(
[[
Request Item %s
Amount Required %s
]],
self.name,
self.count)
end

-- Overriding GetDisplayString method
function RequestItemClass:GetDisplayString()
    return --hack to center inside button..
[[VALUE]]
end


return RequestItemClass