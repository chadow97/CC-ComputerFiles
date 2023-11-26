local logger = require "UTIL.logger"
TableFileHandlerClass = {}
TableFileHandlerClass.__index = TableFileHandlerClass

-- Serialization of table
local function serialize(tbl)

    local serialized = "{"
    for k, v in pairs(tbl) do
        serialized = serialized .. "[" .. string.format("%q", k) .. "]=" 
        if type(v) == "table" then
            serialized = serialized .. serialize(v)
        else
            serialized = serialized .. string.format("%q", v)
        end
        serialized = serialized .. ","
    end
    return serialized .. "}"
end

-- Deserialization of table
local function deserialize(str)
    local tbl = load("return " .. str)()
    return tbl
end

-- Constructor with file and directory creation
function TableFileHandlerClass:new(filename)
    local path = string.match(filename, "(.+)/[^/]*$")
    if path and not fs.exists(path) then
        fs.makeDir(path)
    end

    if not fs.exists(filename) then
        local file = fs.open(filename, "w")
        file.write(serialize({}))
        file.close()
    end

    local obj = {filename = filename}
    setmetatable(obj, TableFileHandlerClass)
    return obj
end

-- Writing table to file
function TableFileHandlerClass:write(table)
    local file = fs.open(self.filename, "w")
    if file then
        file.write(serialize(table))
        file.close()
    else
        error("Could not open file for writing.")
    end
end

-- Reading table from file
function TableFileHandlerClass:read()
    if not fs.exists(self.filename) then
        error("File not found: " .. self.filename)
    end

    local file = fs.open(self.filename, "r")
    local content = file.readAll()
    file.close()

    local status, result = pcall(deserialize, content)
    if status and type(result) == "table" then
        return result
    else
        -- Replace this with your logging mechanism
        print("Deserialization failed for file: " .. self.filename)
        return {}  -- Return an empty table if deserialization fails or result is not a table
    end
end

return TableFileHandlerClass