local logger = require "UTIL.logger"

---@class Style
local StyleClass = {}
StyleClass.__index = StyleClass

function StyleClass:new()
    local o = setmetatable({}, StyleClass)
    self.innerElementColor = colors.orange
    self.backgroundColor = colors.gray
    self.textColor = colors.black
    return o
end


---@param element Element
function StyleClass:apply(element)
    element:applyStyle(self) -- will call the correct function
end

---@param element Element
function StyleClass:applyStyleToElement(element)
    
end

---comment
---@param button Button
function StyleClass:applyStyleToButton(button)
    button:changeStyle(self.innerElementColor, self.textColor)
end

---@param page Page
function StyleClass:applyStyleToPage(page)
    page:setBackColor(self.backgroundColor)
end


---@param label Label
function StyleClass:applyStyleToLabel(label)
    label:changeStyle(self.innerElementColor, self.textColor)
end

---@param toggleButton ToggleableButton
function StyleClass:applyStyleToToggleButton(toggleButton)
    toggleButton:changeStyle(self.backgroundColor, self.textColor, self.textColor, self.innerElementColor)
end

---@param table TableGUI
function StyleClass:applyStyleToTable(table)
    table:changeStyle(self.backgroundColor, self.innerElementColor, self.textColor)
end

return StyleClass