-- WorkOrderClass.lua
local ObClass = require("MODEL.obClass")  -- Adjust the path if necessary


local WorkOrderClass = {}
WorkOrderClass.__index = WorkOrderClass
setmetatable(WorkOrderClass, { __index = ObClass })

-- Constructor for WorkOrderClass
function WorkOrderClass:new(uniqueKey, buildingType)
    self = setmetatable(ObClass:new(uniqueKey), WorkOrderClass)
    self.buildingType = buildingType  -- Storing the buildingType
    self.id = self.uniqueKey
    return self
end

-- Overriding GetKeyDisplayString method
function WorkOrderClass:GetKeyDisplayString()
    return self.uniqueKey
end

-- Overriding GetDisplayString method
function WorkOrderClass:GetDisplayString()
    return string.format("Pending work order %s \nBuilding %s", self.uniqueKey, self.buildingType)
end

-- Static method to create a WorkOrder from a WorkOrderDataTable
function WorkOrderClass.CreateWorkOrder(WorkOrderDataTable)
    return WorkOrderClass:new(WorkOrderDataTable.id, WorkOrderDataTable.buildingName )
end

return WorkOrderClass