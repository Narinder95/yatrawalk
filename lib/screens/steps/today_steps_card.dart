import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TodayStepsCard extends StatefulWidget {
  final int steps;

  const TodayStepsCard({
    super.key,
    required this.steps,
  });

  @override
  State<TodayStepsCard> createState() => _TodayStepsCardState();
}

class _TodayStepsCardState extends State<TodayStepsCard>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentImageIndex = 0;

  // Background images - cycling through different spiritual journey scenes
  final List<String> backgroundImages = [
    'assets/images/steps-backgrounds/night_meditation.png',
    'assets/images/steps-backgrounds/temple_journey.png',
    'assets/images/steps-backgrounds/sunrise_destination.png',
    'assets/images/steps-backgrounds/mountain_peak.png',
    'assets/images/steps-backgrounds/riverside_walk.png',
    'assets/images/steps-backgrounds/golden_sunset.png',
  ];

  // Fallback colors for each scene
  final List<LinearGradient> fallbackGradients = [
    LinearGradient(
      colors: [Color(0xFF001a4d), Color(0xFF0d3d66)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFF8B6F47), Color(0xFF2d5016)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFFFF9800), Color(0xFFFF6B6B)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFF4A90E2), Color(0xFF2d5016)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFF2d5016), Color(0xFF87CEEB)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFFFFB366), Color(0xFFFF9800)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Auto-cycle through images every 4 seconds
    Future.delayed(const Duration(seconds: 4), _autoScrollImages);
  }

  void _autoScrollImages() {
    if (!mounted) return;
    _pageController.nextPage(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildBackgroundImage(int index) {
    return Image.asset(
      backgroundImages[index % backgroundImages.length],
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          decoration: BoxDecoration(
            gradient: fallbackGradients[index % fallbackGradients.length],
          ),
          child: Center(
            child: Text(
              '🙏',
              style: TextStyle(
                fontSize: 80,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: 240,
        width: double.infinity,
        child: Stack(
          children: [
            // Background images carousel with fallback
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentImageIndex = index % backgroundImages.length;
                });
                // Auto-scroll to next image
                Future.delayed(const Duration(seconds: 4), _autoScrollImages);
              },
              itemBuilder: (context, index) {
                return _buildBackgroundImage(index);
              },
            ),

            // Translucent overlay
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

            // Content overlay
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Title
                  const Text(
                    "Today's Steps",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                      letterSpacing: 1.0,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Step count with animation - centered
                  if (kIsWeb)
                    Column(
                      children: [
                        const Text(
                          "📱 Not Available",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "Step tracking only works on native iOS/Android apps",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(scale: animation, child: child);
                        },
                        child: Text(
                          "${widget.steps}",
                          key: ValueKey(widget.steps),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: Offset(2, 2),
                                blurRadius: 4,
                                color: Colors.black45,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 8),

                  // Motivational text
                  const Text(
                    "Keep walking towards your Yatra 🙏",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 3,
                          color: Colors.black45,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Image indicator dots
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  backgroundImages.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentImageIndex == index ? 8 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(
                        alpha: _currentImageIndex == index ? 0.9 : 0.4,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}