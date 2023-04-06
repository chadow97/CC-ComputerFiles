                -- file doesnt exist in output dir
print(fs.getFreeSpace("/"))
local file = fs.open("testwrite", "w")

file.writeLine("testWrite")
file.close()
