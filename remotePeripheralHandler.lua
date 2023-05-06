local logger = require("UTIL.logger")
local s2t = require("UTIL.stringToTypeUtils")


local terminal = term.current()
local monitor = peripheral.find("monitor")
if monitor then
    terminal = monitor
end

logger.init(terminal)
logger.terminal.clear() 

-- Open the rednet modem
rednet.open("back")

-- Method for handling getMethods requests
local function handleGetMethods(peripheralName, senderID)
    local peripheralObj = peripheral.find(peripheralName)

    local methods = peripheral.getMethods(peripheral.getName(peripheralObj))
    logger.log("Response:")
    logger.log(methods)

    rednet.send(senderID, methods)
end

-- Method for handling method call requests
local function handleCallMethod(peripheralName, methodName, senderID, args)
    local peripheralObj = peripheral.find(peripheralName)
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
        local success, result = pcall(peripheralObj[methodName], unpack(serializedArgs))
        if success then
            message = {result}
        else 
            message = {error = "failed_method_call", errorDesc = result}    
        end

    end
    logger.log("Response:")
    logger.log(message)
    rednet.send(senderID, message)
end

local messageCount = 0

-- Event loop for handling requests from a PeripheralProxy object
while true do
    logger.log("waiting for message " .. messageCount)
    local senderID, message, protocol = rednet.receive()
    messageCount = messageCount + 1
    logger.log("received message ".. messageCount.."... processing!")
    logger.log(message)
    if message and message.peripheralName and message.method then
        local peripheralName = message.peripheralName
        local methodName = message.method
        local args = message.args
        

        if methodName == "getMethods" then
            handleGetMethods(peripheralName,senderID)
        else
            handleCallMethod(peripheralName, methodName, senderID, args)
        end
    else
        rednet.send(senderID, {error = "missing_param"})
    end
end