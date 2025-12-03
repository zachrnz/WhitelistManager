#!/bin/bash

# Generate all macOS app icon sizes from the shield icon
# Uses macOS built-in sips command

ICON_DIR="WhitelistManager/WhitelistManager/Assets.xcassets/AppIcon.appiconset"
SOURCE_IMAGE="$ICON_DIR/G03.jpg"

if [ ! -f "$SOURCE_IMAGE" ]; then
    echo "Error: Source image not found at $SOURCE_IMAGE"
    exit 1
fi

echo "Generating app icons from shield image..."

# Generate all required sizes
# Format: sips -z height width source --out destination

sips -z 16 16 "$SOURCE_IMAGE" --out "$ICON_DIR/G03 9.jpg" 2>/dev/null && echo "✓ Generated 16x16"
sips -z 32 32 "$SOURCE_IMAGE" --out "$ICON_DIR/G03 8.jpg" 2>/dev/null && echo "✓ Generated 32x32 (16x16@2x)"
sips -z 32 32 "$SOURCE_IMAGE" --out "$ICON_DIR/G03 7.jpg" 2>/dev/null && echo "✓ Generated 32x32"
sips -z 64 64 "$SOURCE_IMAGE" --out "$ICON_DIR/G03 6.jpg" 2>/dev/null && echo "✓ Generated 64x64 (32x32@2x)"
sips -z 128 128 "$SOURCE_IMAGE" --out "$ICON_DIR/G03 5.jpg" 2>/dev/null && echo "✓ Generated 128x128"
sips -z 256 256 "$SOURCE_IMAGE" --out "$ICON_DIR/G03 4.jpg" 2>/dev/null && echo "✓ Generated 256x256 (128x128@2x)"
sips -z 256 256 "$SOURCE_IMAGE" --out "$ICON_DIR/G03 3.jpg" 2>/dev/null && echo "✓ Generated 256x256"
sips -z 512 512 "$SOURCE_IMAGE" --out "$ICON_DIR/G03 2.jpg" 2>/dev/null && echo "✓ Generated 512x512 (256x256@2x)"
sips -z 512 512 "$SOURCE_IMAGE" --out "$ICON_DIR/G03 1.jpg" 2>/dev/null && echo "✓ Generated 512x512"
sips -z 1024 1024 "$SOURCE_IMAGE" --out "$ICON_DIR/G03.jpg" 2>/dev/null && echo "✓ Generated 1024x1024 (512x512@2x)"

echo ""
echo "✓ All icon sizes generated successfully!"
echo "The icons are ready to use in Xcode."

