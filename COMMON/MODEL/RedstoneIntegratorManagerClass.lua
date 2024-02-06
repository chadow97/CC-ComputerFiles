-- RedstoneIntegratorManagerClass.lua
local ManagerClass = require("MODEL.ManagerClass")  -- Adjust the path if necessary
local PerTypes     = require("UTIL.perTypes")
local MeSystemClass = require("COMMON.MODEL.MeSystemClass")
local logger         = require("UTIL.logger")
local RedstoneIntegratorClass = require("COMMON.MODEL.RedstoneIntegratorClass")
local InventoryManagerClass   = require("COMMON.MODEL.InventoryManagerClass")



local RedstoneIntegratorManagerClass = {}
RedstoneIntegratorManagerClass.__index = RedstoneIntegratorManagerClass
setmetatable(RedstoneIntegratorManagerClass, { __index = ManagerClass })
RedstoneIntegratorManagerClass.HANDLED_TYPES = {PerTypes.chest, PerTypes.barrel}

RedstoneIntegratorManagerClass.TYPE = "REDSTONE INTEGRATOR"
-- Constructor for RedstoneIntegratorManagerClass
function RedstoneIntegratorManagerClass:new(document)
    local o = setmetatable(ManagerClass:new(document), RedstoneIntegratorManagerClass)
    o.type = RedstoneIntegratorManagerClass.TYPE
    o.tableFileHandler = TableFileHandlerClass:new(o.document.config:getRiPath())
    o.redstoneIntegrators = {}
    o.savedRiData = nil
    return o
end

function RedstoneIntegratorManagerClass:_getObsInternal()
    return self.redstoneIntegrators
end


function RedstoneIntegratorManagerClass:_onRefreshObs()
    if (not self.savedRiData) then
        self.savedRiData = self.tableFileHandler:read()
    end
    self.redstoneIntegrators = {}
---@diagnostic disable-next-line: param-type-mismatch
    local redstoneIntegratorPers = {peripheral.find(PerTypes.redstone_integrator)}
    if not redstoneIntegratorPers then
        redstoneIntegratorPers = {}
    end

    local inventoryMgr = self.document:getManagerForType(InventoryManagerClass.TYPE)

    for _, redstoneIntegratorPer in pairs(redstoneIntegratorPers) do
        local RIob = RedstoneIntegratorClass:new(redstoneIntegratorPer, self)
        local RiSavedData = self.savedRiData[RIob:getUniqueKey()]
        if not RiSavedData then
            RiSavedData = {}
        end
        local isActive = redstoneIntegratorPer.getInput("top")
        local associatedInventory = inventoryMgr:getOb(RiSavedData.associatedInventory)
        RIob:initRi(RiSavedData.nickname, associatedInventory, isActive)
        table.insert(self.redstoneIntegrators, RIob)
    end
end

function RedstoneIntegratorManagerClass:OnRedstoneIntegratorSavedDataModified(ri)
    local riKey = ri:getUniqueKey()
    self.savedRiData[riKey] = self:_getSavedDataFromRi(ri)
    self.tableFileHandler:write(self.savedRiData)
end

function RedstoneIntegratorManagerClass:_getSavedDataFromRi(ri)
    return {nickname = ri.nickname, associatedInventory = ri.associatedInventory}
end

return RedstoneIntegratorManagerClass