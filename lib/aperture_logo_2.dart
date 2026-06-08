// ignore_for_file: deprecated_member_use
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

enum ApertureLogo2Theme {
  monochrome, // Slate Gray -> Silver -> White
  amber,      // Copper -> Orange -> Amber Gold
  cyber,      // Electric Blue -> Deep Violet -> Cyber Yellow
  emerald,    // Teal -> Emerald -> Lime (Green)
  purple,     // Deep Purple -> Neon Purple -> Lavender
}

enum ApertureAnimationType2 {
  none,
  spin,
  pulse,
  spinAndStop,
  processing,
  breathing,
  aperture,
  toCircle,
  radar,
  vortex,
  shockwave,
  gears,
  drawing,
}

@Preview(name: 'Purple: Processing (Ring)', group: 'Purple Animations')
Widget previewPurpleProcessing() => _buildPreview(
      const ApertureLogo2(
        theme: ApertureLogo2Theme.purple,
        animationType: ApertureAnimationType2.processing,
      ),
    );

@Preview(name: 'Purple: Breathing (Core)', group: 'Purple Animations')
Widget previewPurpleBreathing() => _buildPreview(
      const ApertureLogo2(
        theme: ApertureLogo2Theme.purple,
        animationType: ApertureAnimationType2.breathing,
      ),
    );

@Preview(name: 'Purple: Aperture (Iris)', group: 'Purple Animations')
Widget previewPurpleAperture() => _buildPreview(
      const ApertureLogo2(
        theme: ApertureLogo2Theme.purple,
        animationType: ApertureAnimationType2.aperture,
      ),
    );

@Preview(name: 'Purple: Morph To Circle', group: 'Purple Animations')
Widget previewPurpleToCircle() => _buildPreview(
      const ApertureLogo2(
        theme: ApertureLogo2Theme.purple,
        animationType: ApertureAnimationType2.toCircle,
      ),
    );

@Preview(name: 'Purple: Radar (Sweep)', group: 'Purple Animations')
Widget previewPurpleRadar() => _buildPreview(
      const ApertureLogo2(
        theme: ApertureLogo2Theme.purple,
        animationType: ApertureAnimationType2.radar,
      ),
    );

@Preview(name: 'Purple: Vortex (Suction)', group: 'Purple Animations')
Widget previewPurpleVortex() => _buildPreview(
      const ApertureLogo2(
        theme: ApertureLogo2Theme.purple,
        animationType: ApertureAnimationType2.vortex,
      ),
    );

@Preview(name: 'Purple: Shockwave (Blast)', group: 'Purple Animations')
Widget previewPurpleShockwave() => _buildPreview(
      const ApertureLogo2(
        theme: ApertureLogo2Theme.purple,
        animationType: ApertureAnimationType2.shockwave,
      ),
    );

@Preview(name: 'Purple: Gears (Opposing)', group: 'Purple Animations')
Widget previewPurpleGears() => _buildPreview(
      const ApertureLogo2(
        theme: ApertureLogo2Theme.purple,
        animationType: ApertureAnimationType2.gears,
      ),
    );

@Preview(name: 'Purple: Drawing (Sequential)', group: 'Purple Animations')
Widget previewPurpleDrawing() => _buildPreview(
      const ApertureLogo2(
        theme: ApertureLogo2Theme.purple,
        animationType: ApertureAnimationType2.drawing,
      ),
    );

Widget _buildPreview(Widget logo) {
  return Scaffold(
    backgroundColor: const Color(0xFF0D0D1E),
    body: Center(
      child: SizedBox(
        width: 250,
        height: 250,
        child: logo,
      ),
    ),
  );
}

class ApertureLogo2 extends StatefulWidget {
  final ApertureLogo2Theme theme;
  final double? size;
  final Duration rotationDuration;
  final ApertureAnimationType2 animationType;
  
  // Custom colors to color each segment and the core individually
  final List<Color>? segmentColors;
  final Color? coreColor;

  const ApertureLogo2({
    super.key, 
    this.theme = ApertureLogo2Theme.purple,
    this.size,
    this.rotationDuration = const Duration(seconds: 4),
    this.animationType = ApertureAnimationType2.processing,
    this.segmentColors,
    this.coreColor,
  });

