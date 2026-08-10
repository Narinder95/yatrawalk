import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../screens/home_screen.dart';
import '../onboarding_controller.dart';
import '../widgets/onboarding_button.dart';

class FinishScreen extends StatelessWidget {
  final OnboardingController controller;

  const FinishScreen(this.controller, {super.key});

  Future<void> _finishOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('onboarding_complete', true);

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),

            const Icon(
              Icons.emoji_events_rounded,
              size: 120,
              color: Colors.orange,
            ),

            const SizedBox(height: 24),

            const Text(
              "You're All Set!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              "Welcome to DigiTeerth.\n\n"
              "Track your steps, explore amazing places, and make every walk a journey.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                height: 1.5,
              ),
            ),

            const Spacer(),

            OnboardingButton(
              text: "Start Walking",
              onPressed: () => _finishOnboarding(context),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}