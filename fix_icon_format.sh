#!/bin/bash

# Convert JPG icons to PNG format for proper macOS app icon support
# macOS app icons should be PNG with proper alpha channels

ICON_DIR="WhitelistManager/WhitelistManager/Assets.xcassets/AppIcon.appiconset"
SOURCE_IMAGE="$ICON_DIR/G03.jpg"

if [ ! -f "$SOURCE_IMAGE" ]; then
    echo "Error: Source image not found at $SOURCE_IMAGE"
    exit 1
fi

echo "Converting app icons from JPG to PNG format..."

# Generate all required sizes as PNG files
# Format: sips -z height width source --out destination

sips -s format png -z 16 16 "$SOURCE_IMAGE" --out "$ICON_DIR/icon_16x16.png" 2>/dev/null && echo "✓ Generated icon_16x16.png"
sips -s format png -z 32 32 "$SOURCE_IMAGE" --out "$ICON_DIR/icon_16x16@2x.png" 2>/dev/null && echo "✓ Generated icon_16x16@2x.png"
sips -s format png -z 32 32 "$SOURCE_IMAGE" --out "$ICON_DIR/icon_32x32.png" 2>/dev/null && echo "✓ Generated icon_32x32.png"
sips -s format png -z 64 64 "$SOURCE_IMAGE" --out "$ICON_DIR/icon_32x32@2x.png" 2>/dev/null && echo "✓ Generated icon_32x32@2x.png"
sips -s format png -z 128 128 "$SOURCE_IMAGE" --out "$ICON_DIR/icon_128x128.png" 2>/dev/null && echo "✓ Generated icon_128x128.png"
sips -s format png -z 256 256 "$SOURCE_IMAGE" --out "$ICON_DIR/icon_128x128@2x.png" 2>/dev/null && echo "✓ Generated icon_128x128@2x.png"
sips -s format png -z 256 256 "$SOURCE_IMAGE" --out "$ICON_DIR/icon_256x256.png" 2>/dev/null && echo "✓ Generated icon_256x256.png"
sips -s format png -z 512 512 "$SOURCE_IMAGE" --out "$ICON_DIR/icon_256x256@2x.png" 2>/dev/null && echo "✓ Generated icon_256x256@2x.png"
sips -s format png -z 512 512 "$SOURCE_IMAGE" --out "$ICON_DIR/icon_512x512.png" 2>/dev/null && echo "✓ Generated icon_512x512.png"
sips -s format png -z 1024 1024 "$SOURCE_IMAGE" --out "$ICON_DIR/icon_512x512@2x.png" 2>/dev/null && echo "✓ Generated icon_512x512@2x.png"

echo ""
echo "✓ All icons converted to PNG format!"
echo "Updating Contents.json..."


