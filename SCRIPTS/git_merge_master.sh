#!/bin/bash

# Get the current branch
current_branch=$(git rev-parse --abbrev-ref HEAD)

# Fetch the latest changes from the remote repository
git fetch origin

# Ensure the local master branch is up-to-date with the remote repository
git checkout master
git pull origin master

# Display a recap of the changes between the temp branch and the current master branch
echo "Recap of changes to be merged:"
git diff temp

# Wait for user confirmation
read -p "Press enter to continue or Ctrl+C to cancel"

# Merge the temp branch into the master branch with a squash commit
git merge --squash temp

# Commit the squashed changes with the provided commit message
git commit -m "$1"

# Push the changes to the remote repository's master branch
git push origin master

# Return to the original branch