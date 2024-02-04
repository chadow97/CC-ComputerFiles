-- WorkOrderFetcher.lua
local DataFetcherClass = require("MODEL.DataFetcherClass") 
local RequestItemManagerClass = require("COLONY.MODEL.RequestItemManagerClass")
local logger = require("UTIL.logger")




local RequestItemsFetcherClass = {}

RequestItemsFetcherClass.__index = RequestItemsFetcherClass
setmetatable(RequestItemsFetcherClass, { __index = DataFetcherClass })

function RequestItemsFetcherClass:new(requestId, document)

    local o = setmetatable(DataFetcherClass:new(), RequestItemsFetcherClass)
    o.document = document
    o.requestItemsManager = o.document:getManagerForType(RequestItemManagerClass.TYPE)
    o.requestId = requestId

    return o
end

function RequestItemsFetcherClass:getObs()
    local items = self.requestItemsManager:getItemsForRequest(self.requestId)
    logger.db(items)
    return items
end

return RequestItemsFetcherClass