-- WorkOrderFetcher.lua
local DataFetcherClass = require("MODEL.dataFetcherClass") 
local WorkOrderClass = require("MODEL.workOrderClass")
local colIntUtil = require("UTIL.colonyIntegratorPerUtils")
local logger = require("UTIL.logger")
local MeUtils= require("UTIL.meUtils")
local RessourceClass = require("MODEL.ressourceClass")
local RequestItemManagerClass = require("MODEL.requestItemManagerClass")




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