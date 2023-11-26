-- WorkOrderClass.lua
local ObClass = require("MODEL.ObClass")  -- Adjust the path if necessary
local logger  = require("UTIL.logger")
local stringUtils = require("UTIL.stringUtils")


local MeSystemClass = {}
MeSystemClass.__index = MeSystemClass
setmetatable(MeSystemClass, { __index = ObClass })

-- Constructor for WorkOrderClass
function MeSystemClass:new(meData,manager)
    local uniqueKey = "ME_SYSTEM" -- only support 1 me system for now.
    local o = setmetatable(ObClass:new(uniqueKey), MeSystemClass)
    o.manager = manager
    o.id = o.uniqueKey

    o.availableItemStorage = meData.availableItemStorage
    o.usedItemStorage = meData.usedItemStorage
    o.totalItemStorage = meData.totalItemStorage
    o.cells = meData.cells
    o.craftingCpus = meData.craftingCpus
    o.energyStorage = meData.energyStorage
    o.maxEnergyStorage = meData.maxEnergyStorage
    o.energyUsage = meData.energyUsage

    return o
end

function MeSystemClass:getUsedPercentage()
    return math.floor((self.usedItemStorage / self.totalItemStorage)*100)
end

function MeSystemClass:getFreePercentage()
    return 100 - self:getUsedPercentage()
end

function MeSystemClass:getEnergyPercentage()
    return math.floor((self.energyStorage / self.maxEnergyStorage)*100)
end

function MeSystemClass:getNumberOfCraftingCells()
    return #self.cells
end

return MeSystemClass