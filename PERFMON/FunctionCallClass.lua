
---@class FunctionCall
local FunctionCallClass = {}
FunctionCallClass.__index = FunctionCallClass

function FunctionCallClass:new(section, startTime, orderInSection, functionName, nRepetitionInSection)
    ---@class FunctionCall
    local o = setmetatable({}, FunctionCallClass)

    o.section = section
    o.startTime = startTime
    o.functionName = functionName
    o.orderInSection = orderInSection
    o.nRepetitionInSection = nRepetitionInSection
    o.endTime = nil
    o.elapsedTime = nil
    o.functionEnded = false

    return o
end

function FunctionCallClass:OnFunctionCallEnd( endTime)
    if self.functionEnded then
        error("function ending twice!")
    end
    self.endTime = endTime
    self.elapsedTime = self.endTime - self.startTime
    self.functionEnded = true
end


return FunctionCallClass