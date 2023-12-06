package.path = package.path .. ";/?;/?.lua"
local logger = require("UTIL.logger")
logger.init(term.current(),"remoteComputerText", true)

local peripheralProxyClass = require("UTIL.peripheralProxy")
local ConnectionClass = require("UTIL.RemoteConnectionClass")
local RemoteComputerClass = require("UTIL.RemoteComputerClass")

local channel = 1

local connection = ConnectionClass:new(channel, "right")
local remoteComputer = RemoteComputerClass:new(connection)
logger.logGenericTableToFile(remoteComputer:getPeripherals())

