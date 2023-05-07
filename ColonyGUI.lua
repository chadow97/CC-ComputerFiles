
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
local MeUtils = require("UTIL.meUtils")

local monitor = peripheral.find("monitor")

local terminal = term.current()
logger.init(terminal, "buttonTest", true)


-- define colors
local backgroundColor = colors.yellow
local elementBackColor = colors.red
local innerElementBackColor = colors.yellow
local textColor = colors.lime


local isRunning = true

local buttonList = {}

local function endProgram()
    isRunning = false
end

local page = PageClass.new(monitor)
page:setBackColor(backgroundColor)



local monX, monY =monitor.getSize()


local ExitButton = ButtonClass:new(monX - 1, monY -1, "X")
ExitButton:setFunction(endProgram)
ExitButton:changeStyle(nil, elementBackColor)
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
internalTable:changeStyle(elementBackColor, innerElementBackColor, textColor)
pageStack1:changeStyle(nil, elementBackColor)

local itemsMap = {}

local CraftableItems = MeUtils.getCraftableItems()
for _, value in pairs(CraftableItems) do
    itemsMap[value.name] = value
end
local CurrentMeItems = MeUtils.getItemList()
for _, value in pairs(CurrentMeItems) do
    itemsMap[value.name] = value
end

logger.log(itemsMap)

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
            local missing = ressource.needed - ressource.available - ressource.delivering
            local valueToShow = ressource.item .. "\nMissing:" .. missing .. "\n"
            local itemMeData = itemsMap[ressource.item]
            if missing > 0 and itemMeData then
                if itemMeData.amount >= missing then
                    valueToShow = valueToShow .. "Me system has:" .. itemMeData.amount .. "\n(Press to send to colony)"
                elseif itemMeData.isCraftable then
                    valueToShow = valueToShow .. "Me system has:" .. itemMeData.amount .. ",need " .. missing - itemMeData.amount .. " more.\n(Press to craft and send!)"
                else
                    valueToShow = valueToShow .. "Me system has:" .. itemMeData.amount .. ",need " .. missing - itemMeData.amount .. " more.\n(Not craftable!!!)"
                end
            else    
                valueToShow = valueToShow .. "Me system has: 0, need " .. missing .." more.\n(Not craftable!!!)"
            end
            table.insert(ressourceTableToShow, valueToShow)
            ressourceByValueToShow[valueToShow] = ressource

        end

        local ressourceTable = TableClass:new(monitor, 5, 5, "ressources")
        ressourceTable:setDisplayKey(false)
        ressourceTable:setInternalTable(ressourceTableToShow)
        ressourceTable:setRowHeight(6)
        ressourceTable:changeStyle(elementBackColor, innerElementBackColor, textColor)


        local onDrawFunc =
            function (position, isKey, data, button)
                if isKey then
                    return
                end
                local ressource = ressourceByValueToShow[data]
                local missing = ressource.needed - ressource.available - ressource.delivering
                local color =colors.green
                if missing > 0 then
                    -- missing some item, look in me system!
                    local itemMeData = itemsMap[ressource.item]
                    if  itemMeData then
                        if itemMeData.amount >= missing then
                            color = colors.yellow
                        elseif itemMeData.isCraftable then
                            color = colors.orange
                        else
                            color = colors.red
                        end
                    else
                        -- items     
                        color = colors.red
                    end
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



while isRunning do
---@diagnostic disable-next-line: undefined-field
    page:handleEvent(os.pullEvent())
end

