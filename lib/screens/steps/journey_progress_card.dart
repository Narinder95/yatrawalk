import 'package:flutter/material.dart';

/// Shows progress for the real active Yatra. Takes already-computed
/// walkedKm/totalDistanceKm (from the shared YatraProgress utility) so
/// this card can never drift out of sync with the Home dashboard's
/// numbers again.
class JourneyProgressCard extends StatelessWidget {
  final String destination;
  final double walkedKm;
  final double totalDistanceKm;

  const JourneyProgressCard({
    super.key,
    required this.destination,
    required this.walkedKm,
    required this.totalDistanceKm,
  });

  String _getBackgroundImage() {
    const images = [
      'assets/images/steps-backgrounds/temple_journey.png',
      'assets/images/steps-backgrounds/mountain_peak.png',
      'assets/images/steps-backgrounds/sunrise_destination.png',
      'assets/images/steps-backgrounds/riverside_walk.png',
      'assets/images/steps-backgrounds/golden_sunset.png',
    ];
    return images[destination.hashCode % images.length];
  }

  @override
  Widget build(BuildContext context) {
    final double progress = totalDistanceKm > 0
        ? (walkedKm / totalDistanceKm).clamp(0.0, 1.0)
        : 0.0;

    final double remaining =
        (totalDistanceKm - walkedKm).clamp(0, totalDistanceKm);

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(_getBackgroundImage()),
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.black.withValues(alpha: 0.5),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Text(
                  "Your Yatra",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
                              color: Colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 4),

                          Text(
                            "${walkedKm.toStringAsFixed(2)} km completed",
                            style: const TextStyle(
                              color: Colors.white70,
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
                    backgroundColor: Colors.white30,
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
                        color: Colors.lightGreenAccent,
                      ),
                    ),

                    Text(
                      "${remaining.toStringAsFixed(1)} km remaining",
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Row(
                    children: [

                      Icon(
                        Icons.favorite,
                        color: Colors.orangeAccent,
                      ),

                      SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          "Every step brings you closer to your destination.",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
