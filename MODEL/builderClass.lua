-- WorkOrderClass.lua
local ObClass = require("MODEL.obClass")  -- Adjust the path if necessary
local logger  = require("UTIL.logger")


local BuilderClass = {}
BuilderClass.__index = BuilderClass
setmetatable(BuilderClass, { __index = ObClass })

-- Constructor for WorkOrderClass
function BuilderClass:new(builderData)
    local uniqueKey = builderData.id
    self = setmetatable(ObClass:new(uniqueKey), BuilderClass)
    self.id = self.uniqueKey
    self.associatedInventory = nil


    self.name = builderData.name
    if builderData.work then
        self.builderHutLocation = builderData.work.location
        self.builderHutLevel = builderData.work.level
    end
    self.state = builderData.state

    return self
end

function BuilderClass:setAssociatedInventory(inventory)
    self.associatedInventory = inventory
end

-- Overriding GetKeyDisplayString method
function BuilderClass:GetKeyDisplayString()
    return self.uniqueKey
end

-- Overriding GetDisplayString method
function BuilderClass:GetDisplayString()
    local inventoryDisplay = "Error (Will use default!)"
    if self.associatedInventory then
        inventoryDisplay = self.associatedInventory:GetDisplayString()
    end
    return string.format("ID: %s \nName: %s\nHut level: %s\nStatus: %s\nTarget Inventory: %s", 
                         self.id, 
                         self.name, 
                         self.builderHutLevel, 
                         self.state, 
                         inventoryDisplay)
end


return BuilderClass