import 'package:flutter/material.dart';
import 'dart:math';

/// Cute Yatra mascot widget with various animations and sizes
class YatraMascot extends StatefulWidget {
  /// Size of the mascot (width/height)
  final double size;

  /// Animation type: bounce, float, spin, etc.
  final MascotAnimation animation;

  /// Whether mascot should be interactive
  final bool interactive;

  /// Callback when mascot is tapped
  final VoidCallback? onTap;

  const YatraMascot({
    super.key,
    this.size = 100,
    this.animation = MascotAnimation.bounce,
    this.interactive = false,
    this.onTap,
  });

  @override
  State<YatraMascot> createState() => _YatraMascotState();
}

enum MascotAnimation { bounce, float, spin, wiggle, pulse, none }

class _YatraMascotState extends State<YatraMascot>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    if (widget.animation != MascotAnimation.none) {
      _controller = AnimationController(
        vsync: this,
        duration: _getDuration(widget.animation),
      )..repeat();
    }
  }

  @override
  void dispose() {
    if (widget.animation != MascotAnimation.none) {
      _controller.dispose();
    }
    super.dispose();
  }

  Duration _getDuration(MascotAnimation animation) {
    switch (animation) {
      case MascotAnimation.bounce:
        return const Duration(milliseconds: 1000);
      case MascotAnimation.float:
        return const Duration(milliseconds: 3000);
      case MascotAnimation.spin:
        return const Duration(milliseconds: 2000);
      case MascotAnimation.wiggle:
        return const Duration(milliseconds: 600);
      case MascotAnimation.pulse:
        return const Duration(milliseconds: 1500);
      default:
        return const Duration(milliseconds: 1000);
    }
  }

  Widget _buildMascot() {
    return _MascotSVG(size: widget.size);
  }

  Widget _applyAnimation(Widget child) {
    if (widget.animation == MascotAnimation.none) {
      return child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, widget) {
        switch (this.widget.animation) {
          case MascotAnimation.bounce:
            final bounce = sin(_controller.value * 2 * pi) * 8;
            return Transform.translate(offset: Offset(0, bounce), child: child);

          case MascotAnimation.float:
            final float = sin(_controller.value * 2 * pi) * 6;
            return Transform.translate(offset: Offset(0, float), child: child);

          case MascotAnimation.spin:
            return Transform.rotate(
              angle: _controller.value * 2 * pi,
              child: child,
            );

          case MascotAnimation.wiggle:
            final wiggle = sin(_controller.value * 2 * pi) * 5;
            return Transform.translate(offset: Offset(wiggle, 0), child: child);

          case MascotAnimation.pulse:
            final scale = 0.95 + (_controller.value * 0.1);
            return Transform.scale(scale: scale, child: child);

          default:
            return child;
        }
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mascot = _buildMascot();

    if (widget.interactive) {
      return MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Transform.scale(
            scale: _isHovered ? 1.1 : 1.0,
            child: _applyAnimation(mascot),
          ),
        ),
      );
    }

    return _applyAnimation(mascot);
  }
}

/// Simple SVG representation of the cute mascot
class _MascotSVG extends StatelessWidget {
  final double size;

  const _MascotSVG({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MascotPainter(),
      ),
    );
  }
}

class _MascotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF8B5A3C);
    final accentPaint = Paint()..color = const Color(0xFFFFA500);
    final goldPaint = Paint()..color = const Color(0xFFFFD700);
    final whitePaint = Paint()..color = Colors.white;
    final blackPaint = Paint()..color = Colors.black;
    final greenPaint = Paint()..color = const Color(0xFF2D5016);

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Body
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, centerY + 10),
        width: size.width * 0.6,
        height: size.height * 0.5,
      ),
      paint,
    );

    // Head
    canvas.drawCircle(Offset(centerX, centerY - 20), size.width * 0.35, paint);

    // Horns - left
    final horn1Path = Path();
    horn1Path.moveTo(centerX - 20, centerY - 40);
    horn1Path.quadraticBezierTo(centerX - 35, centerY - 50, centerX - 40, centerY - 30);
    canvas.drawPath(horn1Path, blackPaint..strokeWidth = size.width * 0.08);
    canvas.drawPath(horn1Path, blackPaint..style = PaintingStyle.stroke);

    // Horns - right
    final horn2Path = Path();
    horn2Path.moveTo(centerX + 20, centerY - 40);
    horn2Path.quadraticBezierTo(centerX + 35, centerY - 50, centerX + 40, centerY - 30);
    canvas.drawPath(horn2Path, blackPaint..strokeWidth = size.width * 0.08);
    canvas.drawPath(horn2Path, blackPaint..style = PaintingStyle.stroke);

    // Face details
    // Eyes
    canvas.drawCircle(Offset(centerX - 12, centerY - 25), size.width * 0.08, whitePaint);
    canvas.drawCircle(Offset(centerX + 12, centerY - 25), size.width * 0.08, whitePaint);

    // Pupils
    canvas.drawCircle(Offset(centerX - 12, centerY - 25), size.width * 0.05, blackPaint);
    canvas.drawCircle(Offset(centerX + 12, centerY - 25), size.width * 0.05, blackPaint);

    // Smile
    final smilePath = Path();
    smilePath.arcTo(
      Rect.fromCenter(center: Offset(centerX, centerY - 10), width: 20, height: 15),
      pi,
      pi,
      false,
    );
    canvas.drawPath(smilePath, blackPaint..strokeWidth = 2);

    // Nose
    canvas.drawCircle(Offset(centerX, centerY), size.width * 0.06, accentPaint);

    // Jewelry - gold necklace
    canvas.drawCircle(Offset(centerX - 15, centerY + 15), size.width * 0.06, goldPaint);
    canvas.drawCircle(Offset(centerX, centerY + 20), size.width * 0.07, goldPaint);
    canvas.drawCircle(Offset(centerX + 15, centerY + 15), size.width * 0.06, goldPaint);

    // Belt with gold buckles
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(centerX, centerY + 25),
        width: size.width * 0.5,
        height: size.width * 0.12,
      ),
      accentPaint,
    );

    canvas.drawCircle(Offset(centerX, centerY + 25), size.width * 0.07, goldPaint);

    // Decorative elements on sides
    canvas.drawCircle(Offset(centerX - 35, centerY + 10), size.width * 0.06, greenPaint);
    canvas.drawCircle(Offset(centerX + 35, centerY + 10), size.width * 0.06, greenPaint);
  }

  @override
  bool shouldRepaint(_MascotPainter oldDelegate) => false;
}
