# YatraWalk PWA Performance Optimization

## Problem Analysis

**Current Performance Issues:**
- Load time: Slow due to large assets
- Build size: ~30MB+ (unoptimized images)
- Main bottlenecks:
  - PNG images: 2-2.6MB each (15 large images = 30MB+)
  - CanvasKit WASM: ~25MB (Flutter's rendering engine)
  - Video file: 1.3MB (splash.mp4)

## Solutions

### 1. Image Optimization (HIGHEST PRIORITY)

**Current image sizes:**
```
2.6M background_5.png
2.6M background_2.png
2.4M golden_sunset.png
2.2M background_4.png
2.2M background_3.png
2.2M background_1.png
1.5M yatra_logo.png
... and more
```

**Target: Reduce by 60-80%**

#### Option A: Use Online Image Compressor (Easiest)
1. Go to: https://tinypng.com or https://compressor.io
2. Upload each PNG
3. Download compressed version
4. Replace files in `assets/images/`
5. Expected size reduction: 60-80%

#### Option B: Use ImageMagick (Command Line)
```bash
# Install ImageMagick if not installed
# Then optimize images:

magick convert background_1.png -quality 85 -strip background_1.png
magick convert background_2.png -quality 85 -strip background_2.png
# ... repeat for all images

# Or batch convert all PNGs:
for file in assets/images/**/*.png; do
  magick convert "$file" -quality 85 -strip "$file"
done
```

#### Option C: Use FFmpeg (For multiple formats)
```bash
# Convert to WebP (smaller file size)
ffmpeg -i background_1.png -q:w 80 background_1.webp

# Convert video to smaller format
ffmpeg -i assets/videos/splash.mp4 -c:v libvpx-vp9 -b:v 0 -crf 30 splash.webp
```

#### Option D: Recommended - ImageMagick + WebP Conversion
```bash
# 1. Install ImageMagick and FFmpeg
# 2. Optimize and convert all images to WebP

# For PNGs (reduce quality to 80-85%):
for file in assets/images/**/*.png; do
  filename=$(basename "$file" .png)
  dir=$(dirname "$file")
  magick convert "$file" -quality 85 -strip "$dir/${filename}.webp"
done

# Keep originals but also support PNG fallback
# Result: ~500KB per image instead of 2MB
```

### 2. Update Image References (After Optimization)

If using WebP format, update Flutter code to use WebP:

```dart
// Replace PNG image calls with WebP
// Before:
Image.asset('assets/images/hero-backgrounds/background_1.png')

// After (if server supports WebP):
Image.asset('assets/images/hero-backgrounds/background_1.webp')

// Or use conditional:
Image.asset(
  kIsWeb ? 'assets/images/hero-backgrounds/background_1.webp' 
         : 'assets/images/hero-backgrounds/background_1.png'
)
```

### 3. Video Optimization

Current: `splash.mp4` = 1.3MB

**Optimize:**
```bash
# Reduce quality and resolution
ffmpeg -i assets/videos/splash.mp4 -vf scale=1280:720 -b:v 500k splash.mp4

# Or convert to WebM (smaller):
ffmpeg -i assets/videos/splash.mp4 -c:v libvpx -crf 30 splash.webm

# Result: 200-400KB instead of 1.3MB
```

**Result:** 70-80% size reduction

### 4. Lazy Load Images

Update Flutter code to lazy-load background images:

```dart
class BackgroundImage extends StatelessWidget {
  final String imagePath;
  
  const BackgroundImage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      // Cache network images efficiently
      cacheHeight: MediaQuery.of(context).size.height.toInt(),
      cacheWidth: MediaQuery.of(context).size.width.toInt(),
    );
  }
}
```

### 5. Rebuild Web with Optimization Flags

After optimizing images:

```bash
# Clean previous build
flutter clean

# Rebuild with optimizations
flutter build web --release

# Check new size
# Should be: ~50-60% smaller
```

## Expected Results After Optimization

| Item | Before | After | Reduction |
|------|--------|-------|-----------|
| Images | ~30MB | ~6-9MB | 70-80% |
| Video | 1.3MB | 0.3-0.4MB | 70% |
| Total build | ~57MB | ~15-20MB | 65-70% |
| Load time | 5-10s | 2-3s | 50-60% |
| Cache size | 30MB+ | 5-8MB | 75-80% |

## Implementation Steps

### Step 1: Backup Original Assets
```bash
# Create backup
copy assets assets_backup
```

### Step 2: Compress Images
- Use TinyPNG.com (easiest, no setup required)
- Or install ImageMagick and compress locally

### Step 3: Rebuild Web
```bash
flutter clean
flutter build web --release
```

### Step 4: Re-deploy
```bash
firebase deploy --only hosting
```

### Step 5: Test Performance
- Clear browser cache (Ctrl+Shift+Delete)
- Test load time (should be 2-3x faster)
- Check network tab in DevTools
- Test on mobile (should be much faster)

## Alternative: Serve Images from CDN

Instead of bundling images, serve from a CDN:

```dart
// Use network images instead of assets
Image.network(
  'https://your-cdn.com/images/background_1.webp',
  fit: BoxFit.cover,
  cacheManager: DefaultCacheManager(), // Cache locally
)
```

Benefits:
- ✅ Smaller app bundle
- ✅ CDN optimization and compression
- ✅ Faster updates (change images without rebuilding)
- ✅ Better caching

## Quick Wins (Do These First)

1. **Delete duplicate "New" folders** in assets/images (~1-2MB saved)
2. **Compress PNGs to WebP** using TinyPNG (5 min, 70% reduction)
3. **Reduce video quality** with FFmpeg (5 min, 70% reduction)
4. **Rebuild and redeploy** (5 min)

**Total time: ~15 minutes | Result: 60% faster app**

## Performance After Optimization

With optimized images:
- First load: 2-3 seconds
- Cached load: < 500ms
- Responsive on 3G
- Installable on home screen (PWA)
- Smooth offline experience

## Monitoring Performance

After deployment, check:

```javascript
// In browser console
// Check load time
performance.timing.loadEventEnd - performance.timing.navigationStart

// Check cache size
navigator.storage.estimate()
  .then(estimate => console.log(`Cache: ${estimate.usage / 1024 / 1024} MB`))

// Check assets being downloaded
// DevTools → Network tab → filter by image type
```

## Tools Needed

- **TinyPNG** (no install): https://tinypng.com
- **ImageMagick** (command line): `choco install imagemagick` (Windows)
- **FFmpeg** (video): `choco install ffmpeg` (Windows)
- **Online tool**: https://compressor.io

## Next Steps

1. [ ] Backup assets: `copy assets assets_backup`
2. [ ] Compress images (TinyPNG or ImageMagick)
3. [ ] Compress video (FFmpeg or online tool)
4. [ ] Rebuild: `flutter clean && flutter build web --release`
5. [ ] Deploy: `firebase deploy --only hosting`
6. [ ] Test: Visit https://yatrawalk-abd84.web.app and check DevTools

**Expected improvement: 60% faster load time** ⚡
