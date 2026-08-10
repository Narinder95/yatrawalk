import 'package:flutter/material.dart';

import '../onboarding_controller.dart';
import '../widgets/onboarding_button.dart';

class WelcomeScreen extends StatelessWidget {
  final OnboardingController controller;

  const WelcomeScreen(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [

            const Spacer(),

            const Icon(
              Icons.directions_walk,
              size: 120,
            ),

            const SizedBox(height: 30),

            const Text(
              "Welcome to DigiTeerth",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              "Walk • Explore • Earn",
              textAlign: TextAlign.center,
            ),

            const Spacer(),

            OnboardingButton(
              text: "Next",
              onPressed: () {
                controller.next(6);
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}