#!/bin/bash

# Get the current branch name
current_branch=$(git rev-parse --abbrev-ref HEAD)

# Check if the current branch is not "temp"
if [ "$current_branch" != "temp" ]; then
    echo "Error: Not on branch 'temp'"
else
    git add -A && git commit -m "AUTO-COMMIT" && git push
    echo "added and commited changes on temp"
fi