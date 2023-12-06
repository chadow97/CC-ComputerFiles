local ConfigClass = require("MODEL.ConfigClass") 
local logger                  = require("UTIL.logger")


local ColonyConfigClass = {}
ColonyConfigClass.__index = ColonyConfigClass
setmetatable(ColonyConfigClass, { __index = ConfigClass })


ColonyConfigClass.configs = 
    {
    data_dir_path ="data_path",
    association_filename = "association_filename",
    request_inventory_filename = "request_inventory_filename",
    proxy_peripherals_channel = "proxy_peripherals_channel"
    }

-- Constructor for WorkOrderClass
function ColonyConfigClass:new()

    local o = setmetatable(ConfigClass:new(), ColonyConfigClass)
    -- set config variables for colony
    o:set(ColonyConfigClass.configs.data_dir_path, "./DATA/")
    o:set(ColonyConfigClass.configs.association_filename, "associations.txt")
    o:set(ColonyConfigClass.configs.request_inventory_filename, "request_inventory.txt")
    o:set(ColonyConfigClass.configs.proxy_peripherals_channel, 1)

    return o
end

function ColonyConfigClass:getAssociationsPath()
    return fs.combine(self:get(ColonyConfigClass.configs.data_dir_path),
                      self:get(ColonyConfigClass.configs.association_filename))
end

function ColonyConfigClass:getRequestInventoryPath()
    return fs.combine(self:get(ColonyConfigClass.configs.data_dir_path),
                      self:get(ColonyConfigClass.configs.request_inventory_filename))
end

return ColonyConfigClass