-- PeripheralManagerClass.lua
local ManagerClass = require("MODEL.ManagerClass")  -- Adjust the path if necessary
local logger         = require("UTIL.logger")
local perUtils       = require("UTIL.perUtils")
local PeripheralClass= require("COMMON.MODEL.PeripheralClass")
local InventoryManagerClass = require("COMMON.MODEL.InventoryManagerClass")
local perTypes              = require("UTIL.perTypes")
local peripheralProxy       = require("UTIL.peripheralProxy")
local RemoteComputerClass   = require("UTIL.RemoteComputerClass")

---@class PeripheralManager: Manager
local PeripheralManagerClass = {}
PeripheralManagerClass.__index = PeripheralManagerClass
setmetatable(PeripheralManagerClass, { __index = ManagerClass })

PeripheralManagerClass.TYPE = "Peripheral"
-- Constructor for PeripheralManagerClass
function PeripheralManagerClass:new(document, connectionProvider)
    ---@class PeripheralManager: Manager
    local o = setmetatable(ManagerClass:new(document), PeripheralManagerClass)
    o.type = PeripheralManagerClass.TYPE
    o.peripherals = {}
    o.wasInitialised = false
    o.inventoryManager = o.document:getManagerForType(InventoryManagerClass.TYPE)
    o.wirelessModemToUse = nil
    o.connection = nil
    o.remoteComputer = nil
    ---@type ConnectionProvider
    o.connectionProvider = connectionProvider
    ---T
    return o
end

-- override to transfer some logic to inventory manager
function PeripheralManagerClass:getObs()
    local allPeripherals = {}
    for _, per in ipairs(ManagerClass.getObs(self)) do
        table.insert(allPeripherals, per)
    end
    for _, per in ipairs(self.inventoryManager:getObs()) do
        table.insert(allPeripherals, per)
    end
    return allPeripherals
end

function PeripheralManagerClass:isRemoteConnectionValid()
    return self.remoteComputer:testConnection()
end

function PeripheralManagerClass:getPeripherals(type, localOnly, filterfunc)
    local peripheralObs = self:getObs()
    local remotePer = {}
    local localPer = {}
    for _, perOb in ipairs(peripheralObs) do
        if type == nil or perOb.type == type then
            if filterfunc == nil or filterfunc(perOb) then
                if perOb.isDistant then
                    table.insert(remotePer, perOb)
                else 
                    table.insert(localPer, perOb)
                end
            end
        end
    end
    if localOnly == true then
        return localPer
    elseif localOnly == false then
        return remotePer
    else
        -- both accepted, but make sure local are first as they are faster!
        local allPer = localPer
        for _, per in ipairs(remotePer) do
            table.insert(allPer, per)
        end
        return allPer
    end

end

function PeripheralManagerClass:getMainColonyPeripheral()
   return self:getMainPeripheral(perTypes.colony_integrator)
end

function PeripheralManagerClass:getLocalWirelessPeripherals()
    local filterfunc = function (per) return per:isWirelessModem()end
    return self:getPeripherals(perTypes.wired_modem, true, filterfunc)
end

function PeripheralManagerClass:getMainPeripheral(type, localOnly, filterFunc)
    local possibleChoices = self:getPeripherals(type, localOnly, filterFunc)
    if #possibleChoices > 1 then
        logger.log(string.format("Can't choose principal peripheral of type %s! Chose at random.",type), logger.LOGGING_LEVEL.WARNING)
    end
    if #possibleChoices < 1 then
        logger.log(string.format("Couldnt find any peripheral of type %s!", type), logger.LOGGING_LEVEL.WARNING)
        return nil
    else
        return possibleChoices[1]
    end
end

function PeripheralManagerClass.getPeripheralObsForType(peripheralsToConsider, type, wirelessModem)
    local perToReturn = {}
    for _,per in ipairs(peripheralsToConsider) do
        if (per.type == type) then
            if (wirelessModem == nil or per.isWireless() == wirelessModem) then
                table.insert(perToReturn, per)
            end
        end
    end
    return perToReturn
end

function PeripheralManagerClass:_getObsInternal()
    return self.peripherals
end

function PeripheralManagerClass:forceCompleteRefresh()
    self.wasInitialised = false
end

function PeripheralManagerClass:_onRefreshObs()
    if self.wasInitialised then
        return
    end
    self.wasInitialised = true
    self.peripherals = {}
    local peripherals = perUtils.getAllPeripherals()
    for _, per in ipairs(peripherals) do
        if not InventoryManagerClass.isTypeHandled(peripheral.getType(per)) then
            local peripheralOb = PeripheralClass:new(per)
            table.insert(self.peripherals, peripheralOb)
        end
    end
    -- get remote peripherals
    -- first, get the wireless modem to use
    local wirelessModemObs = PeripheralManagerClass.getPeripheralObsForType(self.peripherals, perTypes.wired_modem, true)
    if #wirelessModemObs == 0 then
        logger.log("No wireless modem found!", logger.LOGGING_LEVEL.WARNING)
        return
    end
    self.wirelessModemToUse = wirelessModemObs[1]
    if #wirelessModemObs > 1 then
        logger.log("More than one wireless modem found, ", logger.LOGGING_LEVEL.WARNING)
    end

    self.connection = self.connectionProvider:getConnection(self.wirelessModemToUse)

    self.remoteComputer = RemoteComputerClass:new(self.connection)

    local remotePeripheralNames = self.remoteComputer:getPeripherals()
    if not remotePeripheralNames then
        -- remote connection did not answer
        return
    end
    for _,perName in ipairs(remotePeripheralNames) do
        local type = self.remoteComputer:getType(perName)
        local perProxy = peripheralProxy:new(self.connection, perName)
        local perObFromProxy = PeripheralClass:newFromProxy(perProxy,type)
        table.insert(self.peripherals, perObFromProxy)
    end

end


return PeripheralManagerClass