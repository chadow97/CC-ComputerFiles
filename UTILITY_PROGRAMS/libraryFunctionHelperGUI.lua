local customPrintUtils = require("UTIL.customPrintUtils")
local functionHelperUtils = require("UTIL.functionHelperUtils")


local args = {...}

local libName = args[1]

local function stringToTable(str)
    local words = {}
    for word in str:gmatch("%S+") do
      table.insert(words, word)
    end
    return words
end


if libName == nil then
    print("Provide a library to chose a functions to call!")
    return
end

local lib = require(libName)

if lib == nil then
    print("Invalid Library!")
end

print("Please choose a function to call, enter anything else to exit program")
functionHelperUtils.printFunctions(lib, true)

local input = read() 
local num = tonumber(input)
local functions = functionHelperUtils.getFunctions(lib)
if not num or num <= 0 or num > #functions then
    print("Invalid Choice, terminating")
    return
end

local funcName = functions[num]

print("Should output be printed to file? y or anything else for no")
local isPrinting = false
local input = read()
if (input == "y") then
    isPrinting = true
end

print("Calling " .. funcName .. "\n... Please write any arguments you want to provide to the function. \n Multiple arguments should be separated by a space")
local input = read() 
local funcArgs = stringToTable(input)

if isPrinting then
    functionHelperUtils.callFunction(lib, funcName, funcArgs, true, "output")
else
    functionHelperUtils.callFunction(lib, funcName, funcArgs)
end




