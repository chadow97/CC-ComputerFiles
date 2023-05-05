local logger = require("UTIL.logger")
logger.init(term.current())

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
  
  return workOrders[1]


end

function ColonyIntegratorPerUtils.getFirstWorkOrderId(per)
    local AllWorkOrders = per.getWorkOrders()[1]

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

    return FirstWorkOrder[1]
  
  end

function ColonyIntegratorPerUtils.getMissingRessourcesFromWorkOrder(per, workOrderId)
    logger.log(workOrderId)

    local WorkOrderRessources = per:getWorkOrderResources(workOrderId)
    if not WorkOrderRessources then
        return ColonyIntegratorPerUtils.FailedGetWorkOrder
    end
    local missingRessources = {}
    for _,ressource in ipairs(WorkOrderRessources[1]) do
        if ressource.status ~= "NOT_NEEDED" then
            ressource.missing = ressource.needed - ressource.available - ressource.delivering
            table.insert(missingRessources,ressource)
        end
    end
    return missingRessources

end







return ColonyIntegratorPerUtils  -- return the module table at the end of the file

