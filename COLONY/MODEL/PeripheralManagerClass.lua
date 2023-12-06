-- PeripheralManagerClass.lua
local ManagerClass = require("MODEL.ManagerClass")  -- Adjust the path if necessary
local logger         = require("UTIL.logger")
local perUtils       = require("UTIL.perUtils")
local PeripheralClass= require("COLONY.MODEL.PeripheralClass")
local InventoryManagerClass = require("COLONY.MODEL.InventoryManagerClass")
local perTypes              = require("UTIL.perTypes")
local ColonyConfigClass     = require("COLONY.MODEL.ColonyConfigClass")
local peripheralProxy       = require("UTIL.peripheralProxy")
local RemoteConnectionClass = require("UTIL.RemoteConnectionClass")
local RemoteComputerClass   = require("UTIL.RemoteComputerClass")


local PeripheralManagerClass = {}
PeripheralManagerClass.__index = PeripheralManagerClass
setmetatable(PeripheralManagerClass, { __index = ManagerClass })

PeripheralManagerClass.TYPE = "Peripheral"
-- Constructor for PeripheralManagerClass
function PeripheralManagerClass:new(document)
    local o = setmetatable(ManagerClass:new(document), PeripheralManagerClass)
    o.type = PeripheralManagerClass.TYPE
    o.peripherals = {}
    o.wasInitialised = false
    o.inventoryManager = o.document:getManagerForType(InventoryManagerClass.TYPE)
    o.wirelessModemToUse = nil
    o.connection = nil
    o.remoteComputer = nil
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

function PeripheralManagerClass:getPeripherals(type, localOnly)
    local peripheralObs = self:getObs()
    local remotePer = {}
    local localPer = {}
    for _, perOb in ipairs(peripheralObs) do
        if type == nil or perOb.type == type then
            logger.log(perOb)
            if perOb.isDistant then
                table.insert(remotePer, perOb)
            else 
                table.insert(localPer, perOb)
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
    -- no preference for now
    local possibleChoices = self:getPeripherals(perTypes.colony_integrator)
    if #possibleChoices > 1 then
        logger.log("Multiple colony integrators! Chose at random", logger.LOGGING_LEVEL.WARNING)
    end
    if #possibleChoices < 1 then
        logger.log("Couldnt find any colony peripheral!", logger.LOGGING_LEVEL.ERROR)
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

function PeripheralManagerClass:_onRefreshObs()
    if self.wasInitialised then
        return
    end
    self.wasInitialised = true
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
        logger.logToFile("No wireless modem found!", logger.LOGGING_LEVEL.WARNING)
    end
    self.wirelessModemToUse = wirelessModemObs[1]
    if #wirelessModemObs > 1 then
        logger.logToFile("More than one wireless modem found, ", logger.LOGGING_LEVEL.WARNING)
    end

    local proxyPerChannel = self.document.config:get(ColonyConfigClass.configs.proxy_peripherals_channel)

    self.connection = RemoteConnectionClass:new(proxyPerChannel, self.wirelessModemToUse.name)
    self.remoteComputer = RemoteComputerClass:new(self.connection)

    local remotePeripheralNames = self.remoteComputer:getPeripherals()
    for _,perName in ipairs(remotePeripheralNames) do
        local type = self.remoteComputer:getType(perName)
        local perProxy = peripheralProxy:new(self.connection, perName)
        local perObFromProxy = PeripheralClass:newFromProxy(perProxy,type)
        table.insert(self.peripherals, perObFromProxy)
    end

end


return PeripheralManagerClass