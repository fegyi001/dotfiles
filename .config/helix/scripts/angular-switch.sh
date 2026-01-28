#!/usr/bin/env sh
# Angular file switcher for Helix editor
# Usage: angular-switch.sh <current_file> <target_extension>

current_file="$1"
target_ext="$2"

if [ -z "$current_file" ] || [ -z "$target_ext" ]; then
  exit 1
fi

# Extract base name and type using sed
base_name=""
file_type=""

case "$current_file" in
  *.component.html)
    base_name="${current_file%.component.html}"
    file_type="component"
    ;;
  *.component.ts)
    base_name="${current_file%.component.ts}"
    file_type="component"
    ;;
  *.component.scss)
    base_name="${current_file%.component.scss}"
    file_type="component"
    ;;
  *.component.spec.ts)
    base_name="${current_file%.component.spec.ts}"
    file_type="component"
    ;;
  *.service.ts)
    base_name="${current_file%.service.ts}"
    file_type="service"
    ;;
  *.service.spec.ts)
    base_name="${current_file%.service.spec.ts}"
    file_type="service"
    ;;
  *)
    exit 1
    ;;
esac

# Build target file path
target_file="${base_name}.${file_type}.${target_ext}"

if [ -f "$target_file" ]; then
  echo "$target_file"
else
  exit 1
fi
