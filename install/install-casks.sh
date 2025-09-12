#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CASKS_FILE="${SCRIPT_DIR}/casks.txt"

if [[ ! -f "$CASKS_FILE" ]]; then
    echo "Error: ${CASKS_FILE} not found!"
    echo "Run backup-brew.sh first to generate the casks list."
    exit 1
fi

echo "Installing Homebrew casks from ${CASKS_FILE}..."

while IFS= read -r cask; do
    if [[ -n "$cask" ]]; then
        echo "Installing cask: $cask"
        if ! brew install --cask "$cask"; then
            echo "Warning: Failed to install $cask"
        fi
    fi
done < "$CASKS_FILE"

echo "Cask installation complete!"