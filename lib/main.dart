import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'startup_screen.dart';

// Global RouteObserver so any screen (e.g. the Home dashboard) can be
// notified via RouteAware when it becomes visible again after a screen
// pushed on top of it is popped - this is how we refresh the dashboard
// after a Yatra is created/updated on another screen.
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Requires running `flutterfire configure` first, which generates
  // lib/firebase_options.dart for your specific Firebase project.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const DigiTeerthApp());
}

class DigiTeerthApp extends StatelessWidget {
  const DigiTeerthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DigiTeerth',
      theme: ThemeData(
        colorSchemeSeed: Colors.orange,
        useMaterial3: true,
      ),
      navigatorObservers: [routeObserver],
      home: const StartupScreen(),
    );
  }
}
