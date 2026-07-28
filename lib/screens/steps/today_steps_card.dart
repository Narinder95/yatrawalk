import 'package:flutter/material.dart';

class TodayStepsCard extends StatelessWidget {
  final int steps;

  const TodayStepsCard({
    super.key,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shadowColor: Colors.orange.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 30,
        ),
        child: Column(
          children: [
            const Icon(
              Icons.directions_walk,
              size: 70,
              color: Colors.orange,
            ),

            const SizedBox(height: 15),

            const Text(
              "Today's Steps",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                "$steps",
                key: ValueKey(steps),
                style: const TextStyle(
                  fontSize: 54,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Keep walking towards your Yatra.",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}