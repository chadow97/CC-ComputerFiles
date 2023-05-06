
local ButtonClass = require("GUI.buttonClass")
local ToggleableButtonClass = require("GUI.toggleableButtonClass")
local PageClass = require("GUI.pageClass")
local TableClass = require("GUI.tableClass")
local MonUtils = require("UTIL.monUtils")
local MeUtils = require("UTIL.meUtils")
local logger = require("UTIL.logger")
local PageStackClass = require("GUI.pageStackClass")
local colIntUtil = require("UTIL.colonyIntegratorPerUtils")
local peripheralProxyClass = require("UTIL.peripheralProxy")

local monitor = peripheral.find("monitor")
MonUtils.resetMonitor(monitor, colors.purple)

local terminal = term.current()
logger.init(terminal, "buttonTest", true)


local isRunning = true

local buttonList = {}

local function endProgram()
    isRunning = false
end

local page = PageClass.new(monitor)



local monX, monY =monitor.getSize()


local ExitButton = ButtonClass:new(monX - 1, monY -1, "X")
ExitButton:setFunction(endProgram)
table.insert(buttonList, ExitButton)

local channel = 1

local colIntPer = peripheralProxyClass:new(channel, "colonyIntegrator" )

local status, workOrders = pcall(colIntUtil.getWorkOrders,colIntPer)
if not status then
    logger.log(workOrders)
    logger.log(debug.traceback())
    return
end

local tableToShow = {}
local workOrderByValueToShow = {}
for _, value in pairs(workOrders) do
    local valueToShow = "Pending work order " .. value.id .. ". \nBuilding " .. value.buildingName
    table.insert(tableToShow, valueToShow)
    workOrderByValueToShow[valueToShow] = value
end
local pageStack1, internalTable = TableClass.createTableStack(monitor, 5, 5, 40, 30, tableToShow, "Item List")
internalTable:setDisplayKey(false)
internalTable.title = nil
internalTable:setRowHeight(4)





local onPressFunc = 
    function (position, isKey, data)
        if isKey then
            return
        end
        -- get workorder data represented by pressed button
        local workOrder = workOrderByValueToShow[data]
        local ressources = colIntPer:getWorkOrderResources(workOrder.id)[1]

        local ressourceTableToShow = {}
        local ressourceByValueToShow = {}

        for _, ressource in pairs(ressources) do
            local valueToShow = ressource.item .. "\nMissing:" .. ressource.needed - ressource.available - ressource.delivering
            table.insert(ressourceTableToShow, valueToShow)
            ressourceByValueToShow[valueToShow] = ressource

        end

        local ressourceTable = TableClass:new(monitor, 5, 5, "ressources")
        ressourceTable:setDisplayKey(false)
        ressourceTable:setInternalTable(ressourceTableToShow)
        ressourceTable:setRowHeight(4)


        local onDrawFunc =
            function (position, isKey, data, button)
                if isKey then
                    return
                end
                local ressource = ressourceByValueToShow[data]
                local missing = ressource.needed - ressource.available - ressource.delivering
                local color =colors.green
                if missing > 0 then
                    color = colors.red
                end

                button:setTextColor(color)
            end



        ressourceTable:setOnDrawButton(onDrawFunc)
        pageStack1:pushPage(ressourceTable)


        


    end

internalTable:setOnPressFunc(onPressFunc)
table.insert(buttonList, pageStack1)

page:addButtons(buttonList)
page:draw()

--pageStack:draw()


while isRunning do
---@diagnostic disable-next-line: undefined-field
    page:handleEvent(os.pullEvent())
end

