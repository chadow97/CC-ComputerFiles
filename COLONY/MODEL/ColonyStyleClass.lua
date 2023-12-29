local logger = require "UTIL.logger"
local StyleClass = require "MODEL.StyleClass"

---@class ColonyStyle:Style
local ColonyStyleClass = {}
ColonyStyleClass.__index = ColonyStyleClass
setmetatable(ColonyStyleClass, { __index = StyleClass })


function ColonyStyleClass:new(primary, secondary, tertiary)
    ---@class ColonyStyle:Style
    local o = setmetatable(StyleClass:new(), ColonyStyleClass)
    o.primary = primary
    o.secondary = secondary
    o.tertiary = tertiary

    return o
end

function ColonyStyleClass:updateStyle(primary, secondary, tertiary)
    self.primary = primary or self.primary
    self.secondary = secondary or self.secondary
    self.tertiary = tertiary or self.tertiary
end


---@param element Element
function ColonyStyleClass:apply(element)
    element:applyStyle(self) -- will call the correct function
end

---@param element Element
function ColonyStyleClass:applyStyleToElement(element)
    logger.logToFile(element)
    error("Must be implemented")
end


---@param button Button
function ColonyStyleClass:applyStyleToButton(button)
    button:setBackColor(self.secondary)
    button:setTextColor(self.tertiary)
end


---@param toggleButton ToggleableButton
function ColonyStyleClass:applyStyleToToggleButton(toggleButton)
    toggleButton:changeStyle(self.tertiary, self.secondary, self.secondary, self.tertiary)
end

---@param page Page
function ColonyStyleClass:applyStyleToPage(page)
    page:setBackColor(self.primary)
end


---@param label Label
function ColonyStyleClass:applyStyleToLabel(label)
    ColonyStyleClass.applyStyleToButton(self, label)
end

---@param table TableGUI
function ColonyStyleClass:applyStyleToTable(table)
    table:changeStyle(self.primary, self.secondary, self.tertiary)
end

return ColonyStyleClass