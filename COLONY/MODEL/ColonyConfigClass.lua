local ConfigClass = require("MODEL.ConfigClass") 
local logger                  = require("UTIL.logger")

---@class ColonyConfig: Config
local ColonyConfigClass = {}
ColonyConfigClass.__index = ColonyConfigClass
setmetatable(ColonyConfigClass, { __index = ConfigClass })


ColonyConfigClass.configs = 
    {
    data_dir_path ="data_path",
    association_filename = "association_filename",
    request_inventory_filename = "request_inventory_filename",
    proxy_peripherals_channel = "proxy_peripherals_channel",
    primary_style = "primary_style",
    secondary_style = "secondary_style",
    tertiary_style = "tertiary_style",
    ri_file = "ri_file"
    }

-- Constructor for WorkOrderClass
function ColonyConfigClass:new()

    local o = setmetatable(ConfigClass:new(), ColonyConfigClass)
    -- set config variables for colony
    o:setDefault(ColonyConfigClass.configs.association_filename, "associations.txt")
    o:setDefault(ColonyConfigClass.configs.request_inventory_filename, "request_inventory.txt")
    o:setDefault(ColonyConfigClass.configs.proxy_peripherals_channel, 1)
    o:setDefault(ColonyConfigClass.configs.primary_style, colors.gray)
    o:setDefault(ColonyConfigClass.configs.secondary_style, colors.green)
    o:setDefault(ColonyConfigClass.configs.tertiary_style, colors.yellow)
    o:setDefault(ColonyConfigClass.configs.ri_file, "ri.txt")

    return o
end

function ColonyConfigClass:getAssociationsPath()
    return fs.combine(self:get(ConfigClass.configs.data_dir_path),
                      self:get(ColonyConfigClass.configs.association_filename))
end

function ColonyConfigClass:getRequestInventoryPath()
    return fs.combine(self:get(ConfigClass.configs.data_dir_path),
                      self:get(ColonyConfigClass.configs.request_inventory_filename))
end

function ColonyConfigClass:getRiPath()
    return fs.combine(self:get(ConfigClass.configs.data_dir_path),
                      self:get(ColonyConfigClass.configs.ri_file))
end

function ColonyConfigClass:getStyles()
    return self:get(ColonyConfigClass.configs.primary_style), self:get(ColonyConfigClass.configs.secondary_style),self:get(ColonyConfigClass.configs.tertiary_style)
end

function ColonyConfigClass:getPrimaryStyle()
    return self:get(ColonyConfigClass.configs.primary_style)
end

function ColonyConfigClass:getSecondaryStyle()
    return self:get(ColonyConfigClass.configs.secondary_style)
end

function ColonyConfigClass:getTertiaryStyle()
    return self:get(ColonyConfigClass.configs.tertiary_style)
end

return ColonyConfigClass