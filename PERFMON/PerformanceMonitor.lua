local SectionClass = require "PERFMON.SectionClass"
local stringUtils  = require "UTIL.stringUtils"
local logger       = require "UTIL.logger"

local DEFAULT_INSTANCE_KEY = "DEFAULT_INSTANCE_KEY"

---@class PerformanceMonitor
local PerformanceMonitorClass = {
    instance = nil
}
PerformanceMonitorClass.__index = PerformanceMonitorClass

---comment
---@param fileName string
---@param title string
---@param isActivated? boolean true by default
---@return PerformanceMonitor
function PerformanceMonitorClass.createInstance(fileName, title, isActivated)

    if type(fileName) ~= "string" then
        error("No valid filename provided")
    end
    if PerformanceMonitorClass.instance ~= nil then
        error("Instance already created")
    end

    PerformanceMonitorClass.instance = PerformanceMonitorClass:new(fileName, title, isActivated)
    return PerformanceMonitorClass.instance
end

---comment
---@return PerformanceMonitor | nil
function PerformanceMonitorClass.getInstance()
    return PerformanceMonitorClass.instance   
end

function PerformanceMonitorClass:new(fileName, title, isActivated)
    ---@class PerformanceMonitor
    local o = setmetatable({}, PerformanceMonitorClass)

    o.fileName = fileName
    o.loggingEnabled = false
    fs.delete(o.fileName)

    o.currentSection = nil
    o.completedSections = {}
    o.sectionsByName = {}
    o.title = title
    o.width = 100
    if isActivated == false then
        o.activated = false
    else
        o.activated = true
    end

    if o.activated then
        o:addToFile(o:getMainHeader(o.width))
    end
    return o
end

function PerformanceMonitorClass:addToFile(textToAdd)
    local file = fs.open(self.fileName,"a")
    assert(file, "Failed to open file")
    file.write(textToAdd)
    file.close()
end

function PerformanceMonitorClass:setupHooks()
    if not self.activated then
        return
    end
    if self.loggingEnabled then
        debug.sethook(function(event)
            local info = debug.getinfo(2, "n")  -- Get function name
            local name = info.name
            if name == nil then
                name = "UNNAMED_FUNCTIONS"
            end
            if info and info.name then
                if event == "call" then
                    self:onFunctionStart(name)
                elseif event == "return" then
                    self:onFunctionEnd(name)
                end
            end
        end, "cr")
    else
        debug.sethook()  -- Clear the hook to disable logging
    end
end

function PerformanceMonitorClass:startLogging()
    if not self.activated then
        return
    end
    self.loggingEnabled = true
    self:setupHooks()
end

function PerformanceMonitorClass:stopLogging()
    if not self.activated then
        return
    end
    self.loggingEnabled = false
    self:setupHooks()
end

function PerformanceMonitorClass:startSection(sectionName)
    if not self.activated then
        return
    end
    if sectionName == nil then
        error("cannot start unnamed section")
    end
    if self.currentSection ~= nil then
        error("section already started!")
    end

    if self.sectionsByName[sectionName] == nil then
        self.sectionsByName[sectionName] = {}
    end
    local sectionsWithSameName = self.sectionsByName[sectionName]
    self.currentSection = SectionClass:new(PerformanceMonitorClass.getCurrentTime(), 
                                           sectionName, 
                                           #self.completedSections + 1,
                                           #sectionsWithSameName + 1, 
                                           self)

    table.insert(self.sectionsByName[sectionName], self.currentSection)
    self:startLogging()
    return self.currentSection

end

function PerformanceMonitorClass:endSection(section)
    if not self.activated then
        return
    end
    if self.currentSection == nil then
        error("No section to end!")
    end
    if type(section) == "string" then
        assert(section == self.currentSection.name, "ending wrong section")
    else
        assert(section == self.currentSection, "ending wrong section!")      
    end
    section = self.currentSection
    self:stopLogging()

    section:OnSectionEnd(self:getCurrentTime())
    self:addToFile(section:getSectionDisplay(self.width))
    
    self.currentSection = nil
    table.insert(self.completedSections,section)


end

function PerformanceMonitorClass:getMainHeader(width)
    local sep1 = string.rep("X",width)
    local title = "PERFORMANCE REPORT: " .. self.title
    local centeredTitle = stringUtils.CenterStringInLine(title,width)
    
    return table.concat({
        sep1,
        sep1,
        centeredTitle,
        sep1,
        sep1
    }, "\n") .. "\n"

end

function PerformanceMonitorClass:onFunctionStart(name)
    if not self.loggingEnabled then
        return
    end
    self.currentSection:onFunctionStart(name, self:getCurrentTime())

end

function PerformanceMonitorClass:onFunctionEnd(name)
    if not self.loggingEnabled then
        error("logging disabled!")
    end
    if not self.currentSection then
        error("No section started!")
    end
    self.currentSection:onFunctionEnd(name, self:getCurrentTime())
end

function PerformanceMonitorClass.getCurrentTime()
    return os.epoch("local") / 1000
end

function PerformanceMonitorClass:endMonitoring()
    if self.currentSection ~= nil then
        error("didnt complete last section!")
    end

end


return PerformanceMonitorClass