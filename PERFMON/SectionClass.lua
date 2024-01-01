local FunctionCallClass = require "PERFMON.FunctionCallClass"
local stringUtils       = require "UTIL.stringUtils"
local FunctionStatsClass= require "PERFMON.FunctionStatsClass"
local logger            = require "UTIL.logger"
---@class Section
local SectionClass = {}
SectionClass.__index = SectionClass

function SectionClass:new(startTime, sectionName, sectionOrder, sectionRepetition, performanceMonitor)
    ---@class Section
    local o = setmetatable({}, SectionClass)

    o.name = sectionName
    o.startTime = startTime
    o.sectionOrder = sectionOrder
    o.sectionRepetition = sectionRepetition
    o.endTime = nil
    o.elapsedTime = nil
    o.sectionEnded = false
    o.nFunctionCalls = 0
    o.functionCallsByFunctionNameMap = {}

    o.peformanceMonitor = performanceMonitor

    return o
end

function SectionClass:getSectionKey()
    return self.name .. tostring(self.sectionRepetition)
end

function SectionClass:onFunctionStart(funcName, startTime)
    if self.peformanceMonitor[funcName] ~= nil or self[funcName] ~= nil then
        return
    end
    if self.sectionEnded then
        
        error("function " .. funcName .. "started after section end!")
    end
    self.nFunctionCalls = self.nFunctionCalls + 1

    if self.functionCallsByFunctionNameMap[funcName] == nil then
        self.functionCallsByFunctionNameMap[funcName] = {}
    end
    local numberOfFunctionRepetition = #self.functionCallsByFunctionNameMap[funcName] + 1


    

    local newFunctionCall = FunctionCallClass:new(self, startTime, self.nFunctionCalls, funcName, numberOfFunctionRepetition)

    table.insert(self.functionCallsByFunctionNameMap[funcName], newFunctionCall)
end

function SectionClass:onFunctionEnd(funcName, endTime)
    if self.peformanceMonitor[funcName] ~= nil or self[funcName] ~= nil then
        return
    end

    if self.functionCallsByFunctionNameMap[funcName] == nil then
        error("function was ended without being started!")
    end

    local functionCalls = self.functionCallsByFunctionNameMap[funcName]
    local indexToEnd = #functionCalls
    local functionCallToEnd = nil
    while indexToEnd > 0 do
        functionCallToEnd = functionCalls[indexToEnd]
        if not functionCallToEnd.functionEnded then
            break
        end
        indexToEnd = indexToEnd - 1
    end


    if functionCallToEnd == nil or functionCallToEnd.functionEnded then
        error("trying to end already ended function!")
    end

    functionCallToEnd:OnFunctionCallEnd(endTime)

end

function SectionClass:endSection()
    
    self.peformanceMonitor:endSection(self)
end

function SectionClass:OnSectionEnd( endTime)
    if self.sectionEnded then
        error("section was already ended!")
    end
    self.endTime = endTime
    self.elapsedTime = self.endTime - self.startTime
    self.sectionEnded = true
end

function SectionClass:getSectionDisplay(width)
    return self:getSectionHeader(width)  .. self:getFunctionsStatsDisplay()

end



function SectionClass:getSectionHeader(width)
    local sep1 = string.rep("=",width)
    local sep2 = string.rep("-",width)
    local sectionTitle = "SECTION: " .. self:getSectionKey()
    local centeredTitle = stringUtils.CenterStringInLine(sectionTitle,width)
    local sectionInfo = string.format("Section total time: %s, Section id: %s , #function calls: %s", self.elapsedTime, self.sectionOrder, self.nFunctionCalls)
    local centeredSectionInfo = stringUtils.CenterStringInLine(sectionInfo, width)
    return table.concat({
        sep1,
        centeredTitle,
        sep1,
        centeredSectionInfo,
        sep2
    }, "\n") .. "\n"

end

function SectionClass:getFunctionsStatsDisplay()
    
    local sortedFunctionStats = self:getAllFunctionStats()
    table.sort(sortedFunctionStats, function(a, b) return a.averageTime > b.averageTime end)
    local functionStatsDisplay = ""
    for order, sortedFunctionStat in ipairs(sortedFunctionStats) do
        functionStatsDisplay = functionStatsDisplay .. sortedFunctionStat:getFunctionDisplayString(order) .. "\n"
    end

    return functionStatsDisplay
end


---@return FunctionStats[]
function SectionClass:getAllFunctionStats()
    local functionStats = {}
    for funcName, functionCalls in pairs(self.functionCallsByFunctionNameMap) do
        table.insert(functionStats, FunctionStatsClass:new(functionCalls,self))
    end
    return functionStats
end




return SectionClass