-- WorkOrderClass.lua
local ObClass = require("MODEL.obClass")  -- Adjust the path if necessary

local RESSOURCE_STATUS_LIST = {
    all_in_external_inv = 1,
    all_in_me_or_ex = 2,
    no_missing = 3,
    missing_not_craftable = 4,
    craftable = 5}

local RessourceClass = {}

RessourceClass.__index = RessourceClass
setmetatable(RessourceClass, { __index = ObClass })

-- Constructor for WorkOrderClass
function RessourceClass:new(ressourceRequirement, meDataForRessource, amountInExternalInventory)
    local itemID = ressourceRequirement.item
    self = setmetatable(ObClass:new(itemID), RessourceClass)


    self.itemId = itemID
    self.neededForColony = ressourceRequirement.needed
    self.availableInColony = ressourceRequirement.available
    self.deliveringInColony = ressourceRequirement.delivering
    
    self.amountInExternalInventory = amountInExternalInventory

    self.amountInMeSystem = meDataForRessource.amount

    self.missingInColony = self.neededForColony - self.availableInColony - self.deliveringInColony
    self.missingWithExternalInventory = self.missingInColony - self.amountInExternalInventory
    self.missingWithExternalInventoryAndMe = self.missingWithExternalInventory - self.amountInMeSystem
    self.isCraftableInMeSystem = meDataForRessource.isCraftable

    self.status = self:getItemStatus()
    
    return self
end

function RessourceClass:getItemStatus()

    if self.missingInColony <= 0 then
        return RESSOURCE_STATUS_LIST.no_missing
    elseif self.missingWithExternalInventory <= 0 then
        return RESSOURCE_STATUS_LIST.all_in_external_inv
    elseif self.missingWithExternalInventoryAndMe <= 0 then
        return RESSOURCE_STATUS_LIST.all_in_me_or_ex
    elseif self.isCraftableInMeSystem then
        return RESSOURCE_STATUS_LIST.craftable
    else
        return RESSOURCE_STATUS_LIST.missing_not_craftable
    end

end

-- Overriding GetKeyDisplayString method
function RessourceClass:GetKeyDisplayString()
    return self.uniqueKey
end

-- Overriding GetDisplayString method
function RessourceClass:GetDisplayString()

    local actionToDisplay = ""
    if self.status == RESSOURCE_STATUS_LIST.no_missing or self.status == RESSOURCE_STATUS_LIST.all_in_external_inv then
        actionToDisplay = "Nothing to do."
    elseif self.status == RESSOURCE_STATUS_LIST.all_in_me_or_ex then
        actionToDisplay = "Press to send to external inv."
    elseif self.status == RESSOURCE_STATUS_LIST.missing_not_craftable then
        actionToDisplay = "Missing and cannot be crafted!"
    elseif self.status == RESSOURCE_STATUS_LIST.craftable then
        actionToDisplay = "Press to craft."
    end

    return string.format("%s \nNeeded for colony: %s \nAmount in me system: %s \nAmount in External storage: %s \nAmount missing in colony/ext: %s \n %s", 
                         self.itemId, self.missingInColony, self.amountInMeSystem, self.amountInExternalInventory, self.missingWithExternalInventoryAndMe, actionToDisplay)
end

function RessourceClass:getObStyle()
    -- return elementBackColor, elementTextColor
    local elementBackColor = nil

    local elementTextColor = colors.white
    if self.status == RESSOURCE_STATUS_LIST.no_missing or self.status == RESSOURCE_STATUS_LIST.all_in_external_inv then
        elementTextColor = colors.green
    elseif self.status == RESSOURCE_STATUS_LIST.all_in_me_or_ex then
        elementTextColor = colors.yellow
    elseif self.status == RESSOURCE_STATUS_LIST.missing_not_craftable then
        elementTextColor = colors.red
    elseif self.status == RESSOURCE_STATUS_LIST.craftable then
        elementTextColor = colors.orange
    end

    return elementBackColor, elementTextColor
end

-- Static method to create a WorkOrder from a WorkOrderDataTable
function RessourceClass.CreateRessource(ressourceRequirement, meDataForRessource, amountInExternalInventory)
    return RessourceClass:new(ressourceRequirement, meDataForRessource, amountInExternalInventory )
end

return RessourceClass