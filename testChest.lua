
local chestName = "minecraft:chest_0"
local dispenserName = "minecraft:dispenser_0"
local furnaceName = "minecraft:furnace_0"
local chest = peripheral.wrap("minecraft:chest_0")
local logger = require("UTIL.logger")
local ChestWrapper = require("UTIL.chestWrapper")

local terminal = term.current()
logger.init(terminal, "buttonTest", true)

-- Create a new ChestWrapper instance for a chest named "minecraft:chest_1"
local chestPer = ChestWrapper:new()
logger.log(chestPer)
logger.log(chestPer:getAllItems())
