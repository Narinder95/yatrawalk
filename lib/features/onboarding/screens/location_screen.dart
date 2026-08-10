import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../onboarding_controller.dart';
import '../widgets/onboarding_button.dart';

class LocationScreen extends StatelessWidget {
  final OnboardingController controller;

  const LocationScreen(this.controller, {super.key});

  Future<void> _requestLocation() async {
    final status = await Permission.locationWhenInUse.request();

    // Continue regardless of the user's choice.
    // You can enforce permission later if needed.
    controller.next(6);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),

            const Icon(
              Icons.location_on,
              size: 120,
              color: Colors.orange,
            ),

            const SizedBox(height: 24),

            const Text(
              "Enable Location",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              "DigiTeerth uses your location to discover nearby walking routes, attractions, and travel experiences.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                height: 1.5,
              ),
            ),

            const Spacer(),

            OnboardingButton(
              text: "Allow Location",
              onPressed: _requestLocation,
            ),

            const SizedBox(height: 12),

            TextButton(
              onPressed: () {
                controller.next(6);
              },
              child: const Text("Not Now"),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}