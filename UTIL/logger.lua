local pretty = require "cc.pretty"
local CustomPrintUtils = require "UTIL.customPrintUtils"

local logger = {}

logger.LOGGING_LEVEL = {
    ALWAYS_DEBUG = 1, -- these are temporary but we always went to see them
    ALWAYS = 2,
    ERROR = 3,
    WARNING = 4,
    INFO = 5
    }
logger.terminal = nil
logger.lastLineWriten = nil
logger.directory = "output"
logger.fileName = nil
logger.isActive = nil
logger.curLoggingLevel = logger.LOGGING_LEVEL.WARNING


local function getFilePath()
    return logger.directory  ..  "/" .. logger.fileName
end


function logger.init(terminal, fileName, shouldDeleteFile, loggingLevel)
    logger.terminal = terminal
    logger.fileName = fileName or "logger.log"
    logger.isActive = true
    logger.setLoggingLevel(loggingLevel)

    if shouldDeleteFile then
        fs.delete(getFilePath())
    end
end

function logger.setLoggingLevel(loggingLevel)
    logger.curLoggingLevel = loggingLevel or logger.curLoggingLevel
end

function logger.deactiveate()
    logger.isActive = false
end

function logger.db(text)
    logger.log(text, logger.LOGGING_LEVEL.ALWAYS_DEBUG)
end

function logger.log(text, logLevel)
    if not logger.canLog(logLevel) then
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

function logger.logGenericTableToFile(object, maxDepth, logLevel)
    if not logger.canLog(logLevel) then
        return
    end
    if not logger.fileName then
        logger.fileName = "logger.log" 
     end
    local text = CustomPrintUtils.getAnythingString(object, maxDepth)
    local path = getFilePath()
    local file = fs.open(path, "a")
    file.write(text)
    file.close()
end

function logger.canLog(logLevel)
    if not logger.isActive then
        return false
    end

    if logLevel and logger.curLoggingLevel < logLevel then
        return false
    end

    return true
end

function logger.logToFile(objectToPrint, logLevel)

    if not logger.canLog(logLevel) then
        return
    end

    if not logger.fileName then
       logger.fileName = "logger.log" 
    end

    local text = tostring(objectToPrint)

    local path = getFilePath()
    local file = fs.open(path, "a")
    ---@diagnostic disable-next-line: param-type-mismatch
    local time = textutils.formatTime(os.time("local"))
    local logLevelString = logger.logLevelToString(logLevel)

    file.writeLine(pretty.render(pretty.group(pretty.text("[") .. pretty.pretty(time) .. pretty.text("-") .. pretty.text(logLevelString) .. pretty.text("]:").. pretty.pretty(text))))
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

function logger.logLevelToString(logLevel)
    if logLevel == logger.LOGGING_LEVEL.ALWAYS_DEBUG then
        return "ALWAYS_DEBUG"
    elseif logLevel == logger.LOGGING_LEVEL.INFO then
        return "INFO"
    elseif logLevel == logger.LOGGING_LEVEL.ERROR then
        return "ERROR"
    elseif logLevel == logger.LOGGING_LEVEL.WARNING then
        return "WARNING"
    else
        return "ALWAYS"
    end
end


return logger