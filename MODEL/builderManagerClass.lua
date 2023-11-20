-- WorkOrderFetcher.lua
local colIntUtil = require("UTIL.colonyIntegratorPerUtils")
local logger = require("UTIL.logger")
local BuilderClass = require("MODEL.builderClass")
local TableFileHandlerClass = require("UTIL.tableFileHandlerClass")
local InventoryManagerClass = require("MODEL.inventoryManagerClass")

local DEFAULT_FILE_PATH = "./DATA/associations.txt"

local BuilderManagerClass = {}

BuilderManagerClass.TYPE = "BUILDER"

BuilderManagerClass.__index = BuilderManagerClass
setmetatable(BuilderManagerClass, { __index = ManagerClass })

function BuilderManagerClass:new(colonyPeripheral, document)
    local o = setmetatable(ManagerClass:new(), BuilderManagerClass)
    o.colonyPeripheral = colonyPeripheral
    o.type = BuilderManagerClass.TYPE
    o.builders = {}
    o.shouldRefresh = true
    o.associations = nil
    o.tableFileHandler = TableFileHandlerClass:new(DEFAULT_FILE_PATH)
    o.document = document

    return o
end

function BuilderManagerClass:getData()

    self.shouldRefresh = true
    return ManagerClass.getData(self)
end


function BuilderManagerClass:getObs()
    if self.shouldRefresh then
        self:refreshObjects()
    end
    return self.builders
end

function BuilderManagerClass:clear()
    self.builders = {}
    self.shouldRefresh = true
end

function BuilderManagerClass:onAssociationModified(builderOb)
    if not self.associations then
        error("tried updating without ever reading!")
    end
    self.associations[builderOb:getUniqueKey()] = builderOb:getAssociatedInventory()
    self.tableFileHandler:write(self.associations)
end

function BuilderManagerClass:refreshObjects()
    self.shouldRefresh = false
    if not self.associations then
        self:readAssociations()
    end
    for index, builderData in ipairs(self:getBuilders()) do

        local potentialOb = BuilderClass:new(builderData, self)
        potentialOb.associatedInventoryName = self.associations[potentialOb:getUniqueKey()]
        if not potentialOb.associatedInventoryName then
            -- get default inventory
            local inventoryMgr = self.document:getManagerForType(InventoryManagerClass.TYPE)
            local defaultInventory = inventoryMgr:getDefaultInventory()
            assert(defaultInventory, "No default inventory!!")
            potentialOb:setAssociatedInventory(defaultInventory:getUniqueKey())
        end

        local currentOb = self:getOb(potentialOb:getUniqueKey())
        if not currentOb then
            table.insert(self.builders, potentialOb)            
        else
            currentOb:copyFrom(potentialOb)
        end

    end
end

function BuilderManagerClass:readAssociations()
    self.associations = self.tableFileHandler:read()
end

function BuilderManagerClass:getBuilders()
    local status, builders = pcall(colIntUtil.getBuilders, self.colonyPeripheral)
    if not status then
        builders = {}
    end
    return builders
end


return BuilderManagerClass