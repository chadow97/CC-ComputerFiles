-- add absolute paths to package to allow programs to use libraries from anywhere!
package.path = package.path .. ";/?;/?.lua"

local MonUtils = require("UTIL.monUtils")
local logger = require("UTIL.logger")


---@type Monitor
local monitor = peripheral.find("monitor")
MonUtils.resetMonitor(monitor)

local terminal = term.current()
logger.init(terminal, "buttonTest", true)



local my_window = window.create(monitor, 1, 1, 20, 5)
my_window.setBackgroundColour(colours.red)
my_window.setTextColour(colours.white)
my_window.clear()
my_window.write("Testing my window!")
for i = 1, 10 do
    my_window.setVisible(false)
    my_window.reposition(i,i)
    sleep(1)
end

my_window.setVisible(true)