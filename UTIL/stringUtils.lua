-- Define the stringUtils module
local stringUtils = {}

-- Define the splitLines function
function stringUtils.splitLines(str)
  if (type(str) ~= "string") then
    return {str}
  end
  local lines = {}
  local pos = 1
  while true do
    local line, nextPos = str:match('([^\n]*)\n()', pos)
    if not line then break end
    lines[#lines+1] = line
    pos = nextPos
  end
  if pos <= #str then
    lines[#lines+1] = str:sub(pos)
  end
  return lines
end

function stringUtils.CoordToString(x,y)
  local xString = x or "null"
  local yString = y or "null"

  return "(" .. xString .."," .. yString ..")"
end

--- Formats a string with named placeholders and %s for unnamed sequential placeholders.
-- This function allows you to format a string using a table of named placeholders
-- (e.g., %(name)), %s for unnamed sequential placeholders, and specific unnamed 
-- positional placeholders (e.g., %1, %2). The first argument is the format string, 
-- the second argument (optional) is a table for named placeholders, and the subsequent 
-- arguments are for unnamed placeholders.
-- @param str string: The format string.
-- @param tbl table (optional): A table containing key-value pairs for named placeholders.
-- @vararg: Additional arguments for unnamed positional placeholders.
-- @return string: The formatted string.
-- @usage stringUtils.Format("Name: %(name), Age: %s, Favorite Number: %1, Color: %s", {name = "Alice"}, 30, "Blue")
function stringUtils.Format(str, ...)
    assert(type(str) == "string", "First argument (format string) must be a string.")
  
    local args = {...}
    local tbl = table.remove(args, 1)
    if tbl and type(tbl) ~= "table" then
        error("Second argument, if provided, must be a table.")
    end
    local unnamedIndex = 1  -- Index to track the position of unnamed arguments

    local function replacePlaceholder(placeholder)
        if placeholder == "%s" then
            local value = args[unnamedIndex + 1]
            unnamedIndex = unnamedIndex + 1
            if value == nil then
                error("Unnamed parameter for %s at position " .. unnamedIndex - 1 .. " is nil or missing.")
            end
            return tostring(value)
        else
            local key = placeholder:match("%((.-)%)")
            if key then
                if tbl and tbl[key] == nil then
                    print(key)
                    error("Key not found in table: " .. key)
                end
                return tbl[key] or placeholder
            else
                local index = placeholder:match("%%(%d+)")
                if index then
                    index = tonumber(index)
                    if index and args[index] then
                        return tostring(args[index])
                    else
                        error("Index out of range or nil: " .. tostring(index))
                    end
                end
            end
        end
        return placeholder
    end

    -- Escape sequence for %%
    str = str:gsub("%%%%", "\0")
    -- Replace placeholders
    str = str:gsub("%%%b()", replacePlaceholder)
    str = str:gsub("%%s", replacePlaceholder)
    str = str:gsub("%%(%d+)", replacePlaceholder)

    -- Revert escaped %%
    str = str:gsub("\0", "%%")

    return str
end

-- The stringUtils library now has a more versatile Format function.

--- Formats a string with both %s for sequential unnamed placeholders and specific placeholders like %1, %2.
-- This function allows you to format a string using %s for sequential unnamed placeholders,
-- and specific unnamed positional placeholders (e.g., %1, %2). It internally calls the Format function.
-- @param str string: The format string.
-- @vararg: Additional arguments for unnamed positional placeholders.
-- @return string: The formatted string.
-- @usage stringUtils.UFormat("Name: %s, Age: %s, Favorite Number: %1", "Alice", 30)
function stringUtils.UFormat(str, ...)
  assert(type(str) == "string", "First argument (format string) must be a string.")
  
  -- Directly call the Format function with no table for named placeholders
  return stringUtils.Format(str, nil, ...)
end

function stringUtils.Truncate(str, maxLength)
  -- Type checks
  assert(type(str) == "string", "First parameter 'str' must be a string")
  assert(type(maxLength) == "number" and maxLength > 0 and maxLength == math.floor(maxLength), "Second parameter 'maxLength' must be a positive integer")

  if #str > maxLength then
      return str:sub(1, maxLength - 3) .. "..."
  else
      return str
  end
end

function stringUtils.CenterLinesInRectangle(lines, width, height)
    local centeredLines = {}

    -- Function to center a single line
    local function centerLine(line)
        local padding = width - #line
        local leftPadding = math.floor(padding / 2)
        local rightPadding = padding - leftPadding
        return string.rep(" ", leftPadding) .. line .. string.rep(" ", rightPadding)
    end

    -- Center each line horizontally
    for _, line in ipairs(lines) do
        table.insert(centeredLines, centerLine(line))
    end

    -- Center vertically
    local totalLines = #centeredLines
    local topPadding = math.floor((height - totalLines) / 2)
    local bottomPadding = height - totalLines - topPadding

    for i = 1, topPadding do
        table.insert(centeredLines, 1, string.rep(" ", width))  -- Add spaces at the beginning
    end

    for i = 1, bottomPadding do
        table.insert(centeredLines, string.rep(" ", width))  -- Add spaces at the end
    end

    return centeredLines
end

function stringUtils.CenterTextInRectangle(text, width, height)
    return stringUtils.CenterLinesInRectangle(stringUtils.splitLines(text), width, height)
end

-- Return the stringUtils module
return stringUtils
