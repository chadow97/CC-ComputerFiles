local function string_to_type(str)
    local tbl = load("return " .. str)
    if tbl then
      return tbl()
    else
      return str
    end
  end

  return {string_to_type = string_to_type}