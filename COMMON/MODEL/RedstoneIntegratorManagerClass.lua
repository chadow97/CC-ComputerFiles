-- RedstoneIntegratorManagerClass.lua
local ManagerClass = require("MODEL.ManagerClass")  -- Adjust the path if necessary
local PerTypes     = require("UTIL.perTypes")
local MeSystemClass = require("COMMON.MODEL.MeSystemClass")
local logger         = require("UTIL.logger")
local RedstoneIntegratorClass = require("COMMON.MODEL.RedstoneIntegratorClass")



local RedstoneIntegratorManagerClass = {}
RedstoneIntegratorManagerClass.__index = RedstoneIntegratorManagerClass
setmetatable(RedstoneIntegratorManagerClass, { __index = ManagerClass })
RedstoneIntegratorManagerClass.HANDLED_TYPES = {PerTypes.chest, PerTypes.barrel}

RedstoneIntegratorManagerClass.TYPE = "REDSTONE INTEGRATOR"
-- Constructor for RedstoneIntegratorManagerClass
function RedstoneIntegratorManagerClass:new(document)
    local o = setmetatable(ManagerClass:new(document), RedstoneIntegratorManagerClass)
    o.type = RedstoneIntegratorManagerClass.TYPE
    o.redstoneIntegrators = {}
    return o
end

function RedstoneIntegratorManagerClass:_getObsInternal()
    return self.redstoneIntegrators
end


function RedstoneIntegratorManagerClass:_onRefreshObs()
    self.redstoneIntegrators = {}
---@diagnostic disable-next-line: param-type-mismatch
    local redstoneIntegratorPers = {peripheral.find(PerTypes.redstone_integrator)}
    if not redstoneIntegratorPers then
        redstoneIntegratorPers = {}
    end

    for _, redstoneIntegratorPer in pairs(redstoneIntegratorPers) do
        local RIob = RedstoneIntegratorClass:new(redstoneIntegratorPer)
        table.insert(self.redstoneIntegrators, RIob)
    end
end

return RedstoneIntegratorManagerClass