# PWA Integration Guide

This guide shows how to integrate PWA features into your YatraWalk Flutter app.

## 1. Initialize PWA Service

Add to your `main.dart` or app initialization:

```dart
import 'lib/services/pwa_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Initialize PWA service (web only)
  await pwaService.init();
  
  runApp(const YatraWalkApp());
}
```

## 2. Use Online Status in Your Widgets

Display connectivity status to users:

```dart
import 'lib/services/pwa_service.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: pwaService.isOnline,
      builder: (context, isOnline, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('YatraWalk'),
            // Show offline indicator
            backgroundColor: isOnline ? Colors.orange : Colors.grey,
          ),
          body: Column(
            children: [
              if (!isOnline)
                Container(
                  color: Colors.amber,
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      const Icon(Icons.wifi_off, size: 16),
                      const SizedBox(width: 8),
                      const Text('You are offline - some features unavailable'),
                    ],
                  ),
                ),
              // Rest of your UI
            ],
          ),
        );
      },
    );
  }
}
```

## 3. Handle Data Sync on Connection Restored

Sync data when user comes back online:

```dart
class JourneyService {
  Future<void> syncOfflineData() async {
    // Check if online
    if (!pwaService.isOnline.value) {
      debugPrint('Cannot sync - app is offline');
      return;
    }
    
    try {
      // Sync journeys from local storage to Firebase
      final localJourneys = await _loadLocalJourneys();
      
      for (final journey in localJourneys) {
        if (!journey.isSynced) {
          await _uploadJourney(journey);
        }
      }
      
      debugPrint('Sync completed');
    } catch (e) {
      debugPrint('Sync failed: $e');
    }
  }
}

// Listen for online status changes
void setupAutoSync() {
  pwaService.isOnline.addListener(() {
    if (pwaService.isOnline.value) {
      // App came back online - sync data
      journeyService.syncOfflineData();
    }
  });
}
```

## 4. Show PWA Installation Instructions

Create a helper widget to prompt installation on iOS:

```dart
class PWAInstallPrompt extends StatelessWidget {
  const PWAInstallPrompt({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (pwaService.isPWAInstalled) {
      return const SizedBox.shrink(); // Already installed
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.download_for_offline, size: 32, color: Colors.orange),
            const SizedBox(height: 12),
            const Text(
              'Install YatraWalk',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Get quick access from your home screen',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _showInstallInstructions,
              child: const Text('How to Install'),
            ),
          ],
        ),
      ),
    );
  }

  void _showInstallInstructions() {
    // Show platform-specific instructions
    final userAgent = pwaService.getDeviceInfo()['userAgent'] ?? '';
    
    if (userAgent.contains('iPhone') || userAgent.contains('iPad')) {
      _showiOSInstructions();
    } else {
      _showAndroidInstructions();
    }
  }

  void _showiOSInstructions() {
    // Show iOS installation steps
    print('''
    To install YatraWalk:
    1. Tap the Share button (bottom or top)
    2. Select "Add to Home Screen"
    3. Tap "Add"
    4. YatraWalk will now appear on your home screen
    ''');
  }

  void _showAndroidInstructions() {
    // Show Android installation steps
    print('''
    To install YatraWalk:
    1. Chrome will show an install button
    2. Or tap the menu (⋮) and select "Install app"
    3. YatraWalk will now appear on your home screen
    ''');
  }
}
```

## 5. Request Notification Permission

```dart
class SettingsScreen extends StatefulWidget {
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Enable Notifications'),
            subtitle: const Text('Get reminders for your walks'),
            value: _notificationsEnabled,
            onChanged: (value) async {
              final granted = await pwaService.requestNotificationPermission();
              setState(() {
                _notificationsEnabled = granted;
              });
              
              if (granted) {
                pwaService.showNotification(
                  'YatraWalk',
                  body: 'Notifications enabled! Get reminders for your daily walks.',
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
```

## 6. Update Service Worker

Check for updates periodically:

```dart
class AppUpdateChecker {
  static void startUpdateCheck() {
    // Check for SW updates every hour
    Timer.periodic(const Duration(hours: 1), (_) async {
      await pwaService.updateServiceWorker();
    });
  }
}

// Call in main or after app initialization
AppUpdateCheck.startUpdateCheck();
```

