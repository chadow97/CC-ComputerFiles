-- ObTableClass.lua
local TableClass = require("GUI.TableClass")  -- Adjust the path if necessary
local logger     = require("UTIL.logger")
local PageStackClass = require("GUI.PageStackClass")
local stringUtils    = require("UTIL.stringUtils")

---@class ObTable: TableGUI
local ObTableClass = {}

ObTableClass.__index = ObTableClass
setmetatable(ObTableClass, { __index = TableClass })

-- Constructor for ObTableClass
function ObTableClass:new(  monitor, x, y, title, sizeX, sizeY, document )
    ---@class ObTable: TableGUI
    self = setmetatable(TableClass:new(  monitor, x, y, title, sizeX, sizeY, document ), ObTableClass)
    self.obList = {}
    self.dataFetcher = nil
    self.type = "ObClassTable"
    self.buttonIdToObMap = {}
    self.ObIdToButtonPairMap = {}

    return self
end

function ObTableClass:__tostring() 
    return stringUtils.Format("[ObTable %(id), Title:%(title), #ob:%(nob), Position:%(position), Size:%(size) ]",
                              {id = self.id,
                              title = stringUtils.Truncate(tostring(self.title),20),
                              nob = #self.obList,
                              position = (stringUtils.CoordToString(self.x, self.y)),
                              size = (stringUtils.CoordToString(self:getSize()))})
   
end

function ObTableClass:setDataFetcher(dataFetcher)
    self.dataFetcher = dataFetcher
    self:refreshData()
end

function ObTableClass:createElementButtons()
    --rewrite to not use internal table
    local index = 1
    self.buttonIdToObMap = {}
    self.ObIdToButtonPairMap = {}
    for _, ob in pairs(self.obList) do
        self.ObIdToButtonPairMap[ob:getUniqueKey()] = {}
        local CurrentButtonPair = self.ObIdToButtonPairMap[ob:getUniqueKey()]
        local keyButton, valueButton  = self:createTableElementsForRow(index, "tempValue", index)
        if keyButton then
            self.buttonIdToObMap[keyButton.id] = ob
            CurrentButtonPair.key = keyButton
        end
        self.buttonIdToObMap[valueButton.id] = ob
        CurrentButtonPair.value = valueButton
        index = index + 1
    end
end

---comment
---@param button Button
---@return unknown
function ObTableClass:getObFromButton(button)
    return self.buttonIdToObMap[button.id]
end

function ObTableClass:getButtonFromOb(ob, getKey)
    if not getKey then
        getKey = false
    end
    local ObButtonPair = self.ObIdToButtonPairMap[ob:getUniqueKey()]
    if getKey then
        return ObButtonPair.key
    else
        return ObButtonPair.value
    end
end

function ObTableClass:getStringToDisplayForElement(data, isKey, position)
    --rewrite to use OB data

    if isKey then
        return self.obList[position]:GetKeyDisplayString()
    else
        return self.obList[position]:GetDisplayString()
    end
end

function ObTableClass:getTableElementStyleAccordingToData(isKey, position)
    -- return elementBackColor, elementTextColor
    return self.obList[position]:getObStyle(isKey, position)
end

-- Getter/setter for the internal table
function ObTableClass:setInternalTable(internalData)
    self.internalData = nil
    error("setInternalTable was called but is not implemented!")
end

function ObTableClass:getInternalTable()

    error("getInternalTable was called but is not implemented!")
    return nil
end

function ObTableClass:getRowCount()
    return #self.obList
end

function ObTableClass:refreshData()
    -- ask data handler for new data

    -- refresh is not setup
    if not self.dataFetcher then
        error("No fetcher, ob list will always be empty!")
        return
    end

    local NewObList = self.dataFetcher:getObs()

    -- nothing to do if table didn't change
    if (not NewObList or NewObList == self.obList) then
        return
    end
    self.document:startEdition()
    self.obList = NewObList
    self.areButtonsDirty = true
    self:setElementDirty()
    self:onPostRefreshData()
    self.document:registerCurrentAreaAsDirty(self)
    self.document:endEdition()
end

function ObTableClass:processTableElement(elementButton, key, value, position)
    -- overwritten because we do not want default table element behavior from TableClass
end

function ObTableClass:setOnTableElementPressedCallbackForElement(button, key, isKey, position, data)

    local  wrapper =
        function()
            self.onTableElementPressedCallback(position, isKey, self.obList[position])
        end 

    if self.onTableElementPressedCallback then
        button:setOnManualToggle(wrapper)
        return true
    end
    return false
end

function ObTableClass:setupOnDrawButton(button, key, isKey, position, data)
    local wrapper = 
        function()
            self.onDrawButton(position, isKey, button, self.obList[position])
        end
    if self.onDrawButton then
        button:setOnDrawCallback(wrapper)
        return true
    end
    return false
end

return ObTableClass