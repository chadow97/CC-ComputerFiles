
local customPrintUtils = require("customPrintUtils")
local functionHelperUtils = require("functionHelperUtils")


local args = {...}

local libName = args[1]
local libFunction = args[2]
local isCalling = (libFunction ~= nil)
local functionArgs = nil



if libName == nil then
    print("Provide a library to print/call functions")
    return
end

if (isCalling) then
    functionArgs  = args
    -- remove first 2 arguments
    table.remove(functionArgs,1)
    table.remove(functionArgs,1)
end

functionHelperUtils.printLine()
functionHelperUtils.printTitle(isCalling, libName, libFunction)
functionHelperUtils.printLine()


local lib = require(libName)

if isCalling then
    functionHelperUtils.callFunction(lib, libFunction, functionArgs)
else
    functionHelperUtils.printFunctions(lib)
end


functionHelperUtils.printLine()
