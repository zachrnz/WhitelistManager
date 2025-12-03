# App Icon Setup Instructions

The app icon is a black circle with a white checkmark. To set it up:

## Option 1: Use Xcode's Icon Editor (Easiest)

1. Open the project in Xcode
2. Navigate to `Assets.xcassets` → `AppIcon`
3. Drag the `icon.svg` file onto the AppIcon editor
4. Xcode will automatically generate all required sizes

## Option 2: Generate Icons Automatically

Install librsvg and run the generation script:

```bash
brew install librsvg
./generate_icon.sh
```

Or use the Python script:

```bash
pip3 install pillow cairosvg
python3 generate_icon.py
```

## Option 3: Manual Conversion

1. Open `icon.svg` in any image editor (Preview, Photoshop, etc.)
2. Export as PNG in these sizes:
   - 16x16 → `icon_16x16.png`
   - 32x32 → `icon_16x16@2x.png`
   - 32x32 → `icon_32x32.png`
   - 64x64 → `icon_32x32@2x.png`
   - 128x128 → `icon_128x128.png`
   - 256x256 → `icon_128x128@2x.png`
   - 256x256 → `icon_256x256.png`
   - 512x512 → `icon_256x256@2x.png`
   - 512x512 → `icon_512x512.png`
   - 1024x1024 → `icon_512x512@2x.png`

3. Place all PNG files in: `WhitelistManager/WhitelistManager/Assets.xcassets/AppIcon.appiconset/`

## Option 4: Online Converter

Use an online SVG to PNG converter (like cloudconvert.com) to generate all sizes, then place them in the AppIcon.appiconset folder.

