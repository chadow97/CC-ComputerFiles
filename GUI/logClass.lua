local logger = require("UTIL.logger")
local ButtonClass = require("GUI.buttonClass")




local function DefaultOnButtonPress(toggleButton)

end



-- Define the LogClass class
local LogClass = {}
LogClass.__index = LogClass
setmetatable(LogClass, {__index = ButtonClass})

function LogClass.new(self, x, y, text)
  local instance = ButtonClass.new(self, x, y, text) 
  setmetatable(instance, self)
  self.__index = self


  -- Shouldnt override this unless you want to change toggle behavior
  -- to disable automatic untoggle, use disableAutomaticUntoggle
  instance.func = DefaultOnButtonPress

 



  return instance
end

function LogClass:addLine(lineToAdd)
    local lines = self:getTextLines()
    local _,_,_,numberOfWritableLines = self:getTextArea()


    local numberOfEmptyLines = math.max(numberOfWritableLines - #lines, 0)
    local numberOfLinesWithText = math.min(#lines, numberOfWritableLines)
    local textToDisplay = string.rep("\n", numberOfEmptyLines)
    local index = 1
    for _, line in pairs(lines) do
        if index > numberOfLinesWithText then
            break
        end
        textToDisplay = textToDisplay .. line .. "\n"
        index = index + 1
    end

    self:setText(textToDisplay)
    self:askForRedraw(self)


end

return LogClass