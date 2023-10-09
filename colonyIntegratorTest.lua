local colIntUtil = require("UTIL.colonyIntegratorPerUtils")


local logger = require("UTIL.logger")
logger.init(term.current())

local peripheralProxyClass = require("UTIL.peripheralProxy")
local channel = 1

local colIntPer = peripheralProxyClass:new(channel, "colonyIntegrator" )

local WorkOrderId = colIntUtil.getFirstWorkOrderId(colIntPer)
logger.logToFile(colIntUtil.getMissingRessourcesFromWorkOrder(colIntPer,WorkOrderId))