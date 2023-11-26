-- WorkOrderClass.lua
local ObClass = require("MODEL.ObClass")  -- Adjust the path if necessary
local logger  = require("UTIL.logger")


local BuilderClass = {}
BuilderClass.__index = BuilderClass
setmetatable(BuilderClass, { __index = ObClass })

-- Constructor for WorkOrderClass
function BuilderClass:new(builderData, manager)
    local uniqueKey = builderData.id
    self = setmetatable(ObClass:new(uniqueKey), BuilderClass)
    self.id = self.uniqueKey
    self.associatedInventoryName = nil
    self.manager = manager


    self.name = builderData.name
    if builderData.work then
        self.builderHutLocation = builderData.work.location
        self.builderHutLevel = builderData.work.level
    end
    self.state = builderData.state

    return self
end

function BuilderClass:setAssociatedInventory(inventoryName)
    self.associatedInventoryName = inventoryName
    self.manager:onAssociationModified(self)
end

function BuilderClass:getAssociatedInventory()
    return self.associatedInventoryName
end

-- Overriding GetKeyDisplayString method
function BuilderClass:GetKeyDisplayString()
    return self.uniqueKey
end

-- Overriding GetDisplayString method
function BuilderClass:GetDisplayString()
    local inventoryDisplay = "Error (Will use default!)"
    if self.associatedInventoryName then
        inventoryDisplay = self.associatedInventoryName
    end
    return string.format("ID: %s \nName: %s\nHut level: %s\nStatus: %s\nTarget Inventory: %s", 
                         self.id, 
                         self.name, 
                         self.builderHutLevel, 
                         self.state, 
                         inventoryDisplay)
end


return BuilderClass