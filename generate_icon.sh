#!/bin/bash

# Generate macOS app icon from SVG
# Requires: rsvg-convert (install via: brew install librsvg)
# Or use ImageMagick, or convert manually in an image editor

ICON_DIR="WhitelistManager/WhitelistManager/Assets.xcassets/AppIcon.appiconset"
SVG_FILE="$ICON_DIR/icon.svg"

if [ ! -f "$SVG_FILE" ]; then
    echo "Error: SVG file not found at $SVG_FILE"
    exit 1
fi

# Check if rsvg-convert is available
if command -v rsvg-convert &> /dev/null; then
    echo "Generating app icons using rsvg-convert..."
    
    # Generate all required sizes
    rsvg-convert -w 16 -h 16 "$SVG_FILE" -o "$ICON_DIR/icon_16x16.png"
    rsvg-convert -w 32 -h 32 "$SVG_FILE" -o "$ICON_DIR/icon_16x16@2x.png"
    rsvg-convert -w 32 -h 32 "$SVG_FILE" -o "$ICON_DIR/icon_32x32.png"
    rsvg-convert -w 64 -h 64 "$SVG_FILE" -o "$ICON_DIR/icon_32x32@2x.png"
    rsvg-convert -w 128 -h 128 "$SVG_FILE" -o "$ICON_DIR/icon_128x128.png"
    rsvg-convert -w 256 -h 256 "$SVG_FILE" -o "$ICON_DIR/icon_128x128@2x.png"
    rsvg-convert -w 256 -h 256 "$SVG_FILE" -o "$ICON_DIR/icon_256x256.png"
    rsvg-convert -w 512 -h 512 "$SVG_FILE" -o "$ICON_DIR/icon_256x256@2x.png"
    rsvg-convert -w 512 -h 512 "$SVG_FILE" -o "$ICON_DIR/icon_512x512.png"
    rsvg-convert -w 1024 -h 1024 "$SVG_FILE" -o "$ICON_DIR/icon_512x512@2x.png"
    
    echo "Icons generated successfully!"
elif command -v convert &> /dev/null; then
    echo "Generating app icons using ImageMagick..."
    
    convert -background none -resize 16x16 "$SVG_FILE" "$ICON_DIR/icon_16x16.png"
    convert -background none -resize 32x32 "$SVG_FILE" "$ICON_DIR/icon_16x16@2x.png"
    convert -background none -resize 32x32 "$SVG_FILE" "$ICON_DIR/icon_32x32.png"
    convert -background none -resize 64x64 "$SVG_FILE" "$ICON_DIR/icon_32x32@2x.png"
    convert -background none -resize 128x128 "$SVG_FILE" "$ICON_DIR/icon_128x128.png"
    convert -background none -resize 256x256 "$SVG_FILE" "$ICON_DIR/icon_128x128@2x.png"
    convert -background none -resize 256x256 "$SVG_FILE" "$ICON_DIR/icon_256x256.png"
    convert -background none -resize 512x512 "$SVG_FILE" "$ICON_DIR/icon_256x256@2x.png"
    convert -background none -resize 512x512 "$SVG_FILE" "$ICON_DIR/icon_512x512.png"
    convert -background none -resize 1024x1024 "$SVG_FILE" "$ICON_DIR/icon_512x512@2x.png"
    
    echo "Icons generated successfully!"
else
    echo "Error: Neither rsvg-convert nor ImageMagick found."
    echo "Install one of them:"
    echo "  brew install librsvg    (for rsvg-convert)"
    echo "  brew install imagemagick (for convert)"
    echo ""
    echo "Or manually convert the SVG to PNG files in these sizes:"
    echo "  16x16, 32x32, 64x64, 128x128, 256x256, 512x512, 1024x1024"
    exit 1
fi


