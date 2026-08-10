import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'features/onboarding/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'services/auth_service.dart';
import 'services/cloud_sync_service.dart';
import 'services/onboarding_service.dart';
import 'services/user_profile_service.dart';

/// The single entry gate for the whole app. Listens to Firebase auth state
/// and routes to exactly one of: Login, Profile setup (new users), the
/// explainer onboarding carousel, or Home.
class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  final _onboardingService = OnboardingService();
  final _profileService = UserProfileService();
  bool _splashComplete = false;
  Timer? _splashTimer;
  Future<Widget>? _cachedNextScreenFuture;
  String? _cachedUserId;
  Timer? _authDebounceTimer;

  // Keep splash screen instance stable to prevent video reload
  final _splashScreen = const _SplashScreen();

  @override
  void initState() {
    super.initState();
    debugPrint('[StartupScreen] InitState - Starting splash timer');
    final splashDuration = kIsWeb
        ? const Duration(milliseconds: 500)  // Skip splash on web
        : const Duration(milliseconds: 3500); // Full duration on mobile
    _splashTimer = Timer(splashDuration, () {
      debugPrint('[StartupScreen] Splash timer complete - triggering rebuild');
      if (mounted) {
        setState(() {
          _splashComplete = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    _authDebounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show splash for minimum duration
    if (!_splashComplete) {
      debugPrint('[StartupScreen] Showing splash screen');
      return _splashScreen;
    }

    debugPrint('[StartupScreen] Splash complete, showing auth listener');
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      initialData: AuthService().currentUser,
      builder: (context, userSnapshot) {
        debugPrint('[StartupScreen] StreamBuilder state: ${userSnapshot.connectionState}, hasData: ${userSnapshot.hasData}, user: ${userSnapshot.data?.email}');

        final user = userSnapshot.data;
        debugPrint('[StartupScreen] Current user: ${user?.email ?? "not logged in"}');

        // User not logged in - show login screen
        if (user == null) {
          debugPrint('[StartupScreen] User is null, showing LoginScreen');
          return const LoginScreen();
        }

        // User logged in - determine next screen
        debugPrint('[StartupScreen] User logged in, getting next screen for ${user.uid}');

        // Cache the future to prevent rebuilding
        if (_cachedUserId != user.uid) {
          debugPrint('[StartupScreen] Creating new cached future for ${user.uid}');
          _cachedUserId = user.uid;
          _cachedNextScreenFuture = _getNextScreen(user);
        }

        return FutureBuilder<Widget>(
          key: ValueKey(user.uid),
          future: _cachedNextScreenFuture!,
          builder: (context, screenSnapshot) {
            debugPrint('[StartupScreen] FutureBuilder state: ${screenSnapshot.connectionState}, hasData: ${screenSnapshot.hasData}, error: ${screenSnapshot.error}');

            if (screenSnapshot.hasError) {
              debugPrint('[StartupScreen] Error getting next screen: ${screenSnapshot.error}');
              return const LoginScreen();
            }
            if (!screenSnapshot.hasData) {
              debugPrint('[StartupScreen] Waiting for next screen');
              return const _LoadingScreen();
            }
            debugPrint('[StartupScreen] Showing next screen: ${screenSnapshot.data.runtimeType}');
            return screenSnapshot.data!;
          },
        );
      },
    );
  }

  Future<Widget> _getNextScreen(User user) async {
    try {
      debugPrint('[StartupScreen] _getNextScreen called for user: ${user.email}');

      debugPrint('[StartupScreen] Calling ensureUserDocExists');
      await AuthService().ensureUserDocExists();
      debugPrint('[StartupScreen] User doc ensured');

      final cloudSync = CloudSyncService();

      // Check local profile first (faster), then cloud for multi-device support
      debugPrint('[StartupScreen] Checking profile status');
      var profileDone = await _profileService.hasCompletedProfileSetup();
      if (!profileDone) {
        // Check cloud in case user completed profile on another device
        debugPrint('[StartupScreen] Profile not done locally, checking cloud');
        profileDone = await cloudSync.hasCompletedProfileSetupOnCloud();
        if (profileDone) {
          debugPrint('[StartupScreen] Profile completed on cloud, marking local as done');
          await _profileService.markProfileSetupComplete();
        }
      }
      debugPrint('[StartupScreen] Profile done: $profileDone');
      if (!profileDone) {
        debugPrint('[StartupScreen] Returning ProfileSetupScreen');
        return const ProfileSetupScreen();
      }

      // Check local onboarding first (faster), then cloud for multi-device support
      debugPrint('[StartupScreen] Checking onboarding status');
      var onboardingDone = await _onboardingService.hasCompletedOnboarding();
      if (!onboardingDone) {
        // Check cloud in case user completed onboarding on another device
        debugPrint('[StartupScreen] Onboarding not done locally, checking cloud');
        onboardingDone = await cloudSync.hasCompletedOnboardingOnCloud();
        if (onboardingDone) {
          debugPrint('[StartupScreen] Onboarding completed on cloud, marking local as done');
          await _onboardingService.completeOnboarding();
        }
      }
      debugPrint('[StartupScreen] Onboarding done: $onboardingDone');
      if (!onboardingDone) {
        debugPrint('[StartupScreen] Returning OnboardingScreen');
        return const OnboardingScreen();
      }

      debugPrint('[StartupScreen] Showing HomeScreen');
      return const HomeScreen();
    } catch (e) {
      debugPrint('[StartupScreen] Error in _getNextScreen: $e');
      debugPrint('[StartupScreen] Stack trace: ${StackTrace.current}');
      // Return HomeScreen as fallback
      return const HomeScreen();
    }
  }

}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
            ),
            const SizedBox(height: 24),
            Text(
              'Loading...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen> {
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _initializeVideo();
    } else {
      setState(() {
        _isVideoInitialized = false;
      });
    }
  }

  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.asset('assets/videos/splash.mp4');
      await _videoController.initialize();

      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });

        _videoController.setLooping(false);
        await _videoController.play();
      }
    } catch (e) {
      debugPrint('Video initialization error: $e');
      if (mounted) {
        setState(() {
          _isVideoInitialized = false;
        });
      }
    }
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      _videoController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _isVideoInitialized
            ? SizedBox.expand(
                child: VideoPlayer(_videoController),
              )
            : Container(
                color: Colors.black,
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
      ),
    );
  }
}
