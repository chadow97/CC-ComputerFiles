local logger = require("UTIL.logger")

-- colonyIntegratorPerUtils.lua

local ColonyIntegratorPerUtils = {}  -- create a new module table

ColonyIntegratorPerUtils.NoWorkOrderCode = "no_work_order"
ColonyIntegratorPerUtils.FailedGetWorkOrder = "first_order_get_fail"

function ColonyIntegratorPerUtils.getWorkOrders(per)
  -- perform some operations to fetch work orders
  -- flatten table

  local workOrders = per.getWorkOrders()
  if type(workOrders) ~= "table" then
    -- return error
    if type(workOrders) == "string" then
        error(workOrders) 
    else
        error("Unhandled error!")
    end
  end
  
  return workOrders


end

function ColonyIntegratorPerUtils.getFirstWorkOrderId(per)
    local AllWorkOrders = per.getWorkOrders()

    local FirstWorkOrderId = nil
    for _, workOrder in ipairs(AllWorkOrders) do
        if workOrder.type == "WorkOrderBuilding" then
            FirstWorkOrderId = workOrder.id
        end
    end
    if not FirstWorkOrderId then
        return ColonyIntegratorPerUtils.NoWorkOrderCode
    end
    return FirstWorkOrderId
end

function ColonyIntegratorPerUtils.getFirstWorkOrderResources(per)
    local FirstWorkOrderId = ColonyIntegratorPerUtils.getFirstWorkOrderId(per)
    if FirstWorkOrderId == ColonyIntegratorPerUtils.NoWorkOrderCode then
        return ColonyIntegratorPerUtils.NoWorkOrderCode
    end
    
    local FirstWorkOrder = per:getWorkOrderResources(FirstWorkOrderId)

    if not FirstWorkOrder then
        return ColonyIntegratorPerUtils.FailedGetWorkOrder
    end

    return FirstWorkOrder
  
  end

function ColonyIntegratorPerUtils.getMissingRessourcesFromWorkOrder(per, workOrderId)
    local WorkOrderRessources = per:getWorkOrderResources(workOrderId)
    if not WorkOrderRessources then
        return ColonyIntegratorPerUtils.FailedGetWorkOrder
    end
    local missingRessources = {}
    for _,ressource in ipairs(WorkOrderRessources) do
        if ressource.status ~= "NOT_NEEDED" then
            ressource.missing = ressource.needed - ressource.available - ressource.delivering
            table.insert(missingRessources,ressource)
        end
    end
    return missingRessources

end

function ColonyIntegratorPerUtils.getBuildings(per)
    return per.getBuildings()
end

function ColonyIntegratorPerUtils.getRequests(per)
    return per.getRequests()
end

function ColonyIntegratorPerUtils.getWorkOrderById(per, workOrderId)
    local workOrders = ColonyIntegratorPerUtils.getWorkOrders(per)
    local requestedWorkOrder = nil
    for _, workOrder in ipairs(workOrders) do
        if workOrder.id == workOrderId then
            requestedWorkOrder = workOrder
        end
    end
    if not requestedWorkOrder then
        logger.log("Couldn't find WorkOrder by ID!", logger.LOGGING_LEVEL.ERROR)
    end
    return requestedWorkOrder
end

function ColonyIntegratorPerUtils.getBuilderHutInfoFromWorkOrderId(per, workOrderId)
    local workOrder = ColonyIntegratorPerUtils.getWorkOrderById(per, workOrderId)
    return ColonyIntegratorPerUtils.getBuilderHutInfoFromWorkOrder(per, workOrder)
end

function ColonyIntegratorPerUtils.getBuildingByPosition(per, position)
    local buildingRequested = nil
    local buildingList = ColonyIntegratorPerUtils.getBuildings(per)
    for _, building in pairs(buildingList) do
        local buildingLocation = building.location
        if (buildingLocation.x == position.x and
            buildingLocation.y == position.y and
            buildingLocation.z == position.z) then
                buildingRequested = building
                break
            end
        
    end
    return buildingRequested
end

function ColonyIntegratorPerUtils.getBuilders(per)
    return ColonyIntegratorPerUtils.getCitizensByType(per, "builder")
end

function ColonyIntegratorPerUtils.getCitizensByType(per, type)
    if not type then
        return ColonyIntegratorPerUtils.getCitizens(per)
    end
    local citizensForType = {}
    local citizens = ColonyIntegratorPerUtils.getCitizens(per)
    for _, citizen in pairs(citizens) do
        if citizen.work and citizen.work.type == type then
            citizensForType[citizen.id] = citizen
        end
    end
    return citizensForType
    
end

function ColonyIntegratorPerUtils.getCitizens(per)
    return per.getCitizens()
end

function ColonyIntegratorPerUtils.getBuilderHutInfoFromWorkOrder(per, workOrder)
    local builderHutPosition = workOrder.builder
    local builderHutInfo = nil
    if not builderHutPosition then
        return builderHutInfo
    end

    builderHutInfo = ColonyIntegratorPerUtils.getBuildingByPosition(per, builderHutPosition)
    if not builderHutInfo then
        logger.log("No builder hut found!", logger.LOGGING_LEVEL.ERROR)
    end
    return builderHutInfo
end

function ColonyIntegratorPerUtils.getColony(per)
    local colony = {}
    colony.id = per.getColonyID()
    colony.name = per.getColonyName()
    colony.style = per.getColonyStyle()
    colony.location = per.getLocation()
    colony.happiness = per.getHappiness()
    colony.isActive = per.isActive()
    colony.isUnderAttack = per.isUnderAttack()
    colony.amountOfCitizens = per.amountOfCitizens()
    colony.maxOfCitizens = per.maxOfCitizens()
    colony.amountOfGraves = per.amountOfGraves()
    colony.amountOfConstructionSites = per.amountOfConstructionSites()
    return colony

end

return ColonyIntegratorPerUtils  -- return the module table at the end of the file

