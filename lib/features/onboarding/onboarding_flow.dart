import 'package:flutter/material.dart';

import 'onboarding_controller.dart';
import 'screens/welcome_screen.dart';
import 'screens/goal_screen.dart';
import 'screens/location_screen.dart';
import 'screens/finish_screen.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  late OnboardingController controller;

  @override
  void initState() {
    controller = OnboardingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      WelcomeScreen(controller),
      GoalScreen(controller),
      LocationScreen(controller),
      NotificationScreen(controller),
      HealthScreen(controller),
      FinishScreen(controller),
    ];

    return Scaffold(
      body: PageView(
        controller: controller.pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: pages,
      ),
    );
  }
}