local logger = require("UTIL.logger")
local ButtonClass = require("GUI.ButtonClass")
local stringUtils = require("UTIL.stringUtils")




local function DefaultOnButtonPress(toggleButton)

end



-- Define the LogClass class
local LogClass = {}
LogClass.__index = LogClass
setmetatable(LogClass, {__index = ButtonClass})

---@class Log: Button
function LogClass:new(x, y, text, document)
  ---@class Log: Button
  local instance = ButtonClass.new(self, x, y, text, document) 
  setmetatable(instance, self)
  self.__index = self
  self.type = "label"


  -- Shouldnt override this unless you want to change toggle behavior
  -- to disable automatic untoggle, use disableAutomaticUntoggle
  instance.onButtonPressedCallback = DefaultOnButtonPress

 
  instance.completeLogContent = {}
  if text then
    table.insert(instance.completeLogContent, text)
  end


  return instance
end

function LogClass:__tostring() 
  return stringUtils.Format("[Log %(id), Text: %(text), Position:%(position), Size:%(size) ]",
                            {id = self.id, 
                            text = stringUtils.Truncate(tostring(self.text), 20), 
                            position = (stringUtils.CoordToString(self.x, self.y)),
                            size = (stringUtils.CoordToString(self:getSize()))})
end

function LogClass:addLine(lineToAdd)
    -- Insert the new line to the complete log content
    table.insert(self.completeLogContent, lineToAdd)

    -- Get the number of writable lines from the text area
    local _, _, _, numberOfWritableLines = self:getTextArea()

    -- Calculate necessary values for text display
    local totalLines = #self.completeLogContent
    local numberOfEmptyLines = math.max(0, numberOfWritableLines - totalLines)
    local numberOfLinesWithText = math.min(totalLines, numberOfWritableLines)
    local numberOfLogLinesToSkip = math.max(0, totalLines - numberOfWritableLines)

    -- Create a table to hold the lines of text to be displayed
    local linesToDisplay = {}

    -- Append log lines to linesToDisplay table
    for i = 1, numberOfLinesWithText do
        table.insert(linesToDisplay, self.completeLogContent[numberOfLogLinesToSkip + i])
    end

    -- Set the text and request a redraw, merging concatenation and empty line appending in one step
    self:setText(table.concat(linesToDisplay, "\n") .. string.rep("\n", numberOfEmptyLines))
    self:setParentDirty()
end

return LogClass