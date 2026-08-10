import 'package:flutter/material.dart';

class GoalSelector extends StatelessWidget {
  final int selectedGoal;
  final ValueChanged<int> onChanged;

  const GoalSelector({
    super.key,
    required this.selectedGoal,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const goals = [5000, 7500, 10000, 15000];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Daily Step Goal",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: goals.map((goal) {
            return ChoiceChip(
              label: Text("$goal"),
              selected: selectedGoal == goal,
              onSelected: (_) => onChanged(goal),
            );
          }).toList(),
        ),
      ],
    );
  }
}