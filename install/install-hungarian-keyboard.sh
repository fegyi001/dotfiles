#!/bin/bash
# Install Hungarian QWERTZ variant that accounts for keyd's Y/Z swap
# This variant has Y and Z pre-swapped, so keyd's swap will put them in correct positions

echo "Installing Hungarian QWERTZ variant with pre-swapped Y/Z for keyd..."

# Create backup
sudo cp /usr/share/X11/xkb/symbols/hu /usr/share/X11/xkb/symbols/hu.backup.$(date +%s)

# Append the custom variant
sudo tee -a /usr/share/X11/xkb/symbols/hu > /dev/null << 'EOF'

// Hungarian QWERTZ but with Y/Z pre-swapped to counteract keyd's swap
// keyd swaps Y<->Z at hardware level for all layouts
// We define Y in top, Z in bottom (opposite of QWERTZ)
// After keyd swaps: Z in top, Y in bottom (correct QWERTZ!)
partial alphanumeric_keys
xkb_symbols "qwertz_keyd" {
    include "latin"
    include "hu(def_102)"
    include "kpdl(comma)"
    include "hu(def_dead)"
    include "hu(def_common)"
    include "level3(ralt_switch)"
    
    name[Group1] = "Hungarian (QWERTZ for keyd)";

    // Pre-swap Y and Z (opposite of normal QWERTZ)
    // keyd will swap them back to correct QWERTZ positions
    key <AD06>  { [            y,            Y,           endash                   ] };
    key <AB01>  { [            z,            Z,           greater                  ] };
};
EOF

# Register in XKB rules
sudo sed -i '/qwertz_keyd.*hu:/d' /usr/share/X11/xkb/rules/evdev.lst 2>/dev/null || true
sudo sed -i '/qwertz_keyd.*hu:/d' /usr/share/X11/xkb/rules/base.lst 2>/dev/null || true

echo "  qwertz_keyd     hu: Hungarian (QWERTZ for keyd)" | sudo tee -a /usr/share/X11/xkb/rules/evdev.lst > /dev/null
echo "  qwertz_keyd     hu: Hungarian (QWERTZ for keyd)" | sudo tee -a /usr/share/X11/xkb/rules/base.lst > /dev/null

echo ""
echo "Installation complete!"
echo ""
echo "How it works:"
echo "  1. XKB defines Y in top row, Z in bottom (pre-swapped)"
echo "  2. keyd swaps Y<->Z at hardware level"
echo "  3. Result: Z in top row, Y in bottom (correct QWERTZ!)"
echo ""
echo "Now update your Hyprland config to use this variant and reload."
