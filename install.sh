#!/bin/bash

SOURCE_DIR="./home"
TARGET_DIR="$HOME"

cp -a "$SOURCE_DIR/." "$TARGET_DIR"

echo "Dotfiles from '$SOURCE_DIR' copied to '$TARGET_DIR'"
