
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Animated hero card shown at the top of the Home dashboard.
///
/// Slightly more compact than before, with an explicit progress bar (with
/// numbers, not just a ring) and the current daily walking streak, so the
/// two things people care about most - "how far along am I" and "am I
/// keeping up my streak" - are visible at a glance.
class YatraHeroAnimation extends StatefulWidget {
  final bool hasJourney;
  final String destinationEmoji;
  final String destinationName;
  final double progress; // 0.0 - 1.0
  final double walkedKm;
  final double totalDistanceKm;
  final int streakDays;

  const YatraHeroAnimation({
    super.key,
    required this.hasJourney,
    required this.progress,
    this.destinationEmoji = "🛕",
    this.destinationName = "",
    this.walkedKm = 0,
    this.totalDistanceKm = 0,
    this.streakDays = 0,
  });

  @override
  State<YatraHeroAnimation> createState() => _YatraHeroAnimationState();
}

class _YatraHeroAnimationState extends State<YatraHeroAnimation>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _walkController;
  late PageController _stickerController;
  late PageController _backgroundController;
  int _currentStickerIndex = 0;
  int _currentBackgroundIndex = 0;

  // Sticker images for the character
  final List<String> stickerImages = [
    'assets/images/stickers/walking.png',
    'assets/images/stickers/celebrating.png',
    'assets/images/stickers/meditating.png',
    'assets/images/stickers/praying.png',
    'assets/images/stickers/ringing_bell.png',
    'assets/images/stickers/standing.png',
  ];

  // 🎨 Background images for the hero card - change these to your image paths
  final List<String> backgroundImages = [
    'assets/images/hero-backgrounds/background_1.png',
    'assets/images/hero-backgrounds/background_2.png',
    'assets/images/hero-backgrounds/background_3.png',
    'assets/images/hero-backgrounds/background_4.png',
    'assets/images/hero-backgrounds/background_5.png',
  ];

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _walkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _stickerController = PageController();
    // Auto-cycle stickers every 3 seconds
    Future.delayed(const Duration(seconds: 3), _autoScrollSticker);

    // Auto-cycle background every 5 seconds
    Future.delayed(const Duration(seconds: 5), _autoScrollBackground);
  }

  void _autoScrollSticker() {
    if (!mounted) return;
    _stickerController.nextPage(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  void _autoScrollBackground() {
    if (!mounted) return;
    setState(() {
      _currentBackgroundIndex = (_currentBackgroundIndex + 1) % backgroundImages.length;
    });
    Future.delayed(const Duration(seconds: 5), _autoScrollBackground);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _walkController.dispose();
    _stickerController.dispose();
    super.dispose();
  }

  // 🎯 ADJUST STICKER SIZE HERE:
  // Change this value to make stickers bigger or smaller
  // Current: 192 (increased 20% from 160)
  // Try: 140 (smaller), 160 (default), 192 (current), 220 (bigger), 260 (very big)
  static const double STICKER_HEIGHT = 100;

  Widget _buildStickerImage(int index) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(8),
      child: Image.asset(
        stickerImages[index % stickerImages.length],
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        cacheHeight: 400,
        cacheWidth: 400,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Text(
              '🙏',
              style: TextStyle(fontSize: 56),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackgroundImage(int index) {
    return Container(
      color: const Color(0xFFF4511E),
      child: Opacity(
        opacity: 0.6,
        child: Image.asset(
          backgroundImages[index % backgroundImages.length],
          fit: BoxFit.cover,
          filterQuality: FilterQuality.low,
          cacheHeight: 300,
          cacheWidth: 600,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Background image error: $error');
            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFF9800), Color(0xFFF4511E)],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.deepOrange.withValues(alpha: 0.25),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Animated background images
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 800),
              child: _buildBackgroundImage(_currentBackgroundIndex),
            ),

            // Content on top
            Padding(
              padding: const EdgeInsets.only(top: 40, bottom: 12, left: 20, right: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
          // Left: Very large sticker carousel (30% width - center of attraction)
          Expanded(
            flex: 30,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: STICKER_HEIGHT,
                  color: Colors.transparent,
                  child: PageView.builder(
                    controller: _stickerController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() {
                        _currentStickerIndex = index % stickerImages.length;
                      });
                      Future.delayed(const Duration(seconds: 3), _autoScrollSticker);
                    },
                    itemBuilder: (context, index) {
                      return Center(
                        child: _buildStickerImage(index),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                // Sticker indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    stickerImages.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: _currentStickerIndex == index ? 6 : 4,
                      height: 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(
                          alpha: _currentStickerIndex == index ? 0.9 : 0.4,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Right: Journey info and progress (70% width)
          Expanded(
            flex: 70,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.hasJourney ? "Current Yatra" : "No Active Yatra",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        offset: const Offset(1.0, 1.0),
                        blurRadius: 2.0,
                        color: Colors.black.withValues(alpha: 0.6),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.hasJourney
                      ? widget.destinationName
                      : "Begin your spiritual journey today",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: const Offset(1.5, 1.5),
                        blurRadius: 3.0,
                        color: Colors.black.withValues(alpha: 0.7),
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                if (widget.hasJourney) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: widget.progress),
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return LinearProgressIndicator(
                          value: value,
                          minHeight: 8,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${widget.walkedKm.toStringAsFixed(1)} / ${widget.totalDistanceKm.toStringAsFixed(0)} km",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          shadows: [
                            Shadow(
                              offset: const Offset(1.0, 1.0),
                              blurRadius: 2.0,
                              color: Colors.black.withValues(alpha: 0.6),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "${(widget.progress * 100).toStringAsFixed(1)}%",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          shadows: [
                            Shadow(
                              offset: const Offset(1.0, 1.0),
                              blurRadius: 2.0,
                              color: Colors.black.withValues(alpha: 0.6),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (widget.streakDays > 0)
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: _StreakBadge(days: widget.streakDays),
            ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPulseRing(double delay) {
    final t = (_pulseController.value + delay) % 1.0;
    final scale = 0.78 + (t * 0.45);
    final opacity = (1 - t).clamp(0.0, 1.0) * 0.35;

    return Transform.scale(
      scale: scale,
      child: Container(
        height: 84,
        width: 84,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: opacity),
            width: 3,
          ),
        ),
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  final int days;
  const _StreakBadge({required this.days});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department, color: Colors.white, size: 20),
          const SizedBox(height: 2),
          Text(
            "$days",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          const Text(
            "streak",
            style: TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
