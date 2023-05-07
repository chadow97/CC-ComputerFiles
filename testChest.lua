
local chestName = "minecraft:chest_0"
local dispenserName = "minecraft:dispenser_0"
local furnaceName = "minecraft:furnace_0"
local chest = peripheral.wrap("minecraft:chest_0")
local logger = require("UTIL.logger")

local terminal = term.current()
logger.init(terminal, "buttonTest", true)

logger.log(peripheral.getNames())

logger.log(peripheral.getType(chest))
logger.log(peripheral.getMethods(chestName))
logger.log(peripheral.)