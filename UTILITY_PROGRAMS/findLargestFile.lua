-- Function to get the size of a file or directory
local function getSize(path)
    if fs.isDir(path) then
        local size = 0
        local list = fs.list(path)
        for _, file in ipairs(list) do
            size = size + getSize(fs.combine(path, file))
        end
        return size
    else
        return fs.getSize(path)
    end
end

-- Function to gather file or directory sizes
local function scanPath(path, considerDirectories)
    local itemList = {}
    local list = fs.list(path)
    for _, item in ipairs(list) do
        local fullPath = fs.combine(path, item)
        if fs.isDir(fullPath) and considerDirectories then
            -- If considering directories, add the directory and its size
            table.insert(itemList, {path = fullPath, size = getSize(fullPath)})
        elseif not fs.isDir(fullPath) and not considerDirectories then
            -- If considering files, add the file and its size
            table.insert(itemList, {path = fullPath, size = fs.getSize(fullPath)})
        end
    end
    return itemList
end

-- Main function
local function main(args)
    -- Parsing command line arguments
    local numItemsToDisplay = tonumber(args[1]) or 10 -- Default to 10 if no number is provided
    local directory = args[2] or "" -- Default to root directory if no directory is provided
    local considerDirectories = args[3] == "dirs" -- Check if 'dirs' argument is provided

    -- Check if the provided directory exists
    if not fs.exists(directory) or not fs.isDir(directory) then
        print("Invalid directory: " .. directory)
        return
    end

    local itemList = scanPath(directory, considerDirectories)

    -- Sorting the items by size
    table.sort(itemList, function(a, b) return a.size > b.size end)

    -- Calculating the total available space
    local totalSpace = fs.getFreeSpace("/") + getSize("/")

    -- Displaying the specified number of results and their size as a percentage of the total available space
    for i = 1, math.min(numItemsToDisplay, #itemList) do
        local item = itemList[i]
        local percentage = (item.size / totalSpace) * 100
        print(i .. ". " .. item.path .. " (" .. item.size .. " bytes, " .. string.format("%.2f", percentage) .. "% of total space)")
    end
end

-- Running the program
main({...})