
local logger = require("UTIL.logger")
logger.init(term.current())

local peripheralProxyClass = require("peripheralProxy")
local channel = 1


local args = {...}

local peripheralType = args[1]
local methodName = args[2]
local functionArgs = args
table.remove(functionArgs,1)
table.remove(functionArgs,1)


local per = peripheralProxyClass:new(channel, peripheralType )
--print(per:getRemoteMethods())
--print(per.getTextScaaaaale())

logger.logToFile(per:callMethod(methodName,unpack(functionArgs)))