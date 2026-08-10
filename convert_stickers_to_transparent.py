#!/usr/bin/env python3
"""
Sticker Transparency Converter
Converts sticker images with solid backgrounds to transparent PNGs
"""

from PIL import Image
import os
from pathlib import Path

# Configuration
STICKER_DIR = Path("assets/images/stickers")
TRANSPARENT_COLOR = (255, 255, 255)  # White (RGB)
TOLERANCE = 15  # Pixel similarity threshold (0-255)

def convert_sticker_to_transparent(image_path):
    """
    Convert sticker background to transparency.
    Replaces pixels matching TRANSPARENT_COLOR (within TOLERANCE) with transparent.
    """
    try:
        print(f"Processing: {image_path.name}...", end=" ")
        img = Image.open(image_path)

        # Store original mode for reference
        original_mode = img.mode

        # Convert to RGBA if not already
        if img.mode != 'RGBA':
            img = img.convert('RGBA')

        # Get image data
        data = img.getdata()
        new_data = []

        # Process each pixel
        for pixel in data:
            r, g, b = pixel[0], pixel[1], pixel[2]
            alpha = pixel[3] if len(pixel) == 4 else 255

            # Check if pixel color is close to transparent color
            if (abs(r - TRANSPARENT_COLOR[0]) <= TOLERANCE and
                abs(g - TRANSPARENT_COLOR[1]) <= TOLERANCE and
                abs(b - TRANSPARENT_COLOR[2]) <= TOLERANCE):
                # Make it transparent
                new_data.append((r, g, b, 0))
            else:
                # Keep original color with full opacity
                new_data.append((r, g, b, 255))

        # Update image with new data
        img.putdata(new_data)

        # Save as PNG with transparency
        img.save(image_path, 'PNG', optimize=False)
        print("✅ Done")
        return True

    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def main():
    print("=" * 60)
    print("🎨 Sticker Transparency Converter")
    print("=" * 60)

    # Check if directory exists
    if not STICKER_DIR.exists():
        print(f"❌ Error: Sticker directory not found: {STICKER_DIR}")
        print("   Please run this script from the project root directory")
        return False

    # Find all PNG files
    sticker_files = list(STICKER_DIR.glob("*.png"))

    if not sticker_files:
        print(f"❌ No PNG files found in {STICKER_DIR}")
        return False

    print(f"\nFound {len(sticker_files)} sticker(s) to process")
    print(f"Transparent color: RGB{TRANSPARENT_COLOR}")
    print(f"Tolerance: {TOLERANCE}\n")

    # Convert each sticker
    successful = 0
    for sticker_file in sorted(sticker_files):
        if convert_sticker_to_transparent(sticker_file):
            successful += 1

    # Summary
    print("\n" + "=" * 60)
    print(f"Conversion Complete: {successful}/{len(sticker_files)} successful")
    print("=" * 60)

    if successful == len(sticker_files):
        print("\n✅ All stickers converted successfully!")
        print("\nNext steps:")
        print("1. Run: flutter clean")
        print("2. Run: flutter pub get")
        print("3. Run: flutter run")
        print("\nYour stickers should now display with transparent backgrounds!")
        return True
    else:
        print(f"\n⚠️  {len(sticker_files) - successful} sticker(s) failed to convert")
        return False

if __name__ == "__main__":
    # Check if PIL is installed
    try:
        from PIL import Image
        main()
    except ImportError:
        print("❌ Error: Pillow library is required")
        print("\nInstall it with:")
        print("  pip install Pillow")
