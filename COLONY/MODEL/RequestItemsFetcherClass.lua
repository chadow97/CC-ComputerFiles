-- WorkOrderFetcher.lua
local DataFetcherClass = require("MODEL.DataFetcherClass") 
local RequestItemManagerClass = require("COLONY.MODEL.RequestItemManagerClass")




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
    return self.requestItemsManager:getItemsForRequest(self.requestId)
end

return RequestItemsFetcherClass