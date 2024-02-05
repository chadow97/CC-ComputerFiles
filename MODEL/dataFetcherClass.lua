-- Define the base class, DataFetcherClass
DataFetcherClass = {}
DataFetcherClass.__index = DataFetcherClass

-- Constructor for DataFetcherClass
function DataFetcherClass:new()
    local self = setmetatable({}, DataFetcherClass)
    return self
end

-- default getOb key method
function DataFetcherClass:getOb(key)
    for _, ob in pairs(self:getObs()) do
        if ob:getUniqueKey() == key then
            return ob
        end     
    end

    return nil
end

-- A method for DataFetcherClass
function DataFetcherClass:getObs()
    error("Should be implemented!")
    return {}  -- Returning an empty list for now
end

return DataFetcherClass