
---@diagnostic disable-next-line: different-requires
local functionHelperUtils = require("functionHelperUtils")

local function toboolean(str)
    local bool = false
    if str == "true" or str == "t" or str == "1" then
        bool = true
    end
    return bool
end


local args = {...}

local libName = args[1]
local libFunction = args[2]
local fileName = args[3]
local functionArgs = nil



if libName == nil then
    print("Provide a library to print/call functions")
    return
end

if libFunction == nil then
    print("Please provide a libFunction to call")
    return
end

if fileName == nil then   
    fileName = "DefaultOutputFile"
    print("Printing to default file " .. fileName)
end

functionArgs  = args
-- remove first 3 arguments
table.remove(functionArgs,1)
table.remove(functionArgs,1)
table.remove(functionArgs,1)



functionHelperUtils.printLine()
functionHelperUtils.printTitle(true, libName, libFunction)
functionHelperUtils.printLine()


local lib = require(libName)


functionHelperUtils.callFunction(lib, libFunction, functionArgs, true, fileName)


functionHelperUtils.printLine()

--Example libraryFunctionHelperToFile perUtils callPerNameMethod test2 mebridge listItems
-- Call library function perUtils.callPerNameMethod with param meBridge and listItems, and outputs to test2