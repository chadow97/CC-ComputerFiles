local CustomPaintUtils = {}
local logger = require("UTIL.logger")

function CustomPaintUtils.drawFilledBox(startX, startY, endX, endY, color, terminal)
    logger.logOnError(startX)
    logger.logOnError(startY)
    logger.logOnError(endX)
    logger.logOnError(endY)
    logger.logOnError(color)
    logger.logOnError(terminal)

    if startX == nil then
        logger.logOnError(false)
    end
    
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