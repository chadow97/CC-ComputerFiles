local logger = require "UTIL.logger"
local PerUtils = {}

function PerUtils.getMePer()
    local MePer = peripheral.find("meBridge")
    if MePer == nil then
        print("Could not find Me Peripheral")
    end
    return MePer
end

function PerUtils.getPerNames()
    local peripherals = {}
    return peripheral.getNames()

end

function PerUtils.getPerNamesAndTypes()
    local peripherals = {}
    local names = PerUtils.getPerNames()
    for i = 1, #names do
      local name = names[i]
      peripherals[name] = peripheral.getType(name)
    end
    return peripherals
end

function PerUtils.getAllPeripherals()  
    local results = {}
    for _, name in ipairs(peripheral.getNames()) do
        local wrapped = peripheral.wrap(name)
        table.insert(results, wrapped)
    end
    return results
end

function PerUtils.getPerFromName(peripheral_name)
    local peripheral_object = peripheral.wrap(peripheral_name)
    if peripheral_object == nil then
        -- try to find with type if possible
        print("didnt find per!")
        peripheral_object = peripheral.find(peripheral_name)
        print("per.find")
        logger.logOnError(peripheral_object, "Invalid peripheral!") 
        print("per.log on error")    
    end

    return peripheral_object
end

function PerUtils.getPerMethods(peripheral_name)
    local methods = {}
    local peripheral_object = PerUtils.getPerFromName(peripheral_name)

    if peripheral_object == nil then
        return methods
    end
        
    for method_name, method in pairs(peripheral_object) do
        if type(method) == "function" then
        table.insert(methods, method_name)
        end
    end
    return methods
end

function PerUtils.callPerObjMethod(peripheral_object, function_name, ...)
    if (peripheral_object == nil) then
        print("Error: Cannot call method as peripheral is invalid")
        return
    end
    local func = peripheral_object[function_name]
    if type(func) == "function" then
        return func(...)
    else
        print("Error: Invalid function name")
        return nil
    end

end

function PerUtils.callPerNameMethod(peripheral_name, function_name, ...)
    print("Name is " ..peripheral_name)
    local peripheral_object = PerUtils.getPerFromName(peripheral_name)
    return PerUtils.callPerObjMethod(peripheral_object, function_name, ...)
end



local args ={...}


return PerUtils
