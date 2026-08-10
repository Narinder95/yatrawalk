# YatraWalk PWA - Quick Start

## 🚀 5-Minute Setup

### Step 1: Enable Flutter Web (if not already)
```bash
flutter config --enable-web
```

### Step 2: Build Web
```bash
flutter build web --release
```

### Step 3: Test Locally
```bash
cd build/web
python -m http.server 8000
```
Open: `http://localhost:8000`

### Step 4: Verify PWA
- Open DevTools (F12)
- Go to Application tab
- Check "Manifest" - should show app details
- Check "Service Workers" - should say "activated and running"
- Try offline mode (Network → Offline) - should still load

### Step 5: Deploy
```bash
# Option A: Firebase (recommended)
npm install -g firebase-tools
firebase login
firebase init hosting  # Select build/web as public directory
firebase deploy --only hosting

# Option B: Netlify
npm install -g netlify-cli
netlify deploy --prod --dir=build/web
```

## 📱 Testing on Devices

### iOS (Safari)
1. Open app URL in Safari
2. Tap Share → Add to Home Screen
3. Name: "YatraWalk" → Add
4. App appears on home screen, opens fullscreen

### Android (Chrome)
1. Open app URL in Chrome
2. Chrome shows "Install" prompt
3. Tap Install
4. App appears on home screen

### Desktop (Chrome)
1. Open in Chrome
2. Click install icon (address bar)
3. Install as desktop app

## 🔧 Key Files

| File | Purpose |
|------|---------|
| `web/index.html` | PWA metadata, service worker registration |
| `web/manifest.json` | App manifest (name, icons, colors) |
| `web/sw.js` | Service worker (caching, offline) |
| `lib/services/pwa_service.dart` | PWA features in Dart |
| `PWA_SETUP.md` | Detailed setup guide |
| `PWA_INTEGRATION.md` | Code integration examples |

## ⚙️ Configuration

### Change App Name
`web/manifest.json`:
```json
{
    "name": "Your App Name",
    "short_name": "AppName"
}
```

### Change Theme Color
`web/index.html` & `web/manifest.json`:
```html
<meta name="theme-color" content="#FF8C00">
```
```json
{
    "theme_color": "#FF8C00"
}
```

### Update Icons
Replace files in `web/icons/`:
- `Icon-192.png` (192x192)
- `Icon-512.png` (512x512)
- `Icon-maskable-192.png` (192x192, maskable)
- `Icon-maskable-512.png` (512x512, maskable)

## 📊 Status Check

```bash
# Build status
flutter build web --release

# Check if web folder exists
ls -la web/

# Serve and test
cd build/web && python -m http.server 8000

# Check deployed site
curl https://your-app.web.app -v
```

## 🐛 Common Issues

| Issue | Fix |
|-------|-----|
| SW not updating | Clear cache, increment `CACHE_NAME` in `sw.js` |
| Firebase not working | Check `firebase_options.dart` web config |
| Icons missing | Ensure they exist in `web/icons/` |
| Won't install on iOS | Must be HTTPS, use Safari |
| App slow on load | Check network tab, optimize assets |

## 📈 Performance Tips

1. **Minify code**: `flutter build web --release` (automatic)
2. **Cache assets**: Service worker handles this automatically
3. **Lazy load images**: Use `Image.network` with caching
4. **Monitor performance**: Use DevTools → Performance tab

## 🔐 Security

- ✅ Service worker validates Firebase requests
- ✅ Offline API calls fail gracefully
- ✅ HTTPS enforced (most platforms require it)
- ✅ CSP headers recommended on server

Add to your hosting config:
```
X-Content-Type-Options: nosniff
X-Frame-Options: SAMEORIGIN
X-XSS-Protection: 1; mode=block
```

## 📦 Deployment Options

### Firebase Hosting (⭐ Recommended)
- ✅ Free HTTPS
- ✅ Global CDN
- ✅ Built-in analytics
- ✅ Easy deploy: `firebase deploy --only hosting`
- Cost: Free tier or pay per use

### Netlify
- ✅ Simple deployment
- ✅ Automatic deploys from git
- Cost: Free or pro

### Vercel
- ✅ Optimized for web apps
- ✅ Auto-scaling
- Cost: Free or pro

### Traditional Hosting
- ✅ Full control
- Requires: Configure for SPA (all routes → index.html)
- Example nginx config in `PWA_SETUP.md`

## 🎯 Next Steps

1. **Build**: `flutter build web --release`
2. **Test**: Serve locally and test features
3. **Fix**: Address any iOS/offline issues
4. **Deploy**: Push to hosting (Firebase recommended)
5. **Share**: Send URL to iOS users
6. **Monitor**: Check analytics and error logs

## 📞 Support

- [Flutter Web Docs](https://docs.flutter.dev/platform-integration/web)
- [PWA Checklist](https://web.dev/pwa-checklist)
- [Service Workers](https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API)
- [Firebase Hosting](https://firebase.google.com/docs/hosting)

## 💾 Useful Commands

```bash
# Build web
flutter build web --release

# Build web (development with hot reload)
flutter run -d chrome

# Clean build
flutter clean && flutter build web --release

# Serve locally
cd build/web && python -m http.server 8000

# Check build size
flutter build web --release --verbose

# Update service worker cache version
# Edit: web/sw.js → change CACHE_NAME = 'yatrawalk-vX'

# Deploy to Firebase
firebase deploy --only hosting

# Check deployment
firebase hosting:list
```

## ✅ Launch Checklist

- [ ] App builds without errors
- [ ] Service worker is active
- [ ] Icons display correctly
- [ ] Manifest.json is valid
- [ ] App works offline
- [ ] Firebase sync works
- [ ] Looks good on mobile (375px minimum)
- [ ] Tested on iOS Safari
- [ ] Tested on Android Chrome
- [ ] Deployed to hosting
- [ ] URL works from multiple devices
- [ ] Analytics tracking enabled
- [ ] No console errors in production

---

**Status**: Ready to build and deploy! 🎉

Run `flutter build web --release` to get started.
