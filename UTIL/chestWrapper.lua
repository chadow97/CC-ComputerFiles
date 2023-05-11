local logger = require("UTIL.logger")
local PeripheralWrapper = require("UTIL.peripheralWrapper")
local PerTypes = require("UTIL.perTypes")



-- Define the ChestWrapper class as a subclass of PeripheralWrapper
local ChestWrapper = {}
ChestWrapper.__index = ChestWrapper
setmetatable(ChestWrapper, { __index = PeripheralWrapper })


-- Constructor function for creating new instances of the class
function ChestWrapper:new(peripheralNameOrType)
    local internalPerNameOrType = peripheralNameOrType or PerTypes.chest
    local instance = PeripheralWrapper.new(self, internalPerNameOrType)
    if not instance then
        return nil
    end
    -- Check if the peripheral is a chest
    if instance.type ~= PerTypes.chest then
        return nil
    end
    setmetatable(instance, ChestWrapper)
    return instance
end

-- Method for getting all items in the chest
function ChestWrapper:getAllItems()
    --get Total amount
    local totalAmount = {} --format {name:count}
    -- returns all the different stacks
    local itemSlots = self.per.list() --format:{count, name(id)}
    for _, slot in pairs(itemSlots) do
        if not totalAmount[slot.name] then
            totalAmount[slot.name] = slot.count
        else
            totalAmount[slot.name] = totalAmount[slot.name] + slot.count
        end
    end

    return totalAmount
end


function ChestWrapper:__index(key)
    --save debug info!
    local info = debug.getinfo(2, "Sl")




    local mt = getmetatable(self)
    if rawget(self, key) ~= nil or mt[key] ~= nil then
      return rawget(self, key) or mt[key]
    else
      local func = function(_, ...)
        return self:callMethodInternal(key, info, ...)
      end
      return func
    end
  end

return ChestWrapper