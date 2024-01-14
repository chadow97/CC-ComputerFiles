local pretty = require "cc.pretty"
local CustomPrintUtils = require "UTIL.customPrintUtils"
local stringUtils      = require "UTIL.stringUtils"

local logger = {}

logger.LOGGING_LEVEL = {
    ALWAYS_DEBUG = 1, -- these are temporary but we always went to see them
    ALWAYS = 2,
    ERROR = 3,
    WARNING = 4,
    INFO = 5
    }
logger.OUTPUT = {
    FILE = 1,
    TERMINAL = 2
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


function logger.init(terminal, fileName, shouldDeleteFile, loggingLevel, output)
    logger.terminal = terminal
    logger.fileName = fileName or "logger.log"
    logger.isActive = true
    logger.output = output or logger.OUTPUT.TERMINAL
    logger.setLoggingLevel(loggingLevel)
    logger.tableDefaultToStringFunction = logger.__tostring

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

function logger.logToTerminal(text, logLevel)
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

function logger.log(object, logLevel, title)
    if not logger.canLog(logLevel) then
        return
    end

    print(logger.output)
    if logger.output == logger.OUTPUT.FILE then
        logger.logToFile(object,logLevel, title)
    end
    if logger.output == logger.OUTPUT.TERMINAL then
        logger.logToTerminal(object ,logLevel)
    end
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

local function callStackObjectToString(callStackObject)
    local resultString = ""
    for _, callStackLine in ipairs(callStackObject.lines) do
        resultString = resultString .. callStackLine .. "\n"    
    end
    return resultString

end

function logger.cs(...)
    logger.logOnError(...)
end

function logger.logOnError(isValid, errorMessage)
    if isValid then
        return
    end
    errorMessage = errorMessage or "Unknown Error"
    if not logger.canLog(logger.LOGGING_LEVEL.ALWAYS_DEBUG) then
        return
    end
    local callStack = logger.getCallStack()
    local callStackObject = {lines = callStack, errorMessage = errorMessage,type ="callstack"}
    callStackObject.__tostring = callStackObjectToString
    setmetatable(callStackObject,callStackObject)
    logger.log(callStackObject, 
               logger.LOGGING_LEVEL.ALWAYS_DEBUG, 
               string.format("CALLSTACK FROM ERROR: %s", callStackObject.errorMessage))
end

local function isObToPrintCallStack(object)
    return type(object) == "table" and object.type == "callstack" 
end

function logger.logToFile(objectToPrint, logLevel, title)

    if not logger.canLog(logLevel) then
        return
    end

    if not logger.fileName then
       logger.fileName = "logger.log" 
    end

    if not title then
        title = ""
    end

    local path = getFilePath()
    local file = fs.open(path, "a")
    ---@diagnostic disable-next-line: param-type-mismatch
    local time = textutils.formatTime(os.time("local"), true)
    local logLevelString = logger.logLevelToString(logLevel)
    if not file then
        return
    end
    local objectString = pretty.render(pretty.pretty(objectToPrint), 100)
    local logString = string.format("[%s-%s]:", time, logLevelString)
    if #stringUtils.splitLines(objectString) > 1 or title ~= "" then
        logString = logString .. title .. "\n"
    end
    logString = logString .. objectString .. "\n"
    file.write(logString)
    file.close()

end

function logger.getCallStack()
    local callStack= {}
    local level = 2 -- start at level 2 to skip the printCallStack function itself
    while true do
        local info = debug.getinfo(level, "nSl")
        if not info then break end
        
        table.insert(callStack,string.format("%s:%d in function '%s'", info.short_src, info.currentline, info.name or "?"))
        level = level + 1
    end
    return callStack
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