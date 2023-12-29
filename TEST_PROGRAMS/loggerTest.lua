-- add absolute paths to package to allow programs to use libraries from anywhere!
package.path = package.path .. ";/?;/?.lua"

local ButtonClass = require "GUI.ButtonClass"
local DocumentClass = require("MODEL.DocumentClass")

local logger = require("UTIL.logger")



logger.log("this shouldnt print because logger is not initialized", logger.LOGGING_LEVEL.ALWAYS_DEBUG)

logger.init(term.current(), "loggerTest.log", true,logger.LOGGING_LEVEL.WARNING, logger.OUTPUT.FILE)

-- make sure override works
local testTableA = {"test1", "test2"}
logger.log(testTableA)

-- check table loops
local loopTableA ={"loopTableA"}
local loopTableB = {"loopTableB", loopTableA}
local loopTableC = {"loopTableC", loopTableB}
table.insert(loopTableA, loopTableC)
logger.log(loopTableC)

--check logging levels
logger.log("this shouldnt print because of loglevel!", logger.LOGGING_LEVEL.INFO)

-- check custom prints
local customPrintTable = {"this should not be displayed!"}
customPrintTable.__tostring =function (string)
    return "this is a custom print"
end
setmetatable(customPrintTable,customPrintTable)
logger.log(customPrintTable)

--check obs
local document = DocumentClass:new()
local button = ButtonClass:new(1,1, "text", document)

logger.log(button)

--check db
logger.db("printing debug string! (should be in file!)")


--check call stack
local function secondFunction()
    logger.logOnError(false, "There was an error...")
    logger.logOnError(true, "This shouldnt print!")
    logger.logOnError(nil, "printing error nil!")
end
local function firstFunction ()
    secondFunction()
end

firstFunction()

--checking nil print
logger.log(nil)

--check terminal print
logger.init(term.current(), "loggerTest.log", false ,logger.LOGGING_LEVEL.WARNING, logger.OUTPUT.TERMINAL)
logger.log("This should print in the terminal!")
