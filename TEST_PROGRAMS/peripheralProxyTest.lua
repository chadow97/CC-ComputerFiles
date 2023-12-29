package.path = package.path .. ";/?;/?.lua"
local logger = require("UTIL.logger")
logger.init(term.current())

local peripheralProxyClass = require("UTIL.peripheralProxy")
local ConnectionClass = require("UTIL.RemoteConnectionClass")
local channel = 1


local args = {...}

local peripheralType = args[1]
local methodName = args[2]
local functionArgs = args
table.remove(functionArgs,1)
table.remove(functionArgs,1)

local connection = ConnectionClass:new(channel, "right")


local per = peripheralProxyClass:new(connection, peripheralType )


logger.log(per:callMethod(methodName,table.unpack(functionArgs)), logger.LOGGING_LEVEL.INFO)