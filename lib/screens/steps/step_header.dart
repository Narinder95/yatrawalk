import 'package:flutter/material.dart';

class StepHeader extends StatelessWidget {
  const StepHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        SizedBox(height: 20),

        Text(
          "YatraWalk",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.deepOrange,
          ),
        ),

        SizedBox(height: 8),

        Text(
          "Walk Every Day • Reach Your Destination",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),

        SizedBox(height: 25),
      ],
    );
  }
}