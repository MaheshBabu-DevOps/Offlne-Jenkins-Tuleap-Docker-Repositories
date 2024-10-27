#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <path_to_iso> <output_directory>"
    exit 1
fi

ISO_PATH=$1
OUTPUT_DIR=$2
MOUNT_POINT="/mnt/"

# Create a mount point if it doesn't exist
if [ ! -d "$MOUNT_POINT" ]; then
    sudo mkdir "$MOUNT_POINT"
fi

# Mount the ISO file
sudo mount -o loop "$ISO_PATH" "$MOUNT_POINT"
if [ $? -ne 0 ]; then
    echo "Failed to mount ISO."
    exit 1
fi

# Create the output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Copy the contents to the output directory
sudo cp -r "$MOUNT_POINT/"* "$OUTPUT_DIR/"
if [ $? -ne 0 ]; then
    echo "Failed to copy contents."
    sudo umount "$MOUNT_POINT"
    exit 1
fi

# Unmount the ISO
sudo umount "$MOUNT_POINT"
if [ $? -ne 0 ]; then
    echo "Failed to unmount ISO."
    exit 1
fi

# Clean up
sudo rmdir "$MOUNT_POINT"

echo "ISO contents extracted to $OUTPUT_DIR successfully."

