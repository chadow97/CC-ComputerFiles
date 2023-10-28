local logger = require("UTIL.logger")
local ButtonClass = require("GUI.buttonClass")

-- Define the LabelClass class
local LabelClass = {}
LabelClass.__index = LabelClass
setmetatable(LabelClass, {__index = ButtonClass})

function LabelClass.new(self, x, y, text)
  local instance = ButtonClass.new(self, x, y, text) 
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function LabelClass:setOnElementTouched(...)
    logger.log("Called set on Element touched on label element!!")
end

function LabelClass:handleTouchEvent(eventName, side, xPos, yPos)   
    return false
end

return LabelClass