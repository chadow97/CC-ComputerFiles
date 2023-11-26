local stringToTypeUtils = require("UTIL.stringToTypeUtils")
local CustomPrintUtils = {}
local maxTableRows = nil


local function getDepthPrefix(_depth)
    local prefix = ""
    for i= 0,_depth - 1 do
        prefix = prefix .. " " 
    end
    return prefix
end


local function getElementString(_element, _depthLeft, _currentDepth)
    if (_depthLeft ~= nil) then
        _depthLeft = _depthLeft - 1
    end

    if (_currentDepth == nil) then
        _currentDepth = 0
    else
        _currentDepth = _currentDepth + 1
    end
    local hasReachedEnd = (_depthLeft ~= nil) and (_depthLeft <= 0)

    local depthPrefix = getDepthPrefix(_currentDepth)

    local typ = type(_element)
    local result = ""
    if typ == "table" then
        if hasReachedEnd then
            result = "{table that is too deep}"
        else 
            -- GET STRING FOR TABLE
            result = result .."\n" .. depthPrefix .. "{\n"
            local index = 0
            for key, value in pairs(_element) do

                result = result .. depthPrefix .. (getElementString(key, _depthLeft, _currentDepth) .. ": " .. getElementString(value, _depthLeft, _currentDepth) .. "\n")
                index = index + 1
                if maxTableRows ~= nil and index >= maxTableRows then
                    break
                end
            end
            result = result .. depthPrefix .. "}\n"
            -- END OF STRING FOR TABLE
        end

    else
        result = result .. tostring(_element)
    end  
    return result
end



function CustomPrintUtils.printAnything(_anything)
    print(getElementString(_anything))
end

 function CustomPrintUtils.parseAndPrintAnything(_anythingString)
    CustomPrintUtils.printAnything(stringToTypeUtils.string_to_type(_anythingString))
end

function CustomPrintUtils.getAnythingString(_anything, _maxDepth)
    if not _maxDepth then
        _maxDepth = 3
    end
    return(getElementString(_anything, _maxDepth))
end



return CustomPrintUtils
