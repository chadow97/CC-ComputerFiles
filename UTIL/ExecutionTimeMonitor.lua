local logger = require "UTIL.logger"
---@class ExecutionTimeMonitor
local ExecutionTimeMonitor = {
    startTimesBySectionByFunctionMap = {},  -- Table to store start times for functions
    performanceDataBySection = {}, -- Table to store performance information by section
    sectionCounter = {},           -- Counter to track sections with the same name
    initialized = false,           -- Flag to track initialization status
    outputFile = nil,              -- File handle for output file
    loggingEnabled = false,        -- Flag to indicate if logging is enabled by default
    currentSection = "MainSection", -- By defualt, we are in the main section!
    currentSectionStartTime = nil
}

function ExecutionTimeMonitor.initialize(outputFileName)
    if not ExecutionTimeMonitor.initialized then
        -- Open the file for writing
        ExecutionTimeMonitor.outputFile = io.open(outputFileName, "w")
        if not ExecutionTimeMonitor.outputFile then
            print("Error: Failed to open the specified output file.")
            return
        end

        ExecutionTimeMonitor.setupHook()

        ExecutionTimeMonitor.initialized = true
        ExecutionTimeMonitor.currentSectionStartTime = ExecutionTimeMonitor.getTimeSince()
    else
        print("Error: ExecutionTimeMonitor is already initialized.")
    end
end

function ExecutionTimeMonitor.setupHook()
    if ExecutionTimeMonitor.loggingEnabled then
        debug.sethook(function(event)
            local info = debug.getinfo(2, "n")  -- Get function name
            if info and info.name then
                if event == "call" then
                    ExecutionTimeMonitor.startTimer(info.name)
                elseif event == "return" then
                    ExecutionTimeMonitor.stopTimer(info.name)
                end
            end
        end, "cr")
    else
        debug.sethook()  -- Clear the hook to disable logging
    end
end

function ExecutionTimeMonitor.startLogging()
    ExecutionTimeMonitor.loggingEnabled = true
    ExecutionTimeMonitor.setupHook()
end

function ExecutionTimeMonitor.stopLogging()
    ExecutionTimeMonitor.loggingEnabled = false
    ExecutionTimeMonitor.setupHook()
end

function ExecutionTimeMonitor.startSection(sectionName)
    if sectionName == nil then
        error("cannot start main section")
    end
    local sectionKey = sectionName
    ExecutionTimeMonitor.sectionCounter[sectionKey] = (ExecutionTimeMonitor.sectionCounter[sectionKey] or 0) + 1
    ExecutionTimeMonitor.currentSection = sectionKey .. "_" .. ExecutionTimeMonitor.sectionCounter[sectionKey]
    ExecutionTimeMonitor.currentSectionStartTime = ExecutionTimeMonitor.getCurrentTime()
end

function ExecutionTimeMonitor.endSection()
    if ExecutionTimeMonitor.currentSection == "MainSection" then
        print("Error: Cannot end the MainSection.")
        return
    end
    ExecutionTimeMonitor.currentSection = "MainSection"
end

function ExecutionTimeMonitor.startTimer(funcName)
    if ExecutionTimeMonitor.initialized then
        local sectionKey = ExecutionTimeMonitor.currentSection
        if not ExecutionTimeMonitor.startTimesBySectionByFunctionMap[sectionKey] then
            ExecutionTimeMonitor.startTimesBySectionByFunctionMap[sectionKey] = {}
        end
        if not ExecutionTimeMonitor.startTimesBySectionByFunctionMap[sectionKey][funcName] then
            ExecutionTimeMonitor.startTimesBySectionByFunctionMap[sectionKey][funcName] = {}
        end
        table.insert(ExecutionTimeMonitor.startTimesBySectionByFunctionMap[sectionKey][funcName], ExecutionTimeMonitor.getCurrentTime())
    else
        print("Error: ExecutionTimeMonitor is not initialized.")
    end
end

function ExecutionTimeMonitor.stopTimer(funcName)
    if ExecutionTimeMonitor.initialized then
        local sectionKey = ExecutionTimeMonitor.currentSection
        local startTimes = ExecutionTimeMonitor.startTimesBySectionByFunctionMap[sectionKey] and ExecutionTimeMonitor.startTimesBySectionByFunctionMap[sectionKey][funcName]
        if startTimes and #startTimes > 0 then
            local startTime = table.remove(startTimes)
            local elapsedTime = ExecutionTimeMonitor.getTimeSince(startTime)
            if not ExecutionTimeMonitor.performanceDataBySection[sectionKey] then
                ExecutionTimeMonitor.performanceDataBySection[sectionKey] = {}
            end
            local currentTime = ExecutionTimeMonitor.performanceDataBySection[sectionKey][funcName]
            if currentTime == nil then
                currentTime = 0
            end
            ExecutionTimeMonitor.performanceDataBySection[sectionKey][funcName] = currentTime + elapsedTime
        end
    else
        print("Error: ExecutionTimeMonitor is not initialized.")
    end
end

function ExecutionTimeMonitor.printPerformanceData()
    if ExecutionTimeMonitor.initialized then
        for sectionName, data in pairs(ExecutionTimeMonitor.performanceDataBySection) do
            local totalInSection = 0
            for _, time in pairs(data) do
                totalInSection = totalInSection + time
            end

            -- Write section header to the file
            ExecutionTimeMonitor.outputFile:write(string.format("Performance Information for Section '%s' (Total Time: %.6f seconds):\n", sectionName, totalInSection))

            -- Create a table to store function names and their times
            local timesInSection = {}
            for funcName, time in pairs(data) do
                timesInSection[funcName] = {
                    totalTime = time,
                    percentage = (time / totalInSection) * 100
                }
            end

            -- Sort the table by total time
            local sortedTimesInSection = {}
            for funcName, timeData in pairs(timesInSection) do
                table.insert(sortedTimesInSection, { funcName = funcName, data = timeData })
            end
            table.sort(sortedTimesInSection, function(a, b) return a.data.totalTime > b.data.totalTime end)

            -- Write performance information to the file
            for _, entry in ipairs(sortedTimesInSection) do
                local bar = string.rep("*", math.floor(entry.data.totalTime / totalInSection * 50))  -- Generate a bar graph (scaled by 50 for visual clarity)
                ExecutionTimeMonitor.outputFile:write(string.format("%s: %.6f seconds (%.2f%%) | %s\n", entry.funcName, entry.data.totalTime, entry.data.percentage, bar))
            end
            ExecutionTimeMonitor.outputFile:write("\n")  -- Add a newline for clarity between sections
        end

        -- Close the file after writing
        ExecutionTimeMonitor.outputFile:close()
    else
        print("Error: ExecutionTimeMonitor is not initialized.")
    end
end

function ExecutionTimeMonitor.getCurrentTime()
    return os.clock()
end

function ExecutionTimeMonitor.getTimeSince(event)
    return ExecutionTimeMonitor.getCurrentTime() - event
end

return ExecutionTimeMonitor
