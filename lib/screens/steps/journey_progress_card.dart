import 'package:flutter/material.dart';

class JourneyProgressCard extends StatelessWidget {
  final String destination;
  final double totalDistanceKm;
  final int steps;

  const JourneyProgressCard({
    super.key,
    required this.destination,
    required this.totalDistanceKm,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    // 1 step ≈ 0.8 metres
    final double walkedKm = steps * 0.0008;

    final double progress =
        (walkedKm / totalDistanceKm).clamp(0.0, 1.0);

    final double remaining =
        (totalDistanceKm - walkedKm).clamp(0, totalDistanceKm);

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Your Yatra",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [

                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Color(0xFFFFF3E0),
                  child: Icon(
                    Icons.temple_hindu,
                    color: Colors.deepOrange,
                    size: 30,
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        destination,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        "${walkedKm.toStringAsFixed(2)} km completed",
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                minHeight: 12,
                value: progress,
                backgroundColor: Colors.grey.shade300,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(
                  Colors.orange,
                ),
              ),
            ),

            const SizedBox(height: 15),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [

                Text(
                  "${(progress * 100).toStringAsFixed(1)} %",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),

                Text(
                  "${remaining.toStringAsFixed(1)} km remaining",
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Row(
                children: [

                  Icon(
                    Icons.favorite,
                    color: Colors.deepOrange,
                  ),

                  SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      "Every step brings you closer to your destination.",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}