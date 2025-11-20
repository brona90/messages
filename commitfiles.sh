#!/bin/bash

# Configuration
REPO_SUBFOLDER="images"             # !! The final destination folder inside your repo
BATCH_SIZE=20
REMOTE_NAME="origin"                # Usually 'origin'
BRANCH_NAME="main"                  # !! Change to your branch name
TEMP_DIR="/tmp/git_batch_temp"      # A temporary holding place outside the repo

echo "Starting batch commit process using 'move' strategy."

# Ensure the script is run from the root of the git repository
cd "$(git rev-parse --show-toplevel)" || exit

# Create the temp directory if it doesn't exist
mkdir -p "$TEMP_DIR"
mkdir -p "$REPO_SUBFOLDER"

# Move all existing files from the repo subfolder to the temporary directory
# We look for files *not* tracked by git already (?? status) or modified (M status)
# If the folder already has a clean state, this just moves new files
echo "Moving all files from $REPO_SUBFOLDER to $TEMP_DIR..."
find "$REPO_SUBFOLDER" -maxdepth 1 -type f -exec mv {} "$TEMP_DIR" \;
echo "Move complete. Starting batch processing."

# Loop while there are files in the temporary directory
while [ "$(ls -A "$TEMP_DIR")" ]; do
    echo "--- Processing next batch of $BATCH_SIZE files ---"

    # Get a list of files (up to BATCH_SIZE) from the temp dir
    FILES_TO_MOVE=$(ls -A "$TEMP_DIR" | head -n "$BATCH_SIZE")

    # Move the selected batch back into the repository subfolder
    for file_name in $FILES_TO_MOVE; do
        mv "$TEMP_DIR/$file_name" "$REPO_SUBFOLDER/$file_name"
    done
    
    # Check if files were actually moved before proceeding
    if [ -z "$FILES_TO_MOVE" ]; then
        echo "No files left in temporary directory. Exiting loop."
        break
    fi

    # Stage the files that were just moved into the repo
    # This specifically targets the files we just moved.
    git add "$REPO_SUBFOLDER"

    # Commit the staged changes
    COMMIT_MESSAGE="Batch commit $(date +'%Y-%m-%d %H:%M:%S')"
    git commit -m "$COMMIT_MESSAGE"
    echo "Committed with message: '$COMMIT_MESSAGE'"

    # Push the changes
    git push "$REMOTE_NAME" "$BRANCH_NAME"
    echo "Pushed to $REMOTE_NAME/$BRANCH_NAME"
    echo "--------------------------------------------------"

    # Small pause
    sleep 2
done

# Clean up the temporary directory after completion
rmdir "$TEMP_DIR" || true

echo "All files in $REPO_SUBFOLDER have been committed and pushed successfully."
