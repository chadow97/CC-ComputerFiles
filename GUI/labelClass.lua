local logger = require("UTIL.logger")
local ButtonClass = require("GUI.ButtonClass")
local stringUtils = require("UTIL.stringUtils")

-- Define the LabelClass class
local LabelClass = {}
LabelClass.__index = LabelClass
setmetatable(LabelClass, {__index = ButtonClass})

function LabelClass.new(self, x, y, text, document)
  local instance = ButtonClass.new(self, x, y, text, document) 
  setmetatable(instance, self)
  self.__index = self
  self.type = "label"

  return instance
end

function LabelClass:__tostring() 
  return stringUtils.Format("[Label %(id), Text: %(text), Position:%(position), Size:%(size) ]",
                            {id = self.id, 
                            text = stringUtils.Truncate(tostring(self.text), 20), 
                            position = (stringUtils.CoordToString(self.x, self.y)),
                            size = (stringUtils.CoordToString(self:getSize()))})
 
end

function LabelClass:setOnElementTouched(...)
    logger.log("Called set on Element touched on label element!!")
end

function LabelClass:handleTouchEvent(eventName, side, xPos, yPos)   
    return false
end

return LabelClass