  @override
  State<ApertureLogo2> createState() => _ApertureLogo2State();
}

class _ApertureLogo2State extends State<ApertureLogo2> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _spinAndStopAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.rotationDuration,
    );

    _spinAndStopAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOutCubic),
      ),
    );

    _startAnimation();
  }

  void _startAnimation() {
    _controller.duration = widget.rotationDuration;
    if (widget.animationType == ApertureAnimationType2.none) {
      _controller.stop();
    } else {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(ApertureLogo2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animationType != widget.animationType || oldWidget.rotationDuration != widget.rotationDuration) {
      _startAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Predefined theme palettes
  Color _getThemeCoreColor() {
    if (widget.coreColor != null) return widget.coreColor!;
    switch (widget.theme) {
      case ApertureLogo2Theme.monochrome:
        return const Color(0xFF0F172A); // Deep Slate
      case ApertureLogo2Theme.amber:
        return const Color(0xFF451A03); // Deep Copper
      case ApertureLogo2Theme.cyber:
        return const Color(0xFF0B132B); // Midnight Blue
      case ApertureLogo2Theme.emerald:
        return const Color(0xFF064E3B); // Forest Green
      case ApertureLogo2Theme.purple:
        return const Color(0xFF1E0B36); // Deep Dark Purple
    }
  }

  List<Color> _getThemeSegmentColors() {
    if (widget.segmentColors != null) {
      if (widget.segmentColors!.length >= 8) {
        return widget.segmentColors!;
      }
      return List<Color>.generate(8, (i) => widget.segmentColors![i % widget.segmentColors!.length]);
    }
    
    switch (widget.theme) {
      case ApertureLogo2Theme.monochrome:
        return List<Color>.filled(8, const Color(0xFFCBD5E1)); // Uniform Silver Gray
      case ApertureLogo2Theme.amber:
        return List<Color>.filled(8, const Color(0xFFF97316)); // Uniform Amber Orange
      case ApertureLogo2Theme.cyber:
        return List<Color>.filled(8, const Color(0xFF00B4D8)); // Uniform Electric Cyan
      case ApertureLogo2Theme.emerald:
        return List<Color>.filled(8, const Color(0xFF10B981)); // Uniform Emerald Green
      case ApertureLogo2Theme.purple:
        return List<Color>.filled(8, const Color(0xFF6C3CE9)); // Uniform Main Brand Purple
    }
  }

  @override
  Widget build(BuildContext context) {
    final coreColor = _getThemeCoreColor();
    final segmentColors = _getThemeSegmentColors();

    Widget customPaint = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double ringRotation = 0.0;
        double coreRotation = 0.0;
        double ringScale = 1.0;
        double coreScale = 1.0;
        double apertureValue = 1.0;
        double gapWidthMultiplier = 1.0;
        List<double> segmentOpacities = List.filled(8, 1.0);
        bool useGearsSplit = false;

        switch (widget.animationType) {
          case ApertureAnimationType2.none:
            break;
          case ApertureAnimationType2.spin:
            ringRotation = _controller.value * 2 * math.pi;
            coreRotation = _controller.value * 2 * math.pi;
            break;
          case ApertureAnimationType2.pulse:
            final sineVal = math.sin(_controller.value * 2 * math.pi);
            ringScale = 1.0 + 0.08 * sineVal;
            coreScale = 1.0 + 0.08 * sineVal;
            break;
          case ApertureAnimationType2.spinAndStop:
            ringRotation = _spinAndStopAnimation.value * 2 * math.pi;
            coreRotation = _spinAndStopAnimation.value * 2 * math.pi;
            break;
          case ApertureAnimationType2.processing:
            ringRotation = _controller.value * 2 * math.pi;
            break;
          case ApertureAnimationType2.breathing:
            final sineVal = math.sin(_controller.value * 2 * math.pi);
            coreScale = 1.0 + 0.08 * sineVal;
            break;
          case ApertureAnimationType2.aperture:
            final t = 0.5 + 0.5 * math.cos(_controller.value * 2 * math.pi);
            apertureValue = t;
            ringRotation = (1.0 - t) * (math.pi / 4);
            break;
          case ApertureAnimationType2.toCircle:
            final t = 0.5 + 0.5 * math.cos(_controller.value * 2 * math.pi);
            apertureValue = t;
            gapWidthMultiplier = t;
            break;
          case ApertureAnimationType2.radar:
            ringRotation = _controller.value * 0.2 * 2 * math.pi;
            final sweepAngle = _controller.value * 2 * math.pi;
            segmentOpacities = List.generate(8, (i) {
              final angleStep = 2 * math.pi / 8;
              final centerAngle = (i + 0.5) * angleStep;
              double diff = (sweepAngle - centerAngle) % (2 * math.pi);
              double opacity = 1.0 - (diff / (2 * math.pi));
              return 0.15 + 0.85 * opacity;
            });
            break;
          case ApertureAnimationType2.vortex:
            final t = _controller.value;
            final s = 0.5 + 0.5 * math.cos(t * 2 * math.pi);
            ringScale = s;
            ringRotation = (1.0 - s) * 2 * math.pi;
            break;
          case ApertureAnimationType2.shockwave:
            final p = _controller.value;
            if (p < 0.25) {
              final t = p / 0.25;
              coreScale = 1.0 + 0.15 * math.sin(t * math.pi);
            } else if (p >= 0.25 && p < 0.75) {
              final t = (p - 0.25) / 0.5;
              ringScale = 1.0 + 0.5 * Curves.easeOutExpo.transform(t);
              segmentOpacities = List.filled(8, 1.0 - t);
            } else {
              final t = (p - 0.75) / 0.25;
              ringScale = 0.5 + 0.5 * Curves.easeOutBack.transform(t);
              segmentOpacities = List.filled(8, t);
            }
            break;
          case ApertureAnimationType2.gears:
            ringRotation = _controller.value * 2 * math.pi;
            coreRotation = -_controller.value * 2 * math.pi;
            useGearsSplit = true;
            break;
          case ApertureAnimationType2.drawing:
            final p = _controller.value;
            if (p < 0.8) {
              final t = p / 0.8;
              segmentOpacities = List.generate(8, (i) {
                final threshold = i / 8.0;
                if (t > threshold) {
                  return math.min(1.0, (t - threshold) * 8.0);
                }
                return 0.0;
              });
            } else {
              final t = (p - 0.8) / 0.2;
              segmentOpacities = List.filled(8, 1.0 - t);
            }
            break;
        }

        return CustomPaint(
          painter: _ApertureLogo2Painter(
            coreColor: coreColor,
            segmentColors: segmentColors,
            ringRotation: ringRotation,
            coreRotation: coreRotation,
            ringScale: ringScale,
            coreScale: coreScale,
            apertureValue: apertureValue,
            gapWidthMultiplier: gapWidthMultiplier,
            segmentOpacities: segmentOpacities,
            useGearsSplit: useGearsSplit,
          ),
        );
      },
    );

    if (widget.size != null) {
      customPaint = SizedBox(
        width: widget.size,
        height: widget.size,
        child: customPaint,
      );
    }

    return customPaint;
  }
}

