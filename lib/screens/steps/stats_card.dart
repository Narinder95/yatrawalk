import 'package:flutter/material.dart';

class StatsCard extends StatelessWidget {
  final int steps;
  final int dailyGoal;

  const StatsCard({
    super.key,
    required this.steps,
    this.dailyGoal = 10000,
  });

  @override
  Widget build(BuildContext context) {
    final double distance = steps * 0.0008; // km
    final int calories = (steps * 0.04).round();

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(
              icon: Icons.route,
              title: "Distance",
              value: "${distance.toStringAsFixed(2)} km",
              color: Colors.blue,
            ),
            _StatItem(
              icon: Icons.local_fire_department,
              title: "Calories",
              value: "$calories kcal",
              color: Colors.red,
            ),
            _StatItem(
              icon: Icons.flag,
              title: "Goal",
              // Reads the daily goal the user picked on the Profile
              // screen, instead of a hardcoded 10,000.
              value: "$dailyGoal",
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(
            icon,
            color: color,
            size: 26,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
