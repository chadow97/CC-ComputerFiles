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
  instance.onButtonPressedCallback = DefaultOnButtonPress

 
  instance.completeLogContent = {}
  if text then
    table.insert(instance.completeLogContent, text)
  end


  return instance
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
    self:askForRedraw(self)
end

return LogClass