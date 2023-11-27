-- Function to check if a file should be ignored based on its extension or directory
local function shouldIgnoreFile(filePath)
    local ignoredExtensions = { ".output", ".log", ".code-workspace" }
    local ignoredDirectories = { ".vscode", ".git", "rom", "DATA", "COLONY" }

    for _, extension in ipairs(ignoredExtensions) do
        if filePath:sub(-#extension) == extension then
            return true
        end
    end

    for _, dir in ipairs(ignoredDirectories) do
        if filePath:find(dir, 1, true) then
            return true
        end
    end

    return false
end

-- Function to write a header to the output file
local function writeHeader(outputFile, headerType, name)
    local line = string.rep("-", 79)
    local nameLength = #name
    local paddedName = string.rep(" ", math.floor((79 - nameLength) / 2)) .. name

    if headerType == "file" then
        outputFile.write("\n" .. line .. "\n")
        outputFile.write(paddedName .. "\n")
        outputFile.write(line .. "\n")
    elseif headerType == "directory" then
        local doubleLine = string.rep("=", 79)
        outputFile.write("\n" .. doubleLine .. "\n")
        outputFile.write(paddedName .. "\n")
        outputFile.write(doubleLine .. "\n")
    end
end

-- Function to append a file's content to the output file
local function appendFileContent(inputPath, outputPath, filePath)

    local inputFile = fs.open(filePath, "r")
    if not inputFile then
        print("Error opening file: " .. filePath)
        return
    end

    local outputFile = fs.open(outputPath, "a")
    writeHeader(outputFile, "file", filePath)
    
    local line = inputFile.readLine()
    while line do
        outputFile.write(line .. "\n")
        line = inputFile.readLine()
    end

    inputFile.close()
    outputFile.close()
end

-- Recursive function to process all files in a directory and its subdirectories
local function processDirectory(directoryPath, outputPath, relativePath, firstFile)
    relativePath = relativePath or ""
    firstFile = firstFile or true  -- Flag to check if it's the first file in the directory

    for _, fileName in ipairs(fs.list(directoryPath)) do
        local filePath = fs.combine(directoryPath, fileName)

        if fs.isDir(filePath) then
            
            if not shouldIgnoreFile(filePath) then
                print("Processing directory: " .. filePath)
                processDirectory(filePath, outputPath, fs.combine(relativePath, fileName) .. "/", true)
            else
                print("Ignoring directory: " .. filePath)
            end
        else
            if not shouldIgnoreFile(filePath) then
                if firstFile then
                    local outputFile = fs.open(outputPath, "a")
                    writeHeader(outputFile, "directory", relativePath)
                    outputFile.close()
                    firstFile = false
                end

                appendFileContent(directoryPath, outputPath, fs.combine(relativePath, fileName))
            else
                print("Ignoring file: " .. filePath)
            end
        end
    end
end



-- Set the root directory to the current directory and output file name
local rootDirectoryPath = "/" -- Current directory
local outputPath = "/output/combined_output.output" -- Output file name

-- Make sure the output file is empty
local outputFile = fs.open(outputPath, "w")
outputFile.close()

-- Call the main function
processDirectory(rootDirectoryPath, outputPath)
print("Files have been combined into " .. outputPath)