import 'package:flutter/material.dart';

/// A small daily ritual card: shows the Sankalp (manifestation wish) the
/// user attached to their active Yatra, lets them reaffirm it once per
/// day, and lets them edit/renew it at any time.
class SankalpCard extends StatelessWidget {
  final String sankalp;
  final bool checkedInToday;
  final VoidCallback onCheckIn;
  final VoidCallback onEdit;
  final VoidCallback? onTap;

  const SankalpCard({
    super.key,
    required this.sankalp,
    required this.checkedInToday,
    required this.onCheckIn,
    required this.onEdit,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.orange.shade100),
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text("🙏 ", style: TextStyle(fontSize: 18)),
              const Expanded(
                child: Text(
                  "Today's Sankalp",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 18),
                color: Colors.deepOrange,
                tooltip: "Renew Sankalp",
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            sankalp.isNotEmpty
                ? sankalp
                : "Add a wish or intention to carry with you on this Yatra.",
            style: const TextStyle(fontSize: 15, height: 1.3),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: checkedInToday ? null : onCheckIn,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.deepOrange,
                side: const BorderSide(color: Colors.deepOrange),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(
                checkedInToday ? Icons.check_circle : Icons.favorite_border,
                size: 18,
              ),
              label: Text(
                checkedInToday
                    ? "Recited today"
                    : "I recited my Sankalp today",
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}
