-- WorkOrderClass.lua
local ObClass = require("MODEL.obClass")  -- Adjust the path if necessary
local logger  = require("UTIL.logger")

local RequestClass = {}
RequestClass.__index = RequestClass
setmetatable(RequestClass, { __index = ObClass })

-- Constructor for WorkOrderClass
function RequestClass:new(requestData, manager)
    local uniqueKey = requestData.id
    self = setmetatable(ObClass:new(uniqueKey), RequestClass)
    self.id = self.uniqueKey
    self.manager = manager

    self.name = requestData.name
    self.desc = requestData.desc
    self.state = requestData.state
    self.count = requestData.count
    self.minCount = requestData.minCount
    self.target = requestData.target
    self.items = requestData.items
    self.itemObs = {}

    return self
end

function RequestClass:setItems(itemObs)
    self.itemObs = itemObs
end

function RequestClass:getItems()
    local itemManager = self.manager.document:getManagerForType("REQUEST_ITEM")
    -- make sure items are loaded!
    itemManager:getObs()

    return self.itemObs 
end

-- Overriding GetKeyDisplayString method
function RequestClass:GetKeyDisplayString()
    return string.format(
[[
Request %s
ID:%s
Desc:%s
State:%s
Count:%s
Minimum count:%s
Target:%s
#Items:%s
]],
self.name,
self.id,
self.desc,
self.state,
self.count,
self.minCount,
self.target,
#self.items)
end

-- Overriding GetDisplayString method
function RequestClass:GetDisplayString()
    return --hack to center inside button..
[[



           SEND 
           ALL!



]]
end


return RequestClass