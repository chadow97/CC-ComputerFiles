-- WorkOrderClass.lua
local ObClass = require("MODEL.ObClass")  -- Adjust the path if necessary


local WorkOrderClass = {}
WorkOrderClass.__index = WorkOrderClass
setmetatable(WorkOrderClass, { __index = ObClass })

-- Constructor for WorkOrderClass
function WorkOrderClass:new(uniqueKey, buildingType, builderHutData)
    self = setmetatable(ObClass:new(uniqueKey), WorkOrderClass)
    self.buildingType = buildingType  -- Storing the buildingType
    self.id = self.uniqueKey
    if builderHutData then
        self.hasBuilder = true
        self.nameOfBuiltersHut = builderHutData.name
        self.locationOfBuilderHut = builderHutData.location
        local citizens = builderHutData.citizens
        assert(#citizens == 1, "TOO MANY CITIZENS IN BUILDERS HUT!")
        self.builderName = citizens[1].name
        self.builderID = citizens[1].id
    else
        self.hasBuilder = false
    end
    return self
end

-- Overriding GetKeyDisplayString method
function WorkOrderClass:GetKeyDisplayString()
    return self.uniqueKey
end

-- Overriding GetDisplayString method
function WorkOrderClass:GetDisplayString()
    local displayString = string.format("Pending work order %s \nWork Order building type: %s", self.uniqueKey, self.buildingType)
    if self.hasBuilder then
        displayString = displayString .. string.format("\nBeing built by %s", self.builderName)
    end
    return displayString
end

-- Static method to create a WorkOrder from a WorkOrderDataTable
function WorkOrderClass.CreateWorkOrder(WorkOrderDataTable, builderHutData)
    return WorkOrderClass:new(WorkOrderDataTable.id, WorkOrderDataTable.buildingName, builderHutData)
end

return WorkOrderClass