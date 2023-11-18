local monitor = peripheral.find("monitor")
local defaultMargin = 1

local function makeButton(_text, _xpos, _ypos, _margin, _color, _functionToCall)
    if (_color == nil) then
        _color = colors.lightGray
    end

    if (_margin == nil) then
        _margin = defaultMargin
    end

    local ySize = 1 
    local xSize = #_text

    paintutils.drawFilledBox(_xpos - _margin, _ypos - _margin, _xpos+xSize + _margin -1, _ypos+ySize - 1 + _margin ,  _color)
    monitor.setCursorPos(_xpos, _ypos)
    monitor.write(_text)
end

monitor.setTextScale(0.5)
monitor.setBackgroundColor(colors.black)
monitor.clear()

while true do
    ---@diagnostic disable-next-line: undefined-field
    local event, side, xPos, yPos = os.pullEvent("monitor_touch")
    local output = event .. " on " .. side .. " at " .. xPos .. "," .. yPos
    term.write(output)
end







makeButton("Click me", 2, 2)

