-- WorkOrderFetcher.lua
local colIntUtil = require("UTIL.colonyIntegratorPerUtils")
local logger = require("UTIL.logger")
local MeSystemClass         = require("COLONY.MODEL.MeSystemClass")
local meUtils               = require("UTIL.meUtils")
local ManagerClass = require("MODEL.ManagerClass")

local MeSystemManagerClass = {}

MeSystemManagerClass.TYPE = "ME_SYSTEM"

MeSystemManagerClass.__index = MeSystemManagerClass
setmetatable(MeSystemManagerClass, { __index = ManagerClass })

function MeSystemManagerClass:new(document)
    local o = setmetatable(ManagerClass:new(document), MeSystemManagerClass)
    o.type = MeSystemManagerClass.TYPE
    o.meSystem = nil
    return o
end

function MeSystemManagerClass:_getObsInternal()
    return {self.meSystem}
end

function MeSystemManagerClass:getMeSystem()
    self:getObs() -- refresh if needed.
    return self.meSystem
end

function MeSystemManagerClass:clear()
    self.meSystem = nil
    ManagerClass.clear(self)
end

function MeSystemManagerClass:_onRefreshObs()
    self.meSystem = MeSystemClass:new(self:getMeSystemData())
end


function MeSystemManagerClass:getMeSystemData()
    return meUtils.getMeData()
end


return MeSystemManagerClass