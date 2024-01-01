
local DocumentClass = require("MODEL.DocumentClass")  -- Adjust the path if necessary
local logger                  = require("UTIL.logger")
local MessageManagerClass     = require("RPH.MODEL.MessageManagerClass")



---@class RphDocument:Document
local RphDocumentClass = {}
RphDocumentClass.__index = RphDocumentClass
setmetatable(RphDocumentClass, { __index = DocumentClass })

-- Constructor for WorkOrderClass
function RphDocumentClass:new()

    local o = setmetatable(DocumentClass:new(), RphDocumentClass)
    o:initializeDocument()

    -- register managers used in colony
    o:registerManager(MessageManagerClass:new(o))


    return o
end

return RphDocumentClass