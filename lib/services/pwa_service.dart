import 'dart:async';
import 'dart:js' as js;
import 'dart:js_util' as js_util;
import 'package:flutter/foundation.dart';

class PWAService {
  static final PWAService _instance = PWAService._internal();

  factory PWAService() {
    return _instance;
  }

  PWAService._internal();

  final _isOnlineController = ValueNotifier<bool>(true);
  StreamSubscription? _onlineSubscription;
  StreamSubscription? _offlineSubscription;

  ValueNotifier<bool> get isOnline => _isOnlineController;

  /// Initialize PWA service (online/offline detection)
  Future<void> init() async {
    if (!kIsWeb) return;

    // Set up online/offline listeners
    _setupOnlineDetection();

    // Request notification permission if needed
    _checkNotificationPermission();
  }

  /// Setup online/offline event listeners
  void _setupOnlineDetection() {
    if (!kIsWeb) return;

    try {
      final window = js.context['window'];

      // Check initial online status
      final initialOnline = js.context['navigator']['onLine'] as bool;
      _isOnlineController.value = initialOnline;

      // Listen to online event
      window.callMethod('addEventListener', [
        'online',
        js.allowInterop(() {
          _isOnlineController.value = true;
          _handleOnlineStatusChange(true);
        })
      ]);

      // Listen to offline event
      window.callMethod('addEventListener', [
        'offline',
        js.allowInterop(() {
          _isOnlineController.value = false;
          _handleOnlineStatusChange(false);
        })
      ]);
    } catch (e) {
      debugPrint('PWA Service: Error setting up online detection: $e');
    }
  }

  /// Handle online status changes
  void _handleOnlineStatusChange(bool isOnline) {
    debugPrint('PWA Service: Online status changed to: $isOnline');

    if (isOnline) {
      // App is back online - sync any pending data
      _syncPendingData();
    } else {
      // App went offline - notify user
      debugPrint('PWA Service: App is now offline');
    }
  }

  /// Sync pending data when coming back online
  Future<void> _syncPendingData() async {
    try {
      // TODO: Implement data sync logic here
      // This could include:
      // - Syncing offline step counts
      // - Uploading pending journeys
      // - Refreshing user data
      debugPrint('PWA Service: Syncing pending data...');
    } catch (e) {
      debugPrint('PWA Service: Error syncing data: $e');
    }
  }

  /// Check and request notification permission
  Future<bool> requestNotificationPermission() async {
    if (!kIsWeb) return false;

    try {
      final notification = js.context['Notification'];
      if (notification == null) {
        debugPrint('PWA Service: Notifications not supported');
        return false;
      }

      final permission = js.context['Notification']['permission'];

      if (permission == 'granted') {
        return true;
      } else if (permission == 'default') {
        // Request permission
        final result = await js_util.promiseToFuture(
          notification.callMethod('requestPermission')
        );
        return result == 'granted';
      }

      return false;
    } catch (e) {
      debugPrint('PWA Service: Error requesting notification permission: $e');
      return false;
    }
  }

  /// Check notification permission
  void _checkNotificationPermission() {
    if (!kIsWeb) return;

    try {
      final notification = js.context['Notification'];
      if (notification != null) {
        final permission = js.context['Notification']['permission'];
        debugPrint('PWA Service: Notification permission: $permission');
      }
    } catch (e) {
      debugPrint('PWA Service: Error checking notification permission: $e');
    }
  }

  /// Show a notification (if permission granted)
  Future<void> showNotification(String title, {String? body, String? icon}) async {
    if (!kIsWeb) return;

    try {
      final notification = js.context['Notification'];
      if (notification == null) {
        debugPrint('PWA Service: Notifications not supported');
        return;
      }

      final options = <String, dynamic>{
        'body': body ?? '',
        'icon': icon ?? 'icons/Icon-192.png',
      };

      notification.callConstructor([title, options]);
    } catch (e) {
      debugPrint('PWA Service: Error showing notification: $e');
    }
  }

  /// Check if app is installed as PWA
  bool get isPWAInstalled {
    if (!kIsWeb) return false;

    try {
      // Check if window.navigator.standalone exists (iOS)
      final standalone = js.context['window']['navigator']['standalone'];
      if (standalone != null) return true;

      // Check if display-mode is standalone (Android)
      final matchMedia = js.context['window'].callMethod('matchMedia', [
        '(display-mode: standalone)'
      ]);
      return matchMedia['matches'] as bool;
    } catch (e) {
      return false;
    }
  }

  /// Get device information for PWA
  Map<String, dynamic> getDeviceInfo() {
    if (!kIsWeb) return {};

    try {
      final userAgent = js.context['navigator']['userAgent'] as String;
      final platform = js.context['navigator']['platform'] as String;

      return {
        'userAgent': userAgent,
        'platform': platform,
        'isInstalled': isPWAInstalled,
        'isOnline': _isOnlineController.value,
      };
    } catch (e) {
      debugPrint('PWA Service: Error getting device info: $e');
      return {};
    }
  }

  /// Update service worker (when new version available)
  Future<void> updateServiceWorker() async {
    if (!kIsWeb) return;

    try {
      final serviceWorkerContainer = js.context['navigator']['serviceWorker'];
      if (serviceWorkerContainer == null) return;

      final registration = await js_util.promiseToFuture(
        serviceWorkerContainer.callMethod('ready')
      );

      // Check for updates
      registration.callMethod('update');

      // Listen for controller change (new SW activated)
      final window = js.context['window'];
      window.callMethod('addEventListener', [
        'controllerchange',
        js.allowInterop(() {
          debugPrint('PWA Service: New service worker activated');
          // Optionally reload the app
          // js.context['location'].callMethod('reload');
        })
      ]);
    } catch (e) {
      debugPrint('PWA Service: Error updating service worker: $e');
    }
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    if (!kIsWeb) return;

    try {
      final cacheStorage = js.context['caches'];
      if (cacheStorage == null) return;

      final cacheNames = await js_util.promiseToFuture(
        cacheStorage.callMethod('keys')
      ) as List<dynamic>;

      for (final cacheName in cacheNames) {
        await js_util.promiseToFuture(
          cacheStorage.callMethod('delete', [cacheName])
        );
        debugPrint('PWA Service: Cleared cache: $cacheName');
      }
    } catch (e) {
      debugPrint('PWA Service: Error clearing cache: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _onlineSubscription?.cancel();
    _offlineSubscription?.cancel();
    _isOnlineController.dispose();
  }
}

// Global PWA service instance
final pwaService = PWAService();
