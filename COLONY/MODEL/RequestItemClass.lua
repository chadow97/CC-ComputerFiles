-- WorkOrderClass.lua
local ObClass = require("MODEL.ObClass")  -- Adjust the path if necessary
local logger  = require("UTIL.logger")


local RequestItemClass = {}
RequestItemClass.__index = RequestItemClass
setmetatable(RequestItemClass, { __index = ObClass })

RequestItemClass.RESSOURCE_STATUSES = {
    all_in_external_inv = 4,
    all_in_me_or_ex = 2,
    missing_not_craftable = 3,
    craftable = 1}

RequestItemClass.ACTIONS = {
        CRAFT = 1,
        SENDTOEXTERNAL = 2,
        NOTHING = 3,
        CANNOT_COMPLETE = 4
    }

-- Constructor for WorkOrderClass
function RequestItemClass:new(requestItemData, meItemInfo, amountInExternalInventory, requestOb, manager)
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
    self.meItemInfoOb = meItemInfo
    self.amountInExternalInventory = amountInExternalInventory
    if not meItemInfo then
        logger.callStackToFile()
    end


    return self
end

function RequestItemClass:getAmountMissingForRequest()
    return math.max(self.count - self.amountInExternalInventory,0)
end

function RequestItemClass:isMissingAnyToCompleteRequest()
    return self:getAmountMissingForRequest() > 0
end

function RequestItemClass:getAmountMissingWithMe()
    return math.max(self:getAmountMissingForRequest() - self.meItemInfoOb.amount,0)
end

function RequestItemClass:isMissingAnyWithMe()
    return self:getAmountMissingWithMe() > 0
end

function RequestItemClass:getAmountToSendToMe()
    return math.min(self:getAmountMissingWithMe(), self.meItemInfoOb.amount)
end

function RequestItemClass:getRequestKey()
    return self.requestOb:getUniqueKey()
end

function RequestItemClass:getStatus()
    if not self:isMissingAnyToCompleteRequest() then
        return RequestItemClass.RESSOURCE_STATUSES.all_in_external_inv
    elseif not self:isMissingAnyWithMe() then
        return RequestItemClass.RESSOURCE_STATUSES.all_in_me_or_ex
    elseif self.meItemInfoOb.isCraftable then
        return RequestItemClass.RESSOURCE_STATUSES.craftable
    else 
        return RequestItemClass.RESSOURCE_STATUSES.missing_not_craftable
    end

end

function RequestItemClass:getActionToDo()
    local status = self:getStatus()
    if status == RequestItemClass.RESSOURCE_STATUSES.all_in_external_inv then
        return RequestItemClass.ACTIONS.NOTHING
    elseif status == RequestItemClass.RESSOURCE_STATUSES.all_in_me_or_ex then
        return RequestItemClass.ACTIONS.SENDTOEXTERNAL
    elseif status == RequestItemClass.RESSOURCE_STATUSES.craftable then
        return RequestItemClass.ACTIONS.CRAFT
    elseif status == RequestItemClass.RESSOURCE_STATUSES.missing_not_craftable then
        return RequestItemClass.ACTIONS.CANNOT_COMPLETE
    else
        error("Invalid status!")
    end
    
end

-- Overriding GetKeyDisplayString method
function RequestItemClass:GetKeyDisplayString()
    return string.format(
[[
Request Item %s
Amount required: %s
Amount in external inventory: %s
Amount in Me system: %s
Craftable: %s

]],
self.name,
self.count,
self.amountInExternalInventory,
self.meItemInfoOb.amount,
tostring(self.meItemInfoOb.isCraftable)
)
end

-- Overriding GetDisplayString method
function RequestItemClass:GetDisplayString()
    return string.format(
[[
%s
]],
self:getActionUserString())
end

function RequestItemClass:getActionUserString()
    local action = self:getActionToDo()
    if action == self.ACTIONS.CRAFT then
        return "Missing some items! \nPress here to craft."
    elseif action == self.ACTIONS.SENDTOEXTERNAL then
        return "Missing some items! \nPress here to send from ME!"
    elseif action == self.ACTIONS.NOTHING then
        return "All required items provided.\n Nothing to do!"
    elseif action == self.ACTIONS.CANNOT_COMPLETE then
        return "Missing some items! \n Missing in me and cannot craft!"
    end

end

function RequestItemClass:getObStyle(isKey, position)
    -- return elementBackColor, elementTextColor
    if isKey then
        return nil, nil
    end
    local elementBackColor = nil
    local status = self:getStatus()
    local elementTextColor = colors.white
    if status == RequestItemClass.RESSOURCE_STATUSES.all_in_external_inv then
        elementTextColor = colors.green
    elseif status == RequestItemClass.RESSOURCE_STATUSES.all_in_me_or_ex then
        elementTextColor = colors.yellow
    elseif status == RequestItemClass.RESSOURCE_STATUSES.missing_not_craftable then
        elementTextColor = colors.red
    elseif status == RequestItemClass.RESSOURCE_STATUSES.craftable then
        elementTextColor = colors.orange
    else
        error("Invalid status!")
    end

    return elementBackColor, elementTextColor
end


return RequestItemClass