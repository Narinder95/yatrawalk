# YatraWalk PWA Setup Guide

## Overview
This guide walks you through building and deploying YatraWalk as a Progressive Web App (PWA) for iOS and Android web users.

## Prerequisites
- Flutter SDK (3.5.0+)
- Web platform enabled: `flutter config --enable-web`
- Node.js (optional, for local testing)

## 1. Build Flutter Web

### Development Build (with hot reload)
```bash
flutter run -d chrome
```

### Production Build
```bash
flutter build web --release
```

Output will be in: `build/web/`

## 2. Local Testing

### Using Python (simplest)
```bash
cd build/web
python -m http.server 8000
```
Then open: `http://localhost:8000`

### Using Node.js with http-server
```bash
npm install -g http-server
cd build/web
http-server
```

### Using Docker (recommended for production simulation)
```bash
cd build/web
docker run -d -p 8080:8080 -v $(pwd):/usr/share/nginx/html nginx:alpine
```
Then open: `http://localhost:8080`

## 3. Testing PWA Features

### Desktop (Chrome DevTools)
1. Open the app in Chrome
2. Press F12 → Application tab
3. Check:
   - **Manifest**: Should show app details (name, icons, theme color)
   - **Service Worker**: Should show "activated and running"
   - **Cache Storage**: Should show cached assets
4. Test offline: DevTools → Network → Offline, refresh page
5. Install: Click the install icon (address bar) or Settings → Install app

### iOS (PWA on Safari)
1. Open the web app in Safari
2. Tap Share → Add to Home Screen
3. Name it "YatraWalk" and add
4. The app will open in fullscreen (standalone mode)
5. Offline testing:
   - Open the app
   - Enable Airplane Mode
   - The app should still load (static assets cached)
   - API calls will fail gracefully (app handles offline state)

### Android (Chrome PWA)
1. Open in Chrome
2. Chrome should show install prompt
3. Accept to install as PWA
4. App launches in standalone mode
5. Full offline support with service worker

## 4. PWA Features Implemented

✅ **Manifest**: Full app metadata (name, icons, colors, shortcuts)
✅ **Service Worker**: 
  - Static asset caching
  - Offline fallback
  - Network-first for APIs (Firebase)
  - Cache-first for app assets
✅ **iOS Support**:
  - Apple touch icons
  - Status bar styling
  - Safe area support (viewport-fit=cover)
✅ **Installability**:
  - Standalone display mode
  - Custom theme color (#FF8C00 - Orange)
  - Proper icons (192px, 512px, maskable)

## 5. iOS Limitations & Workarounds

### Known Limitations
- **No background sync**: iOS PWA doesn't support background sync API
- **No push notifications**: Limited push support on iOS PWA
- **No Home Screen badge**: Badge API not supported
- **Limited storage**: ~50MB limit (vs Android's more generous limits)
- **No Web App Installs**: iOS PWA must be manually added (no install prompt)

### Workarounds
1. **Data Sync**: Use localStorage + cloud sync on app open
2. **Notifications**: User must have app in foreground
3. **Storage**: Implement efficient caching, use Firestore for cloud backup
4. **Updates**: Manual refresh or check on app launch

## 6. Firebase Configuration

Your app uses Firebase - verify web setup:

```dart
// lib/firebase_options.dart should include web config
// Check that your firebase_options.dart has:
// - Web API key
// - Project ID
// - Auth domain
```

### Firebase Security Rules for Web
```
// firestore.rules - Update to allow web clients
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow authenticated users to read/write their data
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    // Add other collection rules as needed
  }
}
```

## 7. Deployment Options

### Option A: Firebase Hosting (Recommended)
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase hosting
firebase init hosting

# Select:
# - Project: your Firebase project
# - Public directory: build/web
# - Single-page app: Yes

# Deploy
firebase deploy --only hosting
```

Your PWA will be available at: `https://your-project.web.app`

### Option B: Netlify
```bash
# Install Netlify CLI
npm install -g netlify-cli

# Deploy
netlify deploy --prod --dir=build/web
```

### Option C: Vercel
```bash
# Install Vercel CLI
npm install -g vercel

# Deploy
vercel --prod build/web
```

### Option D: Traditional Hosting (nginx, Apache, etc.)
```bash
# Build
flutter build web --release

# Upload build/web/ contents to your server
# Ensure your server is configured for SPA (all routes → index.html)

# nginx example:
server {
    listen 80;
    server_name yourdomain.com;
    root /var/www/yatrawalk/build/web;
    
    location / {
        try_files $uri /index.html;
    }
    
    # Cache static assets
    location ~* \.(js|css|png|jpg|gif|ico|svg|woff|woff2)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

## 8. Distribution to iOS Users

### Method 1: Home Screen Shortcut (Official PWA)
Users open Safari → Share → Add to Home Screen
- Most standard method
- iOS treats it as a web app (not native)
- Full screen, custom status bar

### Method 2: Share QR Code or Link
Create a landing page with install instructions:
```
1. Open this link in Safari
2. Tap Share
3. Select "Add to Home Screen"
4. Name it and add
```

### Method 3: Combination with Native App
- Promote web version as companion/fallback
- Native app for full features
- Web version for discovery/light usage

## 9. Performance Optimization

### Cache Busting
Service worker uses cache versioning. Update version when deploying:
```javascript
const CACHE_NAME = 'yatrawalk-v2'; // Increment version number
```

### Asset Optimization
- Flutter build automatically minifies
- Images: ensure optimized in `assets/`
- Consider lazy loading for images

### First Load Optimization
- Load time: typically < 3 seconds
- Service worker caches on first load
- Second load: < 1 second (cached)

## 10. Monitoring & Analytics

### Add Web Analytics
```dart
// In pubspec.yaml, add Google Analytics (if not already present)
firebase_analytics: ^10.0.0
```

### Track PWA Events
```dart
// Track app installs
analytics.logEvent(
  name: 'pwa_installed',
  parameters: {'platform': 'web'},
);

// Track offline usage
analytics.logEvent(
  name: 'offline_usage',
  parameters: {'duration': duration},
);
```

## 11. Testing Checklist

- [ ] Web build generates successfully
- [ ] App loads in browser
- [ ] Service worker installs
- [ ] App works offline (static assets)
- [ ] Icons display correctly
- [ ] Manifest loads properly
- [ ] Installation works (Android Chrome)
- [ ] Add to Home Screen works (iOS Safari)
- [ ] Responsive on mobile (375px width minimum)
- [ ] Fullscreen mode works
- [ ] Status bar style correct
- [ ] Firebase auth/data sync works
- [ ] Theme color displays (orange #FF8C00)

## 12. iOS-Specific Testing

Test on actual iOS devices:
1. iPhone with Safari
2. iPad with Safari
3. Different iOS versions (iOS 14+)

Commands to test:
```bash
# Build web
flutter build web --release

# Serve locally
cd build/web && python -m http.server 8000

# On iOS: Open http://<your-mac-ip>:8000 in Safari
```

## Next Steps

1. **Build**: `flutter build web --release`
2. **Test locally**: Serve and test features
3. **Fix iOS issues**: Test on real devices
4. **Deploy**: Choose hosting option (Firebase Hosting recommended)
5. **Share**: Distribute URL or QR code to iOS users
6. **Monitor**: Track usage and issues

## Support Links

- [Flutter Web Docs](https://docs.flutter.dev/platform-integration/web)
- [PWA Checklist](https://web.dev/pwa-checklist/)
- [iOS PWA Guide](https://developer.apple.com/news/?id=1nnsa6rq)
- [Firebase Hosting](https://firebase.google.com/docs/hosting)
