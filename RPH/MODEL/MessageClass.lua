-- MessageClass.lua
local ObClass = require("MODEL.ObClass")  -- Adjust the path if necessary
local logger  = require("UTIL.logger")
local stringUtils = require("UTIL.stringUtils")
local pretty      = require("cc.pretty")

local MessageClass = {}
MessageClass.__index = MessageClass
setmetatable(MessageClass, { __index = ObClass })

-- Constructor for MessageClass
function MessageClass:new(messageId, senderId)
    local uniqueKey = messageId
    local o = setmetatable(ObClass:new(uniqueKey), MessageClass)

    o.messageNumber = messageId
    o.request = nil
    o.response = nil
    o.error = nil
    o.senderId = senderId
    return o
end

function MessageClass:setRequest(request)
    self.request= request
end

function MessageClass:setResponse(response)
    self.response = response
end

-- Overriding GetKeyDisplayString method
function MessageClass:GetKeyDisplayString()
    return string.format(
[[
NOTHING
]])
end

-- Overriding GetDisplayString method
function MessageClass:GetDisplayString()
    return string.format(
[[
ID: %s, REQUEST: %s, RESPONSE: %s
]], self.messageNumber, stringUtils.Truncate(pretty.render(pretty.pretty(self.request)),25), 
                        stringUtils.Truncate(pretty.render(pretty.pretty(self.response)),25))
end


return MessageClass