---@class FunctionStats
local FunctionStatsClass = {}
FunctionStatsClass.__index = FunctionStatsClass

function FunctionStatsClass:new(functionCalls, section)
    ---@class FunctionStats
    local o = setmetatable({}, FunctionStatsClass)

    if #functionCalls < 1 then
        error("cannot calculate stats if function was never called!")
    end

    ---@type FunctionCall[]
    o.functionCalls = functionCalls
    o.totalTime = nil
    o.minTime = nil
    o.maxTime = nil
    o.nTimeCalled = nil
    o.averageTime = nil
    o.calculated = false
    o.functionName = o.functionCalls[1].functionName
    ---@type Section
    o.section = section
    o.percentageOfSection = nil
    o:calculateStats()

    return o
end

function FunctionStatsClass:calculateStats()
    self.totalTime = 0
    self.minTime = math.huge
    self.maxTime = 0
    self.nTimeCalled = 0

    for _,functionCall in ipairs(self.functionCalls) do
        self.nTimeCalled = self.nTimeCalled + 1
        if (functionCall.functionEnded) then
            self.totalTime = self.totalTime + functionCall.elapsedTime
            self.minTime = math.min(self.minTime, functionCall.elapsedTime)
            self.maxTime = math.max(self.maxTime, functionCall.elapsedTime)
        end
    end

    self.averageTime = self.totalTime / self.nTimeCalled
    self.percentageOfSection = (self.totalTime/ self.section.elapsedTime) * 100
    self.calculated = true

end

function FunctionStatsClass:getFunctionDisplayString(orderInSection)
    if not self.calculated then
        error("trying to display function stats before calcultating them")
    end
    return string.format("%s.%s: %.6f seconds/call | Total: %.6f seconds | %.2f%% of section", orderInSection, self.functionName, self.averageTime, self.totalTime, self.percentageOfSection)

end


return FunctionStatsClass