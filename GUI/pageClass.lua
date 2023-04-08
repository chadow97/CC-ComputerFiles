local monUtils = require("UTIL.monUtils")
local logger = require("UTIL.logger")


-- Define the PageClass constructor function
local PageClass = {}
PageClass.__index = PageClass

function PageClass.new(monitor)
    local self = setmetatable({}, PageClass)
    self.buttons = {}
    self.monitor = monitor

    -- By default, area is entire monitor
    self.startX = 1
    self.startY = 1
    self.endX, self.endY = self.monitor.getSize()
    self.eraseOnDraw = true
    return self
end

-- Define the add() method to add button objects to the page
function PageClass:add(button)
    button:setMonitor(self.monitor)
    button:setPage(self)
    table.insert(self.buttons, button)
end

function PageClass:addButtons(buttonList)
    for _, button in ipairs(buttonList) do
        
        self:add(button)
    end
end

-- Define the getButtonCount() method to get the total number of buttons on the page
function PageClass:getButtonCount()
    return #self.buttons
end

-- Define the getButtons() method to get all the buttons on the page
function PageClass:getButtons()
    return self.buttons
end

-- Define the draw method to draw the page
function PageClass:draw()
    if self.eraseOnDraw then
        monUtils.resetMonitor(self.monitor)
    end
    for _, button in ipairs(self.buttons) do
        button:draw()
    end
end

function PageClass:askForRedraw()
    -- if page has no parent, then we can draw, else we ask its parents to handle drawing.
    if self.page then
        self.page:askForRedraw(self) -- passing asker
    else
        self:draw()
    end


end

function PageClass:getArea()
   
    local sizeX,sizeY = self:getSize()
    return self.startX, self.startY, self.endX, self.endY, sizeX, sizeY
end

function PageClass:getSize()
    local sizeX  = self.endX - self.startX
    local sizeY  = self.endY - self.startY
    return sizeX, sizeY
end

function PageClass:setPosition(posX,posY)
    self.posX = posX
    self.posY = posY
end

function PageClass:setSize(sizeX,sizeY)
    self.sizeX = sizeX
    self.sizeY = sizeY
end


-- Define the handleEvent method to handle events on the page
function PageClass:handleEvent(...)
    for i = #self.buttons, 1, -1 do
        local button = self.buttons[i]
        if button:handleEvent(...) then
            return true
        end
    end
    return false
end

function PageClass:disableErase()
    self.eraseOnDraw = false
end

return PageClass