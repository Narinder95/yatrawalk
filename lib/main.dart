import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/step_service.dart';
import 'startup_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const YatraWalkApp());
}

class YatraWalkApp extends StatelessWidget {
  const YatraWalkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'YatraWalk',
      theme: ThemeData(
        colorSchemeSeed: Colors.orange,
        useMaterial3: true,
      ),
      home: const StartupScreen(),
    );
  }
}