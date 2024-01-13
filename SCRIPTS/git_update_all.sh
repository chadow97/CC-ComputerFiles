#!/bin/bash

# Get the root directory of the Git repository
root_dir=$(git rev-parse --show-toplevel)

# Specify the path to git_directories.txt in the /scripts folder
directories_file="${root_dir}/SCRIPTS/git_directories.txt"

# Check if git_directories.txt exists in the /scripts folder
if [ ! -f "$directories_file" ]; then
    echo "Error: git_directories.txt not found in the /scripts folder."
    exit 1
fi

# Check if git_directories.txt is empty or contains only whitespace
if [ ! -s "$directories_file" ]; then
    echo "Error: git_directories.txt is empty or contains only whitespace."
    exit 1
fi

echo "reading directories to update from $directories_file"

# Loop through each directory listed in git_directories.txt
while read -r dir; do
    echo "$dir"

    # Ensure the directory path is not empty or whitespace
    if [[ -z "$dir" ]]; then
        echo "Error: Empty or invalid directory path found in git_directories.txt."
        continue
    fi

    full_path=$(echo -n "${dir}" | tr -d '\r')

    echo "updating $full_path"
    
    # Change directory to the specified path
    cd "$full_path"
    echo "changed active directory to $full_path"
    
    # Check if the directory is a valid Git repository
    if [ -d .git ]; then
        current_branch=$(git rev-parse --abbrev-ref HEAD)
        
        # Check if the current branch is not "temp"
        if [ "$current_branch" != "temp" ]; then
            echo "Error: Not on branch 'temp' in $full_path"
        else
            # Fetch updates from all remotes and pull from the 'temp' branch
            git fetch --all
            git pull origin temp && echo "updated $full_path"
        fi
    else
        echo "Not a valid Git directory: $full_path"
    fi
    
done < "$directories_file"

    # Return to the root directory of the Git repository
cd "$root_dir"
echo "changed active directory to $root_dir, program done."