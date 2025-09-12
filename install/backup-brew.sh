#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Backing up Homebrew packages..."

echo "Exporting formulas to ${SCRIPT_DIR}/formulas.txt"
brew list --formula > "${SCRIPT_DIR}/formulas.txt"

echo "Exporting casks to ${SCRIPT_DIR}/casks.txt"
brew list --cask > "${SCRIPT_DIR}/casks.txt"

echo "Backup complete!"
echo "Formulas: $(wc -l < "${SCRIPT_DIR}/formulas.txt") packages"
echo "Casks: $(wc -l < "${SCRIPT_DIR}/casks.txt") packages"