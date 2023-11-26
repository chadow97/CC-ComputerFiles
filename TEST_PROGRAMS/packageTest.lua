print(fs.combine("/something/file.lua", ".."))
print(package.path)
--print(shell.dir())
--print(shell.getRunningProgram())
--print("shell path:")
--print(shell.path())

package.path = package.path .. ";/?;/?.lua"

-- Example usage
local ButtonClass = require("GUI.ButtonClass") -- This will now go through your custom require function
print(ButtonClass)
