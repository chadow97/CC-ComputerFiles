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
local function scanPath(path, considerDirectories, itemList)
    itemList = itemList or {}
    local list = fs.list(path)
    for _, item in ipairs(list) do
        local fullPath = fs.combine(path, item)
        if fs.isDir(fullPath) then
            if considerDirectories then
                -- If considering directories, add the directory and its size
                table.insert(itemList, {path = fullPath, size = getSize(fullPath)})
            else
                -- If considering files, recursively scan the subdirectory
                scanPath(fullPath, considerDirectories, itemList)
            end
        elseif not fs.isDir(fullPath) then
            -- Add the file and its size
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

    -- Fixed total space of the drive
    local totalSpace = fs.getCapacity("/")

    -- Calculating the total used space
    local totalUsedSpace = getSize("/")

    -- Calculating the total available space
    local totalAvailableSpace = totalSpace - totalUsedSpace

    -- Calculating the percentage of space used
    local percentageUsed = (totalUsedSpace / totalSpace) * 100

    -- Displaying the total space information
    print("Total space available: " .. totalSpace  .." bytes")
    print("Total space used: " .. totalUsedSpace .. " bytes")
    print("Total space available: " .. totalAvailableSpace .. " bytes")
    print("Percentage of space used: " .. string.format("%.2f", percentageUsed) .. "%")

    -- Displaying the specified number of results and their size as a percentage of the total space
    for i = 1, math.min(numItemsToDisplay, #itemList) do
        local item = itemList[i]
        local itemPercentage = (item.size / totalSpace) * 100
        print(i .. ". " .. item.path .. " (" .. item.size .. " bytes, " .. string.format("%.2f", itemPercentage) .. "% of total space)")
    end
end

-- Running the program
main({...})
