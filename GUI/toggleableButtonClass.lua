local logger = require("UTIL.logger")
local ButtonClass = require("GUI.buttonClass")

local DefaultToggledTextColor = colors.white
local DefaultToggledBackColor = colors.red

local DefaultUntoggleTime = 0.5


local function DefaultOnButtonPress(toggleButton)

    if toggleButton.canUntoggleManually or not toggleButton.toggled then
        toggleButton:toggle(toggleButton.untoggleTime)
        toggleButton.OnManualToggle(toggleButton)
        toggleButton:askForRedraw()
    end
end

local function DefaultOnAutomaticUntoggle(toggleButton)
    -- do nothing by default
end

local function DefaultOnManualToggle (toggleButton)
    -- do nothing by default
end

-- Define the ToggleableButtonClass class
local ToggleableButtonClass = {}
ToggleableButtonClass.__index = ToggleableButtonClass
setmetatable(ToggleableButtonClass, {__index = ButtonClass})

function ToggleableButtonClass.new(self, x, y, text)
  local instance = ButtonClass.new(self, x, y, text) 
  setmetatable(instance, self)
  self.__index = self


  -- Shouldnt override this unless you want to change toggle behavior
  -- to disable automatic untoggle, use disableAutomaticUntoggle
  instance.func = DefaultOnButtonPress

  instance.OnManualToggle = DefaultOnManualToggle
  instance.OnAutoUntoggle = DefaultOnAutomaticUntoggle

  instance.toggled = false
  instance.toggledTimer = nil
  instance.untoggleTime = DefaultUntoggleTime

  -- By default, the untoggledStyle is determined from buttonClass current colors
  instance.untoggledTextColor = instance.textColor
  instance.untoggledBackColor = instance.backColor

  instance.toggledTextColor = DefaultToggledTextColor
  instance.toggledBackColor = DefaultToggledBackColor

  -- By default, can not untoggle manually
  instance.canUntoggleManually = false



  return instance
end

function ToggleableButtonClass:setOnManualToggle( newFunc )
    -- nil sets back to default
    self.OnManualToggle = newFunc or DefaultOnManualToggle
end

function ToggleableButtonClass:disableAutomaticUntoggle()
    self.untoggleTime = nil
    self.canUntoggleManually = true
end

function ToggleableButtonClass:updateStyle()
    if self.toggled then
        self.textColor = self.toggledTextColor
        self.backColor = self.toggledBackColor
    else
        self.textColor = self.untoggledTextColor
        self.backColor = self.untoggledBackColor
    end

end

function ToggleableButtonClass:onTimerEnd()

    self.toggledTimer = nil
    self:toggle()
    self.OnAutoUntoggle(self)
    self:askForRedraw()
end

function ToggleableButtonClass:isPressed()
    return self.toggled
end



function ToggleableButtonClass:changeStyle(untoggledTextColor, untoggledBackColor, toggledTextColor, toggledBackColor)

    self.toggledTextColor = toggledTextColor or self.toggledTextColor
    self.toggledBackColor = toggledBackColor or self.toggledBackColor
    self.untoggledTextColor = untoggledTextColor or self.untoggledTextColor
    self.untoggledBackColor = untoggledBackColor or self.untoggledBackColor

    self:updateStyle()

end

function ToggleableButtonClass:toggle(timeUntilUndo)

    self.toggled = not self.toggled
    self:updateStyle()

    -- Cancel running timers if we manually toggled button
    if self.toggledTimer ~= nil then
        ---@diagnostic disable-next-line: undefined-field
        os.cancelTimer(self.toggledTimer)
    end
    
    -- Stat a timer to toggle back
    if timeUntilUndo ~= nil then
        ---@diagnostic disable-next-line: undefined-field
        self.toggledTimer = os.startTimer(timeUntilUndo)
    end    
end


function ToggleableButtonClass:handleEvent(eventName, ...)
    if (eventName == "timer") then
        return self:handleTimerEvent(eventName, ...)
    end

    -- Check if parent can handle event if we didnt handle
    if ButtonClass.handleEvent(self, eventName, ...) then 
        return true
    end

    return false
end

function ToggleableButtonClass:handleTimerEvent(eventName, timerID)
    if self.toggledTimer == timerID then
        self:onTimerEnd()
        return true
    end
    return false
end

function ToggleableButtonClass.onResumeAfterContextLost(self)

    -- force timerEnd as we probably have missed it...

    if (self.toggledTimer) then
        self:onTimerEnd()
    end
    
    ButtonClass.onResumeAfterContextLost(self)
end

function ToggleableButtonClass:executeMainAction()
    self.OnManualToggle(self)
end




return ToggleableButtonClass