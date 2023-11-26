local logger = require("UTIL.logger")
local ButtonClass = require("GUI.ButtonClass")
local stringUtils = require('UTIL.stringUtils')

local DefaultToggledTextColor = colors.white
local DefaultToggledBackColor = colors.red

local DefaultUntoggleTime = 0.5


local function DefaultOnButtonPress(toggleButton)
    
    if toggleButton.canUntoggleManually or not toggleButton.toggled then
        toggleButton.document:startEdition()
        toggleButton:toggle(toggleButton.untoggleTime)
        toggleButton.OnManualToggle(toggleButton)
        toggleButton.document:endEdition()
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


ToggleableButtonClass.properties = { automatic_untoggle = "automatic_untoggle"}

function ToggleableButtonClass:new(...)
  local instance = setmetatable(ButtonClass.new(self, ...), ButtonClass)
  setmetatable(instance, self)

  instance.type = "toggleButtton"


  -- Shouldnt override this unless you want to change toggle behavior
  -- to disable automatic untoggle, use disableAutomaticUntoggle
  instance:setOnElementTouched(DefaultOnButtonPress)

  instance.OnManualToggle = DefaultOnManualToggle
  instance.OnAutoUntoggle = DefaultOnAutomaticUntoggle

  instance.toggled = false
  instance.toggledTimer = nil
  instance.untoggleTime = DefaultUntoggleTime

  -- By default, the untoggledStyle is determined from ButtonClass current colors
  instance.untoggledTextColor = instance.textColor
  instance.untoggledBackColor = instance.backColor

  instance.toggledTextColor = DefaultToggledTextColor
  instance.toggledBackColor = DefaultToggledBackColor

  -- By default, can not untoggle manually
  instance.canUntoggleManually = false

  return instance
end

function ToggleableButtonClass:__tostring()
    return stringUtils.Format("[ToggleButton %(id), Text: %(text), Position:%(position), Size:%(size), isToggled:%(istoggled) ]",
                                {
                                id = self.id, 
                                text = stringUtils.Truncate(tostring(self.text), 20), 
                                position = (stringUtils.CoordToString(self.x, self.y)),
                                size = (stringUtils.CoordToString(self:getSize())),
                                istoggled = tostring(self.toggled)
                                })
end

function ToggleableButtonClass:setProperties(properties)
    for propertyKey, propertyValue in pairs(properties) do
        if propertyKey == ToggleableButtonClass.properties.automatic_untoggle and 
           not propertyValue then
            self:disableAutomaticUntoggle()
        end
    end

    ButtonClass.setProperties(self, properties)
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
    self:setElementDirty()

end

function ToggleableButtonClass:onTimerEnd()
    self.document:startEdition()
    self.toggledTimer = nil
    self:toggle()
    self.OnAutoUntoggle(self)
    self.document:endEdition()
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
    self:setElementDirty()

end

function ToggleableButtonClass:toggle(timeUntilUndo)
    self.document:startEdition()
    self.toggled = not self.toggled
    self:updateStyle()

    -- Cancel running timers if we manually toggled button
    if self.toggledTimer ~= nil then
        ---@diagnostic disable-next-line: undefined-field
        os.cancelTimer(self.toggledTimer)
    end
    
    -- Start a timer to toggle back
    if timeUntilUndo ~= nil then
        ---@diagnostic disable-next-line: undefined-field
        self.toggledTimer = os.startTimer(timeUntilUndo)
    end 
    self.document:registerCurrentAreaAsDirty(self)
    self.document:endEdition()   
end

function ToggleableButtonClass:forceToggle( isToggled)
    if self.toggled ~= isToggled then
        self.toggled = isToggled
        self:updateStyle()
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

function ToggleableButtonClass:onResumeAfterContextLost()

    -- force timerEnd as we probably have missed it...

    if (self.toggledTimer) then
        self:onTimerEnd()
    end
    
    ButtonClass.onResumeAfterContextLost(self)
end

function ToggleableButtonClass:pressButton()
    self.OnManualToggle(self)
end

return ToggleableButtonClass