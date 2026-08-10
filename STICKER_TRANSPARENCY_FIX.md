# Sticker Transparency Issue - Solution

## Problem
The sticker images in the hero animation are displaying as solid rectangles instead of showing transparency around the character. This is because the PNG files are using 8-bit colormap format without proper alpha channels.

### Technical Details
```
Current sticker format:
- 8-bit colormap PNG (indexed color)
- No alpha channel / transparency
- Results in solid rectangular display

Required format:
- 32-bit RGBA PNG (true color with alpha)
- Proper transparency around character
```

## Solution: Convert Stickers to Transparent PNGs

### Option 1: Using Python (Recommended)
Run this Python script to convert all sticker images:

```python
# convert_stickers_to_transparent.py
from PIL import Image
import os
from pathlib import Path

# Path to sticker images
sticker_dir = Path("assets/images/stickers")

# Color to make transparent (typically white or background color)
# RGB values - adjust if needed
TRANSPARENT_COLOR = (255, 255, 255)  # White
TOLERANCE = 10  # How similar colors need to be to be considered transparent

def convert_sticker_to_transparent(image_path):
    """Convert sticker background to transparency"""
    img = Image.open(image_path)
    
    # Convert to RGBA if not already
    if img.mode != 'RGBA':
        img = img.convert('RGBA')
    
    data = img.getdata()
    new_data = []
    
    for item in data:
        # Check if color is close to the transparent color
        r, g, b = item[0], item[1], item[2]
        
        # Calculate if color is "close enough" to transparent color
        if (abs(r - TRANSPARENT_COLOR[0]) < TOLERANCE and
            abs(g - TRANSPARENT_COLOR[1]) < TOLERANCE and
            abs(b - TRANSPARENT_COLOR[2]) < TOLERANCE):
            # Make it transparent
            new_data.append((r, g, b, 0))
        else:
            # Keep original with full opacity
            new_data.append((r, g, b, 255))
    
    img.putdata(new_data)
    img.save(image_path, 'PNG')
    print(f"✅ Converted: {image_path.name}")

# Convert all stickers
if sticker_dir.exists():
    for sticker_file in sticker_dir.glob("*.png"):
        convert_sticker_to_transparent(sticker_file)
    print("\n✅ All stickers converted to transparent!")
else:
    print(f"❌ Sticker directory not found: {sticker_dir}")
```

**How to run:**
```bash
# Install required package
pip install Pillow

# Run the conversion script
python convert_stickers_to_transparent.py
```

### Option 2: Using ImageMagick (if installed)
```bash
# Convert all PNG stickers - replace white with transparent
mogrify -background white -alpha off -alpha on -trim assets/images/stickers/*.png

# Or use this command to be more specific:
for file in assets/images/stickers/*.png; do
  convert "$file" -fuzz 10% -transparent white "$file"
done
```

### Option 3: Using Online Tool
1. Go to https://www.remove.bg/ or similar tool
2. Upload each sticker image
3. Download with transparent background
4. Replace the files in `assets/images/stickers/`

## After Conversion

Once you've converted the images, the stickers should:
- ✅ Display with transparent backgrounds
- ✅ Show only the character/icon
- ✅ Blend seamlessly with the hero card background image
- ✅ Appear as proper stickers, not rectangles

## Testing
1. Run `flutter clean`
2. Run `flutter pub get`
3. Run `flutter run`
4. Check the home screen hero card - stickers should now show with transparency

## Alternative: Using Emoji Fallback
If you prefer not to convert the images, you can enable the emoji fallback by:
1. Renaming/removing the sticker PNG files from `assets/images/stickers/`
2. The app will automatically fall back to emoji characters
3. Update the fallback in `_buildStickerImage()` to use better emojis:
   - 🙏 (praying)
   - 🎉 (celebrating)
   - 🧘 (meditating)
   - 🙏 (praying)
   - 🔔 (bell)
   - 🧍 (standing)

## Recommended Action
Convert the stickers using the Python script above - it's quick and gives you proper transparent stickers that look professional!
