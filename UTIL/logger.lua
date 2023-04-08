local pretty = require "cc.pretty"


local logger = {
    terminal = nil,
    lastLineWriten = nil,
    directory = "output",
    fileName = nil,
    isActive = nil
}

local function getFilePath()
    return logger.directory  ..  "/" .. logger.fileName
end


function logger.init(terminal, fileName, shouldDeleteFile)
    logger.terminal = terminal
    logger.fileName = fileName or "logger.log"
    logger.isActive = true

    if shouldDeleteFile then
        fs.delete(getFilePath())
    end
end

function logger.deactiveate()
    logger.isActive = false
end

function logger.log(text)
    if not logger.isActive then
        return
    end


    if logger.terminal ~= nil then
        local originalTerminal = term.current()
        if (logger.terminal == nil or originalTerminal == logger.terminal) then
            pretty.pretty_print(text)
            return
        end
        term.redirect(logger.terminal)
        pretty.pretty_print(text)
        term.redirect(originalTerminal)

    end
end

function logger.logToFile(text)

    if not logger.isActive then
        return
    end

    if not logger.fileName then
       logger.fileName = "logger.log" 
    end

    local path = getFilePath()
    

    local file = fs.open(path, "a")
    ---@diagnostic disable-next-line: param-type-mismatch
    local time = textutils.formatTime(os.time("local"))

    file.writeLine(pretty.render(pretty.group(pretty.text("[") .. pretty.pretty(time) .. pretty.text("]:").. pretty.pretty(text))))
    file.close()

end

function logger.callStackToFile()

    if not logger.isActive then
        return
    end

    if not logger.fileName then
        logger.fileName = "logger.log" 
    end

    local path = getFilePath()

    local file = fs.open(path, "a")
    file.writeLine("----------------------------------------------------------")

    local level = 2 -- start at level 2 to skip the printCallStack function itself
    while true do
        local info = debug.getinfo(level, "nSl")
        if not info then break end
        
        file.writeLine(string.format("%s:%d in function '%s'", info.short_src, info.currentline, info.name or "?"))
        level = level + 1
    end

    file.close()

end


return logger