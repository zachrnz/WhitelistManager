#!/usr/bin/env python3
"""
Generate macOS app icon PNG files from SVG
Uses PIL/Pillow if available, otherwise provides instructions
"""

import os
import subprocess
import sys

ICON_DIR = "WhitelistManager/WhitelistManager/Assets.xcassets/AppIcon.appiconset"
SVG_FILE = os.path.join(ICON_DIR, "icon.svg")

# Required sizes: (filename, width, height)
SIZES = [
    ("icon_16x16.png", 16, 16),
    ("icon_16x16@2x.png", 32, 32),
    ("icon_32x32.png", 32, 32),
    ("icon_32x32@2x.png", 64, 64),
    ("icon_128x128.png", 128, 128),
    ("icon_128x128@2x.png", 256, 256),
    ("icon_256x256.png", 256, 256),
    ("icon_256x256@2x.png", 512, 512),
    ("icon_512x512.png", 512, 512),
    ("icon_512x512@2x.png", 1024, 1024),
]

def generate_with_pillow():
    """Generate icons using PIL/Pillow"""
    try:
        from PIL import Image
        import cairosvg
        
        # Read SVG and convert to PNG
        svg_data = open(SVG_FILE, 'rb').read()
        
        for filename, width, height in SIZES:
            output_path = os.path.join(ICON_DIR, filename)
            png_data = cairosvg.svg2png(bytestring=svg_data, output_width=width, output_height=height)
            with open(output_path, 'wb') as f:
                f.write(png_data)
            print(f"Generated {filename}")
        
        return True
    except ImportError:
        return False

def generate_with_rsvg():
    """Generate icons using rsvg-convert"""
    if not os.path.exists('/opt/homebrew/bin/rsvg-convert') and not os.path.exists('/usr/local/bin/rsvg-convert'):
        return False
    
    rsvg = '/opt/homebrew/bin/rsvg-convert' if os.path.exists('/opt/homebrew/bin/rsvg-convert') else '/usr/local/bin/rsvg-convert'
    
    for filename, width, height in SIZES:
        output_path = os.path.join(ICON_DIR, filename)
        subprocess.run([rsvg, '-w', str(width), '-h', str(height), SVG_FILE, '-o', output_path], check=True)
        print(f"Generated {filename}")
    
    return True

def generate_with_qlmanage():
    """Generate icons using macOS qlmanage (quicklook)"""
    # Convert SVG to a temporary large PNG first
    temp_png = os.path.join(ICON_DIR, "temp_1024.png")
    
    # Try using qlmanage to convert SVG
    try:
        subprocess.run(['qlmanage', '-t', '-s', '1024', '-o', ICON_DIR, SVG_FILE], 
                      check=True, capture_output=True)
        
        # Rename the generated file
        ql_output = os.path.join(ICON_DIR, "icon.svg.png")
        if os.path.exists(ql_output):
            os.rename(ql_output, temp_png)
        else:
            return False
    except:
        return False
    
    # Use sips to resize
    try:
        for filename, width, height in SIZES:
            output_path = os.path.join(ICON_DIR, filename)
            subprocess.run(['sips', '-z', str(height), str(width), temp_png, '--out', output_path], 
                          check=True, capture_output=True)
            print(f"Generated {filename}")
        
        os.remove(temp_png)
        return True
    except:
        if os.path.exists(temp_png):
            os.remove(temp_png)
        return False

if __name__ == "__main__":
    if not os.path.exists(SVG_FILE):
        print(f"Error: SVG file not found at {SVG_FILE}")
        sys.exit(1)
    
    print("Attempting to generate app icons...")
    
    # Try different methods
    if generate_with_rsvg():
        print("\n✓ Icons generated successfully using rsvg-convert!")
    elif generate_with_qlmanage():
        print("\n✓ Icons generated successfully using macOS built-in tools!")
    elif generate_with_pillow():
        print("\n✓ Icons generated successfully using PIL/Pillow!")
    else:
        print("\n⚠ Could not generate icons automatically.")
        print("\nPlease install one of these tools:")
        print("  brew install librsvg")
        print("\nOr manually create PNG files from the SVG in these sizes:")
        for _, w, h in SIZES:
            print(f"  {w}x{h}")
        print(f"\nSVG file is at: {SVG_FILE}")
        sys.exit(1)