## 7. Clear Cache on Logout

```dart
class AuthService {
  Future<void> logout() async {
    // Clear PWA cache
    await pwaService.clearCache();
    
    // Sign out from Firebase
    await FirebaseAuth.instance.signOut();
    
    // Redirect to login
  }
}
```

## 8. Build and Test

### Build web version
```bash
flutter build web --release
```

### Test locally
```bash
cd build/web
python -m http.server 8000
```

Open `http://localhost:8000` in browser and test:
- [ ] App loads correctly
- [ ] Icons display
- [ ] Manifest loads (DevTools → Application)
- [ ] Service Worker active (DevTools → Application)
- [ ] Offline mode works (DevTools → Network → Offline)
- [ ] Online/offline indicators show
- [ ] Data syncs when connection restored
- [ ] iOS Add to Home Screen works (Safari)
- [ ] Android install prompt works (Chrome)

### Test PWA Service in browser console
```javascript
// Check online status
navigator.onLine

// List cached items
caches.keys().then(names => console.log(names))

// Check service worker
navigator.serviceWorker.getRegistrations().then(r => console.log(r))

// Clear cache
caches.keys().then(names => names.forEach(n => caches.delete(n)))
```

## 9. Optional: Add Offline Page

Create a fallback for when service worker can't load anything:

```html
<!-- web/offline.html -->
<!DOCTYPE html>
<html>
<head>
    <title>YatraWalk - Offline</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100vh;
            margin: 0;
            background: #f5f5f5;
        }
        .offline-container {
            text-align: center;
            padding: 20px;
        }
        .offline-icon {
            font-size: 64px;
            margin-bottom: 20px;
        }
        h1 {
            margin: 0 0 10px 0;
            color: #333;
        }
        p {
            color: #666;
            margin: 0;
        }
    </style>
</head>
<body>
    <div class="offline-container">
        <div class="offline-icon">📵</div>
        <h1>You're Offline</h1>
        <p>Please check your internet connection and try again.</p>
        <p>Some cached content may still be available.</p>
    </div>
</body>
</html>
```

Update `sw.js` to serve this page:
```javascript
// In fetch event handler, for HTML requests:
if (request.headers.get('accept')?.includes('text/html')) {
  return fetch(request).catch(() => caches.match('offline.html'));
}
```

## 10. Common Issues & Fixes

### Service Worker not updating
- Clear browser cache: Ctrl+Shift+Delete
- Unregister old SW: DevTools → Application → Service Workers → Unregister
- Increment `CACHE_NAME` in `sw.js`

### App not installing on iOS
- Must be HTTPS (unless localhost)
- Must have proper manifest.json
- Must have valid icons
- Must use Safari (not Chrome or Firefox)

### Firebase auth not working on web
- Check Firebase web config in `firebase_options.dart`
- Update CORS settings in Firebase Console if needed
- Check browser console for errors

### Icons not showing
- Ensure icons exist in `web/icons/`
- Check manifest.json icon paths are correct
- Clear browser cache and rebuild

## Deployment Checklist

Before going live:

- [ ] Flutter web builds successfully
- [ ] Service worker installs and caches assets
- [ ] App works offline (static assets)
- [ ] Firebase auth/Firestore work on web
- [ ] Icons display correctly
- [ ] Installation works (iOS & Android)
- [ ] Online/offline indicators work
- [ ] Data syncs when connection restored
- [ ] Performance is acceptable
- [ ] No console errors in production
- [ ] Tested on real iOS device
- [ ] Tested on real Android device
- [ ] Configured web hosting with proper CORS
- [ ] SSL certificate valid
- [ ] Analytics tracking working
- [ ] PWA manifest validator passes (web.dev/pwa-checklist)

## Resources

- [Flutter Web Docs](https://docs.flutter.dev/platform-integration/web)
- [PWA Checklist](https://web.dev/pwa-checklist/)
- [Service Workers](https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API)
- [iOS PWA Support](https://webkit.org/blog/12257/the-web-just-gets-better-with-web-push/)
- [Firebase Web Setup](https://firebase.google.com/docs/web/setup)
