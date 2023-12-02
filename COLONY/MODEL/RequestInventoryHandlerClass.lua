-- RequestInventoryHandlerClass.lua
RequestInventoryHandlerClass = {}
RequestInventoryHandlerClass.__index = RequestInventoryHandlerClass

-- Constructor for RequestInventoryHandlerClass
function RequestInventoryHandlerClass:new(document)
    local o = setmetatable({}, RequestInventoryHandlerClass)
    o.tableFileHandler = TableFileHandlerClass:new(document.config:getRequestInventoryPath())
    return o
end

function RequestInventoryHandlerClass:getRequestInventoryKey()
    return self.tableFileHandler:read()[1]
end


function RequestInventoryHandlerClass:setRequestInventoryKey(inventoryKey)
    self.tableFileHandler:write({inventoryKey})
end

return RequestInventoryHandlerClass