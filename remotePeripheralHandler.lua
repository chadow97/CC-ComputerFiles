local logger = require("UTIL.logger")


local terminal = term.current()
local monitor = peripheral.find("monitor")
if monitor then
    terminal = monitor
end

logger.init(terminal)

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
        local success, result = pcall(peripheralObj[methodName], unpack(args))
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

-- Event loop for handling requests from a PeripheralProxy object
while true do
    local senderID, message, protocol = rednet.receive()
    logger.log("received message ... processing!")
    if message and message.peripheralName and message.method then
        local peripheralName = message.peripheralName
        local methodName = message.method
        local args = message.args
        logger.log(message)

        if methodName == "getMethods" then
            handleGetMethods(peripheralName,senderID)
        else
            handleCallMethod(peripheralName, methodName, senderID, args)
        end
    else
        rednet.send(senderID, {error = "missing_param"})
    end
end