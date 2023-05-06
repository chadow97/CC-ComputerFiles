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

-- Return the stringUtils module
return stringUtils
