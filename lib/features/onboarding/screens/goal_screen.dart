import 'package:flutter/material.dart';

import '../onboarding_controller.dart';
import '../widgets/onboarding_button.dart';

class GoalScreen extends StatelessWidget {
  final OnboardingController controller;

  const GoalScreen(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [

            const SizedBox(height: 40),

            const Text(
              "Choose Your Goal",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            ListTile(
              leading: Icon(Icons.local_fire_department),
              title: Text("Lose Weight"),
            ),

            ListTile(
              leading: Icon(Icons.favorite),
              title: Text("Stay Healthy"),
            ),

            ListTile(
              leading: Icon(Icons.hiking),
              title: Text("Explore Places"),
            ),

            const Spacer(),

            OnboardingButton(
              text: "Continue",
              onPressed: () {
                controller.next(6);
              },
            ),
          ],
        ),
      ),
    );
  }
}