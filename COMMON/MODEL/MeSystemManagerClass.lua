-- MeSystemManagerClass.lua
local ManagerClass = require("MODEL.ManagerClass")  -- Adjust the path if necessary
local PerTypes     = require("UTIL.perTypes")
local MeSystemClass = require("COMMON.MODEL.MeSystemClass")
local logger         = require("UTIL.logger")



local MeSystemManagerClass = {}
MeSystemManagerClass.__index = MeSystemManagerClass
setmetatable(MeSystemManagerClass, { __index = ManagerClass })
MeSystemManagerClass.HANDLED_TYPES = {PerTypes.chest, PerTypes.barrel}

MeSystemManagerClass.TYPE = "ME SYSTEM"
-- Constructor for MeSystemManagerClass
function MeSystemManagerClass:new(document)
    local o = setmetatable(ManagerClass:new(document), MeSystemManagerClass)
    o.type = MeSystemManagerClass.TYPE
    o.meSystems = {}
    return o
end

function MeSystemManagerClass.isTypeHandled(type)
    return type == PerTypes.me_bridge
end

function MeSystemManagerClass:_getObsInternal()
    return self.meSystems
end

function MeSystemManagerClass:getFirstMeSystem()
    return self:getObs()[1]
end

function MeSystemManagerClass:getDefaultMeSystem()
    return self:getFirstMeSystem()
end

function MeSystemManagerClass:_onRefreshObs()
    self.meSystems = {}
---@diagnostic disable-next-line: param-type-mismatch
    local meSytemsPers = {peripheral.find(PerTypes.me_bridge)}
    if not meSytemsPers then
        meSytemsPers = {}
    end

    for _, meSytemsPer in pairs(meSytemsPers) do
        local inventoryOb = MeSystemClass:new(meSytemsPer)
        table.insert(self.inventories, inventoryOb)
    end
end

return MeSystemManagerClass