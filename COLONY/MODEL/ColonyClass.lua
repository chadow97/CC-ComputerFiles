-- WorkOrderClass.lua
local ObClass = require("MODEL.ObClass")  -- Adjust the path if necessary
local logger  = require("UTIL.logger")
local stringUtils = require("UTIL.stringUtils")


local ColonyClass = {}
ColonyClass.__index = ColonyClass
setmetatable(ColonyClass, { __index = ObClass })

-- Constructor for WorkOrderClass
function ColonyClass:new(colonyData,manager)
    local uniqueKey = colonyData.id
    local o = setmetatable(ObClass:new(uniqueKey), ColonyClass)
    o.manager = manager
    o.id = o.uniqueKey

    o.name = colonyData.name
    o.style = colonyData.style
    o.location = colonyData.location
    o.happiness = colonyData.happiness
    o.isActive = colonyData.isActive
    o.isUnderAttack = colonyData.isUnderAttack
    o.amountOfCitizens = colonyData.amountOfCitizens
    o.maxOfCitizens = colonyData.maxOfCitizens
    o.amountOfGraves = colonyData.amountOfGraves
    o.amountOfConstructionSites = colonyData.amountOfConstructionSites

    return o
end

-- Overriding GetKeyDisplayString method
function ColonyClass:GetKeyDisplayString()
    return self.uniqueKey
end

-- Overriding GetDisplayString method
function ColonyClass:GetDisplayString()
    return stringUtils.UFormat("Colony %s",self.name)
end


return ColonyClass