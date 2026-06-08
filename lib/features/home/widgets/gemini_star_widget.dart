import 'dart:math';
import 'package:flutter/material.dart';

class GeminiStarWidget extends StatefulWidget {
  final double size;
  const GeminiStarWidget({super.key, this.size = 100});

  @override
  State<GeminiStarWidget> createState() => _GeminiStarWidgetState();
}

class _GeminiStarWidgetState extends State<GeminiStarWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final angle = _controller.value * 2 * pi;
        final scale = 1.0 + 0.08 * sin(_controller.value * 2 * pi * 2);

        return Transform.scale(
          scale: scale,
          child: Transform.rotate(
            angle: angle * 0.15, // Rotação suave e lenta
            child: ShaderMask(
              shaderCallback: (bounds) {
                return const LinearGradient(
                  colors: [Color(0xFF4299E1), Color(0xFF9F7AEA), Color(0xFFED64A6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds);
              },
              child: CustomPaint(
                size: Size(widget.size, widget.size),
                painter: FourPointedStarPainter(),
              ),
            ),
          ),
        );
      },
    );
  }
}

class FourPointedStarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    final cx = size.width / 2;
    final cy = size.height / 2;
    final rx = size.width / 2;
    final ry = size.height / 2;

    path.moveTo(cx, cy - ry);
    path.quadraticBezierTo(cx, cy, cx + rx, cy);
    path.quadraticBezierTo(cx, cy, cx, cy + ry);
    path.quadraticBezierTo(cx, cy, cx - rx, cy);
    path.quadraticBezierTo(cx, cy, cx, cy - ry);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
