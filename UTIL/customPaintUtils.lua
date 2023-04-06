local CustomPaintUtils = {}

function CustomPaintUtils.drawFilledBox(startX, startY, endX, endY, color, terminal)
    
    local originalTerminal = term.current()
    if (terminal == nil or originalTerminal == terminal) then
        paintutils.drawFilledBox(startX, startY, endX, endY,  color)
        return
    end
    term.redirect(terminal)
    paintutils.drawFilledBox(startX, startY, endX, endY,  color)
    term.redirect(originalTerminal)
    


    

end

return CustomPaintUtils