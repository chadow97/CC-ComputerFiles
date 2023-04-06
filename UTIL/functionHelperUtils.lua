local customPrintUtils = require("customPrintUtils")
local FunctionHelperUtils = {}


local function  file_exists(file)
    local f = io.open(file, "r")
    if f then
        f:close()
        return true
    else
        return false
    end
end


function FunctionHelperUtils.printLine()
    print("------------------------------")
end

 function FunctionHelperUtils.printTitle(_isCalling, _libName, _libFunction)
    if _isCalling then
        print ("Calling " .. _libName .. "." .. _libFunction)
    else 
        print("Functions of " .. _libName)

    end
end

function FunctionHelperUtils.printFunctions(_lib, _shouldFunctionsBeNumbered)
    local index = 1
    for funcName, funcPtr in pairs(_lib) do
            local prefix = "--"
            if _shouldFunctionsBeNumbered then
                prefix = index .. "-"
            end

            print(prefix .. funcName)
            index = index + 1
    
    end
end

function FunctionHelperUtils.getFunctions(_lib)
    local functions = {}
    for funcName, _ in pairs(_lib) do
        table.insert(functions, #functions + 1, funcName)
    end
    return functions
end


local function throwableWrite(_file, _printable)
    _file.writeLine(_printable)
end



function FunctionHelperUtils.callFunction(_lib, _libFunction, _functionArgs, _sendToFile, _fileName)

    local directory = "output/"
    if not fs.isDir(directory) then
        fs.makeDir(directory)
    end
    
    local output =_lib[_libFunction](table.unpack(_functionArgs))
    if (output ~= nil) then 
        if (not _sendToFile) then
            print("Output:")
            customPrintUtils.printAnything(output)
        else
            
            local path = directory.._fileName
            if (file_exists(path)) then
                print("Could not print as the file already exist in " .. path)
            else
                -- file doesnt exist in output dir
                local file = fs.open(path, "w")
                print("Printing to " .. path .. "...")
                local printable = customPrintUtils.getAnythingString(output)


                local status, err = pcall(throwableWrite, file, printable)
                if (not status) then
                    print( "Error writing to file: " .. err)
                end

                file.close()
            end

            
            
        end
    end
  
end

return FunctionHelperUtils