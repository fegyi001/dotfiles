#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FORMULAS_FILE="${SCRIPT_DIR}/formulas.txt"

if [[ ! -f "$FORMULAS_FILE" ]]; then
    echo "Error: ${FORMULAS_FILE} not found!"
    echo "Run backup-brew.sh first to generate the formulas list."
    exit 1
fi

echo "Installing Homebrew formulas from ${FORMULAS_FILE}..."

while IFS= read -r formula; do
    if [[ -n "$formula" ]]; then
        echo "Installing formula: $formula"
        if ! brew install "$formula"; then
            echo "Warning: Failed to install $formula"
        fi
    fi
done < "$FORMULAS_FILE"

echo "Formula installation complete!"