class _ApertureLogo2Painter extends CustomPainter {
  final Color coreColor;
  final List<Color> segmentColors;
  final double ringRotation;
  final double coreRotation;
  final double ringScale;
  final double coreScale;
  final double apertureValue;
  final double gapWidthMultiplier;
  final List<double> segmentOpacities;
  final bool useGearsSplit;

  _ApertureLogo2Painter({
    required this.coreColor,
    required this.segmentColors,
    required this.ringRotation,
    required this.coreRotation,
    required this.ringScale,
    required this.coreScale,
    required this.apertureValue,
    required this.gapWidthMultiplier,
    required this.segmentOpacities,
    required this.useGearsSplit,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final rOuter = radius * ringScale;
    final rCenter = radius * 0.55 * coreScale;
    final rInner = radius * ringScale * (0.55 + 0.17 * apertureValue);
    
    // Draw central circle
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(coreRotation);
    canvas.translate(-center.dx, -center.dy);
    
    if (useGearsSplit) {
      final Paint half1 = Paint()..color = coreColor..style = PaintingStyle.fill;
      final Paint half2 = Paint()..color = segmentColors[0]..style = PaintingStyle.fill;
      canvas.drawArc(Rect.fromCircle(center: center, radius: rCenter), 0, math.pi, true, half1);
      canvas.drawArc(Rect.fromCircle(center: center, radius: rCenter), math.pi, math.pi, true, half2);
    } else {
      final Paint corePaint = Paint()..color = coreColor..style = PaintingStyle.fill;
      canvas.drawCircle(center, rCenter, corePaint);
    }
    canvas.restore();

    // Save layer for the outer ring with cuts
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    final int numSegments = 8;
    final double angleStep = 2 * math.pi / numSegments;
    final rTangent = rCenter * (0.8 + 0.1 * apertureValue); 
    final double globalRotation = -math.pi / 8;

    for (int i = 0; i < numSegments; i++) {
      final opacity = segmentOpacities[i];
      if (opacity <= 0.0) continue;

      canvas.save();

      // Current cut line geometry
      final double angle = i * angleStep + globalRotation + ringRotation;
      final tx = center.dx + rTangent * math.cos(angle);
      final ty = center.dy + rTangent * math.sin(angle);
      final dx = -math.sin(angle);
      final dy = math.cos(angle);

      // Next cut line geometry
      final double angleNext = (i + 1) * angleStep + globalRotation + ringRotation;
      final txNext = center.dx + rTangent * math.cos(angleNext);
      final tyNext = center.dy + rTangent * math.sin(angleNext);
      final dxNext = -math.sin(angleNext);
      final dyNext = math.cos(angleNext);

      // Construct a polygon to clip this segment
      final clipPath = Path();
      clipPath.moveTo(center.dx, center.dy);
      clipPath.lineTo(tx, ty);
      clipPath.lineTo(tx + dx * radius * 3, ty + dy * radius * 3);
      clipPath.lineTo(txNext + dxNext * radius * 3, tyNext + dyNext * radius * 3);
      clipPath.lineTo(txNext, tyNext);
      clipPath.close();

      canvas.clipPath(clipPath);

      final segmentPaint = Paint()
        ..color = segmentColors[i].withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = rOuter - rInner;

      canvas.drawCircle(center, (rOuter + rInner) / 2, segmentPaint);

      canvas.restore();
    }

    // Cut the gaps (only if gapWidthMultiplier > 0)
    if (gapWidthMultiplier > 0.0) {
      final clearPaint = Paint()
        ..blendMode = BlendMode.clear
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * ringScale * 0.12 * gapWidthMultiplier;

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(ringRotation);
      canvas.translate(-center.dx, -center.dy);

      for (int i = 0; i < numSegments; i++) {
        final angle = i * angleStep + globalRotation;
        
        final tx = center.dx + rTangent * math.cos(angle);
        final ty = center.dy + rTangent * math.sin(angle);
        
        final dx = -math.sin(angle);
        final dy = math.cos(angle);
        
        final p1 = Offset(tx - dx * radius * 0.1, ty - dy * radius * 0.1);
        final p2 = Offset(tx + dx * radius * 1.5, ty + dy * radius * 1.5);
        
        canvas.drawLine(p1, p2, clearPaint);
      }
      canvas.restore();
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ApertureLogo2Painter oldDelegate) {
    return oldDelegate.coreColor != coreColor ||
        oldDelegate.segmentColors != segmentColors ||
        oldDelegate.ringRotation != ringRotation ||
        oldDelegate.coreRotation != coreRotation ||
        oldDelegate.ringScale != ringScale ||
        oldDelegate.coreScale != coreScale ||
        oldDelegate.apertureValue != apertureValue ||
        oldDelegate.gapWidthMultiplier != gapWidthMultiplier ||
        oldDelegate.segmentOpacities != segmentOpacities ||
        oldDelegate.useGearsSplit != useGearsSplit;
  }
}
