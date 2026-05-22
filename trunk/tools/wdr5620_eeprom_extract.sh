#!/bin/bash
# WDR5620 Ver 9.0 EEPROM Extraction Tool
# Extracts WiFi calibration data from stock firmware for Padavan cross-flash

if [ -z "$1" ]; then
    echo "Usage: $0 <stock_firmware.bin> [output_dir]"
    echo ""
    echo "Extracts EEPROM data from WDR5620 stock firmware for Padavan cross-flash."
    echo "The extracted files should be written to the Padavan Factory partition (0x40000)."
    exit 1
fi

STOCK_FW="$1"
OUTPUT_DIR="${2:-.}"
FW_SIZE=$(stat -f%z "$STOCK_FW" 2>/dev/null || stat -c%s "$STOCK_FW" 2>/dev/null)

if [ "$FW_SIZE" -ne 8388608 ]; then
    echo "Warning: Expected 8MB (8388608 bytes) firmware, got $FW_SIZE bytes"
fi

mkdir -p "$OUTPUT_DIR"

# WDR5620 Ver 9.0 EEPROM offsets (from stock TP-Link firmware)
OFFSET_2G_EEPROM=0x1E000
OFFSET_5G_EEPROM=0x1F000
OFFSET_MAC=0x1D80D

# Padavan Factory partition offset
PADAVAN_FACTORY_OFFSET=0x40000

echo "=== WDR5620 EEPROM Extraction ==="
echo "Stock firmware: $STOCK_FW"
echo "Output directory: $OUTPUT_DIR"
echo ""

# Extract 2.4G EEPROM (4KB)
echo "Extracting 2.4G EEPROM from offset $OFFSET_2G_EEPROM..."
dd if="$STOCK_FW" of="$OUTPUT_DIR/eeprom_2g.bin" bs=1 skip=$((OFFSET_2G_EEPROM)) count=4096 2>/dev/null
echo "  -> $OUTPUT_DIR/eeprom_2g.bin (4KB)"

# Extract 5G EEPROM (4KB)
echo "Extracting 5G EEPROM from offset $OFFSET_5G_EEPROM..."
dd if="$STOCK_FW" of="$OUTPUT_DIR/eeprom_5g.bin" bs=1 skip=$((OFFSET_5G_EEPROM)) count=4096 2>/dev/null
echo "  -> $OUTPUT_DIR/eeprom_5g.bin (4KB)"

# Extract MAC address (6 bytes)
echo "Extracting MAC address from offset $OFFSET_MAC..."
dd if="$STOCK_FW" of="$OUTPUT_DIR/mac.bin" bs=1 skip=$((OFFSET_MAC)) count=6 2>/dev/null
MAC_HEX=$(xxd -p "$OUTPUT_DIR/mac.bin" | head -1)
echo "  -> MAC: ${MAC_HEX:0:2}:${MAC_HEX:2:2}:${MAC_HEX:4:2}:${MAC_HEX:6:2}:${MAC_HEX:8:2}:${MAC_HEX:10:2}"

# Extract full Factory partition for reference (64KB at 0x40000)
echo ""
echo "Extracting Padavan Factory partition area (0x40000-0x4FFFF)..."
dd if="$STOCK_FW" of="$OUTPUT_DIR/factory_padavan.bin" bs=1 skip=$((PADAVAN_FACTORY_OFFSET)) count=65536 2>/dev/null
echo "  -> $OUTPUT_DIR/factory_padavan.bin (64KB)"

echo ""
echo "=== Cross-flash Instructions ==="
echo "1. Flash Padavan firmware to router"
echo "2. After flashing, write EEPROM data to Factory partition:"
echo "   mtd_write write $OUTPUT_DIR/eeprom_2g.bin Factory  # At offset 0x0 in Factory"
echo "   # OR use programmer to write at flash offset 0x40000"
echo ""
echo "Note: The WDR5620 stock EEPROM is at 0x1E000/0x1F000, but Padavan expects"
echo "it at 0x40000 (Factory partition). You may need a programmer (CH341A) to"
echo "properly transplant the EEPROM data after flashing Padavan."
