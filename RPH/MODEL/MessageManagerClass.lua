-- WorkOrderFetcher.lua
local logger = require("UTIL.logger")
local MessageClass = require("RPH.MODEL.MessageClass")
local ManagerClass = require("MODEL.ManagerClass")
local s2t = require("UTIL.stringToTypeUtils")

local MessageManagerClass = {}

MessageManagerClass.TYPE = "RPH_MESSAGE"

MessageManagerClass.__index = MessageManagerClass
setmetatable(MessageManagerClass, { __index = ManagerClass })

function MessageManagerClass:new(document)
    local o = setmetatable(ManagerClass:new(document), MessageManagerClass)
    o.type = MessageManagerClass.TYPE
    o.messagesById = {}
    o.nextMessageId = 1

    return o
end

function MessageManagerClass:getOb(uniqueKey)
    self:_refreshIfNeeded()
    return self.messagesById[uniqueKey]

end

function MessageManagerClass:getObs()
    -- override get obs because we want to return a vector and not a map
    self:_refreshIfNeeded()
    local obs = {}
    for _, ob in pairs(self:_getObsInternal()) do
        table.insert(obs,ob)
    end
    return obs
end

function MessageManagerClass:_getObsInternal()
    return self.messagesById
end

function MessageManagerClass:_onRefreshObs()
    -- no periodic refresh for this manager
end

function MessageManagerClass:handleEvent(eventName, ...)
    if (eventName == "rednet_message") then
        self:handleRednetMessage(...)
    end
end

-- Method for handling getMethods requests
function MessageManagerClass:_handleGetMethods(peripheralName, senderID)
    local peripheralObj = peripheral.find(peripheralName)

    local methods = peripheral.getMethods(peripheral.getName(peripheralObj))
    
    local message = {response = methods}

    rednet.send(senderID, message)
    return message
end

-- Method for handling method call requests
function MessageManagerClass:_handleCallMethod(peripheralName, methodName, senderID, args)
    local peripheralObj = peripheral.wrap(peripheralName)
    if not peripheralObj then
        peripheralObj = peripheral.find(peripheralName)       
    end
    local message = {error = "unhandled_error"}
    if not peripheralObj then
        message = {error = "unfound_peripheral"}
    
    elseif not methodName or not peripheralObj[methodName] or not type(peripheralObj[methodName]) == "function" then
        message = {error = "unknown_method"}
    
    else 
        -- first, unserialize args
        local serializedArgs = {}
        for _,arg in ipairs(args) do
            table.insert(serializedArgs, s2t.string_to_type(arg))
        end

        -- call method
---@diagnostic disable-next-line: param-type-mismatch
        local success, result = pcall(peripheralObj[methodName], table.unpack(serializedArgs))
        if success then
            message = {response = result}
        else 
            message = {error = "failed_method_call", errorDesc = result}    
        end

    end
    rednet.send(senderID, message)
    return message
end

function MessageManagerClass:_handleHostComputerCall(program, senderID, code)
    local func, err = load(program)
    local message = {error = "unhandled_error"}
    if not func then
        message = {error = "invalid code!"}
    else
        local success, result = pcall(func)
        if success then
            message = {response = result}
        else
            message = {error ="failed_program_call", errorDesc = result}
        end
    end

    rednet.send(senderID, message)
    return message

end

function MessageManagerClass:handleRednetMessage(senderID, message, protocol)

    logger.log(message , logger.LOGGING_LEVEL.WARNING, "Received message:")
    local ob = MessageClass:new(self.nextMessageId)
    ob:setRequest(message)
    self.nextMessageId = self.nextMessageId + 1
    if (not senderID) then
        error("No sender id received!")
    end

    local response = {}

    if message and message.peripheralName and message.method then
        local peripheralName = message.peripheralName
        local methodName = message.method
        local args = message.args

        if peripheralName == "host_computer" then
            response = self:_handleHostComputerCall(methodName, senderID)
        else
            if methodName == "getMethods" then
                response = self:_handleGetMethods(peripheralName,senderID)
            else
                response = self:_handleCallMethod(peripheralName, methodName, senderID, args)
            end
        end
    else
        response = {error = "missing_param"}
        rednet.send(senderID, response)
    end

    ob:setResponse(response)
    logger.log(response, logger.LOGGING_LEVEL.WARNING, "Response:")
    self:addNewOb(ob)
end

function MessageManagerClass:addNewOb(ob)
    self.messagesById[ob:getUniqueKey()] = ob
    self:_obModified(ob)
end


return MessageManagerClass