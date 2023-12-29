-- Set the random seed to the current time
math.randomseed(os.time())

--- Define the generateId function
---@param length? number
---@return string
local function generateId(length)
  length = length or 6  -- Set default length to 6 if not provided
  local id = ""
  for i = 1, length do
    id = id .. tostring(math.random(0, 9))
  end
  return id
end

-- Export the generateId function to be used by other programs
return {
  generateId = generateId
}