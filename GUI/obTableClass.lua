-- ObTableClass.lua
local TableClass = require("GUI.tableClass")  -- Adjust the path if necessary
local logger     = require("UTIL.logger")
local PageStackClass = require("GUI.pageStackClass")

local ObTableClass = {}

ObTableClass.__index = ObTableClass
setmetatable(ObTableClass, { __index = TableClass })

-- Constructor for ObTableClass
function ObTableClass:new( ... )
    self = setmetatable(TableClass:new( ... ), ObTableClass)
    self.obList = {}
    self.dataFetcher = nil

    return self
end

function ObTableClass:setDataFetcher(dataFetcher)
    self.dataFetcher = dataFetcher
    self:refreshData()
end

function ObTableClass:createElementButtons()
    --rewrite to not use internal table
    local index = 1
    for _, ob in pairs(self.obList) do
        self:createTableElementsForRow(index, "tempValue", index)
        index = index + 1
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

function ObTableClass:getButtonStyleAccordingToData(isKey, position)
    -- return elementBackColor, elementTextColor
    return self.obList[position]:getObStyle()
end

-- Getter/setter for the internal table
function ObTableClass:setInternalTable(internalData)
    self.internalData = nil
    logger.log("setInternalTable was called but is not implemented!")
end

function ObTableClass:getInternalTable()

    logger.log("getInternalTable was called but is not implemented!")
    return nil
end

function ObTableClass:getRowCount()
    return #self.obList
end

function ObTableClass:refreshData()
    -- ask data handler for new data

    -- refresh is not setup
    if not self.dataFetcher then
        logger.log("No fetcher, ob list will always be empty!")
        return
    end

    local NewObList = self.dataFetcher:getData()
    logger.db(NewObList)

    -- nothing to do if table didn't change
    if (not NewObList or NewObList == self.obList) then
        return
    end

    self.obList = NewObList
    self.areButtonsDirty = true
    self:setElementDirty()
    self:askForRedraw()
    self:onPostRefreshData()
end

function ObTableClass:processTableElement(elementButton, key, value, position)
    -- overwritten because we do not want default table element behavior from tableClass
    self:setupOnManualToggle(elementButton,key, false, position, value )

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