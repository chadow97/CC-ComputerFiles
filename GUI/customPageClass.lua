local PageClass = require "GUI.PageClass"
local ObTableClass          = require "GUI.ObTableClass"
local logger                = require "UTIL.logger"
local stringUtils           = require "UTIL.stringUtils"

-- Define constants

local ELEMENT_BACK_COLOR = colors.red
local INNER_ELEMENT_BACK_COLOR = colors.lime
local TEXT_COLOR = colors.yellow

-- Define the RessourcePage Class 
local CustomPageClass = {}
CustomPageClass.__index = CustomPageClass
setmetatable(CustomPageClass, {__index = PageClass})



function CustomPageClass:new(monitor, parentPage, document, pageType)
  self = setmetatable(PageClass:new(monitor, 1, 1, document), CustomPageClass)
  self.pageType = pageType
  self:setParentPage(parentPage)
  return self
end

function CustomPageClass:__tostring() 
  return stringUtils.Format("[CustomPage %(id), CustomPageType:%(pagetype), nElements:%(nelements), Position:%(position), Size:%(size) ]",
                            {id = self.id,
                            pagetype = tostring(self.pageType),
                            nelements = #self.elements,
                            position = (stringUtils.CoordToString(self.x, self.y)),
                            size = (stringUtils.CoordToString(self:getSize()))})
 
end

function CustomPageClass:buildCustomPage()
self.document:startEdition()
self:onBuildCustomPage()
self.document:endEdition()
end

function CustomPageClass:onBuildCustomPage()

end


return CustomPageClass