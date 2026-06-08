// ignore_for_file: deprecated_member_use
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

enum ApertureAnimationType {
  none,
  spin,        // Entire logo rotates
  pulse,       // Entire logo pulses
  spinAndStop, // Entire logo rotates and stops
  processing,  // Only ring rotates
  breathing,   // Only core pulsates
  aperture,    // Diaphragm opening/closing
  toCircle,    // Morphing into a single solid circle
  radar,       // Sequential glowing ring (radar effect)
  vortex,      // Ring spirals into center
  shockwave,   // Core swells, then ring blasts outward
  gears,       // Ring and core rotate in opposite directions (visualized with gradient)
  drawing,     // Ring segments drawn one by one
  welcomeSequence, // Circle appears, then wings with vortex, then loops spinning
  welcomeMorph, // Transition: wings spiral in and disappear, leaving just the core
}

@Preview(name: 'Welcome Screen Sequence', group: 'Logo Animations')
Widget previewWelcomeSequence() => const WelcomeScreenPreview();

@Preview(name: 'Anim: Spin (All)', group: 'Logo Animations')
Widget previewSpin() => _buildPreview(const ApertureLogo(animationType: ApertureAnimationType.spin));

@Preview(name: 'Anim: Pulse (All)', group: 'Logo Animations')
Widget previewPulse() => _buildPreview(const ApertureLogo(animationType: ApertureAnimationType.pulse));

@Preview(name: 'Anim: Spin & Stop (All)', group: 'Logo Animations')
Widget previewSpinStop() => _buildPreview(const ApertureLogo(animationType: ApertureAnimationType.spinAndStop));

@Preview(name: 'Anim: Processing (Ring)', group: 'Logo Animations')
Widget previewProcessing() => _buildPreview(const ApertureLogo(animationType: ApertureAnimationType.processing));

@Preview(name: 'Anim: Breathing (Core)', group: 'Logo Animations')
Widget previewBreathing() => _buildPreview(const ApertureLogo(animationType: ApertureAnimationType.breathing));

@Preview(name: 'Anim: Aperture (Iris)', group: 'Logo Animations')
Widget previewAperture() => _buildPreview(const ApertureLogo(animationType: ApertureAnimationType.aperture));

@Preview(name: 'Anim: Morph To Circle', group: 'Logo Animations')
Widget previewToCircle() => _buildPreview(const ApertureLogo(animationType: ApertureAnimationType.toCircle));

@Preview(name: 'Anim: Radar (Sweep)', group: 'Logo Animations')
Widget previewRadar() => _buildPreview(const ApertureLogo(animationType: ApertureAnimationType.radar));

@Preview(name: 'Anim: Vortex (Suction)', group: 'Logo Animations')
Widget previewVortex() => _buildPreview(const ApertureLogo(animationType: ApertureAnimationType.vortex));

@Preview(name: 'Anim: Shockwave (Blast)', group: 'Logo Animations')
Widget previewShockwave() => _buildPreview(const ApertureLogo(animationType: ApertureAnimationType.shockwave));

@Preview(name: 'Anim: Gears (Opposing)', group: 'Logo Animations')
Widget previewGears() => _buildPreview(const ApertureLogo(animationType: ApertureAnimationType.gears));

@Preview(name: 'Anim: Drawing (Sequential)', group: 'Logo Animations')
Widget previewDrawing() => _buildPreview(const ApertureLogo(animationType: ApertureAnimationType.drawing));

@Preview(name: 'Anim: Static', group: 'Logo Animations')
Widget previewStatic() => _buildPreview(const ApertureLogo(animationType: ApertureAnimationType.none));

Widget _buildPreview(Widget logo) {
  return Scaffold(
    backgroundColor: const Color(0xFF1A1A2E),
    body: Center(
      child: SizedBox(
        width: 250,
        height: 250,
        child: logo,
      ),
    ),
  );
}

class ApertureLogo extends StatefulWidget {
  final Color color;
  final double? size;
  final Duration rotationDuration;
  final ApertureAnimationType animationType;
  final VoidCallback? onIntroComplete;

  const ApertureLogo({
    super.key, 
    this.color = const Color(0xFF6C3CE9),
    this.size,
    this.rotationDuration = const Duration(seconds: 4),
    this.animationType = ApertureAnimationType.processing,
    this.onIntroComplete,
  });

  @override
  State<ApertureLogo> createState() => _ApertureLogoState();
}

class _ApertureLogoState extends State<ApertureLogo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _spinAndStopAnimation;
  bool _introCompleted = false;

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
    if (widget.animationType == ApertureAnimationType.none) {
      _controller.duration = widget.rotationDuration;
      _controller.stop();
    } else if (widget.animationType == ApertureAnimationType.welcomeSequence) {
      _introCompleted = false;
      _controller.duration = const Duration(milliseconds: 2500);
      _controller.forward().then((_) {
        if (mounted && widget.animationType == ApertureAnimationType.welcomeSequence) {
          setState(() {
            _introCompleted = true;
          });
          _controller.duration = widget.rotationDuration;
          _controller.repeat();
          if (widget.onIntroComplete != null) {
            widget.onIntroComplete!();
          }
        }
      });
    } else if (widget.animationType == ApertureAnimationType.welcomeMorph) {
      _controller.duration = const Duration(milliseconds: 1000);
      _controller.forward(from: 0.0);
    } else {
      _controller.duration = widget.rotationDuration;
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(ApertureLogo oldWidget) {
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

  @override
  Widget build(BuildContext context) {
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
        bool useCoreGradient = false;

        switch (widget.animationType) {
          case ApertureAnimationType.none:
            break;
          case ApertureAnimationType.spin:
            ringRotation = _controller.value * 2 * math.pi;
            coreRotation = _controller.value * 2 * math.pi;
            break;
          case ApertureAnimationType.pulse:
            final sineVal = math.sin(_controller.value * 2 * math.pi);
            ringScale = 1.0 + 0.08 * sineVal;
            coreScale = 1.0 + 0.08 * sineVal;
            break;
          case ApertureAnimationType.spinAndStop:
            ringRotation = _spinAndStopAnimation.value * 2 * math.pi;
            coreRotation = _spinAndStopAnimation.value * 2 * math.pi;
            break;
          case ApertureAnimationType.processing:
            ringRotation = _controller.value * 2 * math.pi;
            break;
          case ApertureAnimationType.breathing:
            final sineVal = math.sin(_controller.value * 2 * math.pi);
            coreScale = 1.0 + 0.08 * sineVal;
            break;
          case ApertureAnimationType.aperture:
            final t = 0.5 + 0.5 * math.cos(_controller.value * 2 * math.pi);
            apertureValue = t;
            ringRotation = (1.0 - t) * (math.pi / 4);
            break;
          case ApertureAnimationType.toCircle:
            final t = 0.5 + 0.5 * math.cos(_controller.value * 2 * math.pi);
            apertureValue = t;
            gapWidthMultiplier = t;
            break;
          case ApertureAnimationType.radar:
            ringRotation = _controller.value * 0.2 * 2 * math.pi; // Slow rotation
            final sweepAngle = _controller.value * 2 * math.pi;
            segmentOpacities = List.generate(8, (i) {
              final angleStep = 2 * math.pi / 8;
              final centerAngle = (i + 0.5) * angleStep;
              double diff = (sweepAngle - centerAngle) % (2 * math.pi);
              double opacity = 1.0 - (diff / (2 * math.pi));
              return 0.15 + 0.85 * opacity; // Tail fade effect
            });
            break;
          case ApertureAnimationType.vortex:
            final t = _controller.value;
            final s = 0.5 + 0.5 * math.cos(t * 2 * math.pi);
            ringScale = s;
            ringRotation = (1.0 - s) * 2 * math.pi;
            break;
          case ApertureAnimationType.shockwave:
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
          case ApertureAnimationType.gears:
            ringRotation = _controller.value * 2 * math.pi;
            coreRotation = -_controller.value * 2 * math.pi;
            useCoreGradient = true;
            break;
          case ApertureAnimationType.drawing:
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
          case ApertureAnimationType.welcomeSequence:
            if (!_introCompleted) {
              final t = _controller.value;
              if (t < 0.4) {
                final tCore = t / 0.4;
                coreScale = Curves.easeOutBack.transform(tCore);
                ringScale = 0.0;
                segmentOpacities = List.filled(8, 0.0);
              } else {
                coreScale = 1.0;
                final tRing = (t - 0.4) / 0.6;
                final ringEase = Curves.easeOutCubic.transform(tRing);
                ringScale = ringEase;
                ringRotation = (1.0 - ringEase) * -3 * math.pi;
                segmentOpacities = List.filled(8, ringEase);
              }
            } else {
              coreScale = 1.0;
              ringScale = 1.0;
              ringRotation = _controller.value * 2 * math.pi;
              coreRotation = _controller.value * 2 * math.pi;
            }
            break;
          case ApertureAnimationType.welcomeMorph:
            final t = _controller.value;
            coreScale = 1.0;
            ringScale = 1.0 - t;
            ringRotation = t * math.pi;
            segmentOpacities = List.filled(8, 1.0 - t);
            break;
        }

        return CustomPaint(
          painter: ApertureLogoPainter(
            color: widget.color,
            ringRotation: ringRotation,
            coreRotation: coreRotation,
            ringScale: ringScale,
            coreScale: coreScale,
            apertureValue: apertureValue,
            gapWidthMultiplier: gapWidthMultiplier,
            segmentOpacities: segmentOpacities,
            useCoreGradient: useCoreGradient,
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

class ApertureLogoPainter extends CustomPainter {
  final Color color;
  final double ringRotation;
  final double coreRotation;
  final double ringScale;
  final double coreScale;
  final double apertureValue;
  final double gapWidthMultiplier;
  final List<double> segmentOpacities;
  final bool useCoreGradient;

  ApertureLogoPainter({
    required this.color,
    required this.ringRotation,
    required this.coreRotation,
    required this.ringScale,
    required this.coreScale,
    required this.apertureValue,
    required this.gapWidthMultiplier,
    required this.segmentOpacities,
    required this.useCoreGradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final rOuter = radius * ringScale;
    final rCenter = radius * 0.55 * coreScale;
    final rInner = radius * ringScale * (0.55 + 0.17 * apertureValue);
    
    final Paint corePaint = Paint()..style = PaintingStyle.fill;

    if (useCoreGradient) {
      corePaint.shader = SweepGradient(
        colors: [
          color,
          color.withOpacity(0.3),
          color,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: rCenter));
    } else {
      corePaint.color = color;
    }

    // Draw central circle
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(coreRotation);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawCircle(center, rCenter, corePaint);
    canvas.restore();

    // Save layer for the outer ring with cuts
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    // Rotate canvas for the outer ring
    canvas.translate(center.dx, center.dy);
    canvas.rotate(ringRotation);
    canvas.translate(-center.dx, -center.dy);

    // Draw outer ring segments individually
    final int numSegments = 8;
    final double angleStep = 2 * math.pi / numSegments;

    for (int i = 0; i < numSegments; i++) {
      final opacity = segmentOpacities[i];
      if (opacity <= 0.0) continue;

      final segmentPaint = Paint()
        ..color = color.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = rOuter - rInner;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: (rOuter + rInner) / 2),
        i * angleStep - 0.01,
        angleStep + 0.02,
        false,
        segmentPaint,
      );
    }

    // Cut the gaps (only if gapWidthMultiplier > 0 and ringScale > 0)
    if (gapWidthMultiplier > 0.0 && ringScale > 0.0) {
      final clearPaint = Paint()
        ..blendMode = BlendMode.clear
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * ringScale * 0.12 * gapWidthMultiplier;

      final rTangent = rCenter * (0.8 + 0.1 * apertureValue); 
      final double globalRotation = -math.pi / 8;

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
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ApertureLogoPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.ringRotation != ringRotation ||
        oldDelegate.coreRotation != coreRotation ||
        oldDelegate.ringScale != ringScale ||
        oldDelegate.coreScale != coreScale ||
        oldDelegate.apertureValue != apertureValue ||
        oldDelegate.gapWidthMultiplier != gapWidthMultiplier ||
        oldDelegate.segmentOpacities != segmentOpacities ||
        oldDelegate.useCoreGradient != useCoreGradient;
  }
}

enum WelcomeStage {
  intro,
  welcome,
  morphing,
  nameInput,
  apiKeyInput,
  validating,
  homeTransition,
  home,
}

class WelcomeScreenPreview extends StatefulWidget {
  const WelcomeScreenPreview({super.key});

  @override
  State<WelcomeScreenPreview> createState() => _WelcomeScreenPreviewState();
}

class _WelcomeScreenPreviewState extends State<WelcomeScreenPreview> {
  WelcomeStage _stage = WelcomeStage.intro;
  double _welcomeOpacity = 0.0;
  double _inputOpacity = 0.0;
  double _apiKeyOpacity = 0.0;
  double _homeOpacity = 0.0;
  bool _startLogoAnimation = false;
  ApertureAnimationType _logoAnimType = ApertureAnimationType.welcomeSequence;
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();
  
  bool _obscureApiKey = true;
  bool _simulateFailure = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Inicia a animação da logo logo após o primeiro frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _startLogoAnimation = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  void _onStartPressed() {
    setState(() {
      _stage = WelcomeStage.morphing;
      _welcomeOpacity = 0.0;
      _logoAnimType = ApertureAnimationType.welcomeMorph;
    });

    // Aguarda o término da animação do morph e do deslocamento (1s)
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _stage = WelcomeStage.nameInput;
          _inputOpacity = 1.0;
        });
      }
    });
  }

  void _onNameSubmitted() {
    if (_nameController.text.trim().isEmpty) return;

    setState(() {
      _inputOpacity = 0.0;
      _logoAnimType = ApertureAnimationType.drawing;
    });

    // Desvanece o form de nome e esmaece o de API Key em seguida (500ms)
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _stage = WelcomeStage.apiKeyInput;
          _apiKeyOpacity = 1.0;
        });
      }
    });
  }

  void _onApiKeySubmitted() {
    if (_apiKeyController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = "Por favor, insira a chave de API.";
      });
      return;
    }

    setState(() {
      _stage = WelcomeStage.validating;
      _apiKeyOpacity = 0.0;
      _errorMessage = null;
      _logoAnimType = ApertureAnimationType.spinAndStop;
    });

    // Simula validação (3s)
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      if (_simulateFailure) {
        // Caso de Falha: volta ao canto com a animação de desenho
        setState(() {
          _stage = WelcomeStage.apiKeyInput;
          _apiKeyOpacity = 1.0;
          _logoAnimType = ApertureAnimationType.drawing;
          _errorMessage = "Chave de API inválida. Por favor, insira uma chave válida.";
        });
      } else {
        // Caso de Sucesso: encolhe logo para a home e abre a home
        setState(() {
          _stage = WelcomeStage.homeTransition;
          _logoAnimType = ApertureAnimationType.none;
        });

        // Aguarda 1s para o movimento se completar e faz fade-in da Home
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            setState(() {
              _stage = WelcomeStage.home;
              _homeOpacity = 1.0;
              _logoAnimType = ApertureAnimationType.spin;
            });
          }
        });
      }
    });
  }

  Alignment _getLogoAlignment() {
    switch (_stage) {
      case WelcomeStage.intro:
      case WelcomeStage.welcome:
      case WelcomeStage.validating:
        return const Alignment(0.0, -0.35);
      case WelcomeStage.morphing:
      case WelcomeStage.nameInput:
      case WelcomeStage.apiKeyInput:
        return Alignment.topLeft;
      case WelcomeStage.homeTransition:
      case WelcomeStage.home:
        return const Alignment(0.0, -0.3); // Alinhamento exato no EmptyState do chat
    }
  }

  double _getLogoSize() {
    switch (_stage) {
      case WelcomeStage.intro:
      case WelcomeStage.welcome:
      case WelcomeStage.validating:
        return 150.0;
      case WelcomeStage.morphing:
      case WelcomeStage.nameInput:
      case WelcomeStage.apiKeyInput:
        return 60.0;
      case WelcomeStage.homeTransition:
      case WelcomeStage.home:
        return 80.0; // Tamanho do logo na EmptyState
    }
  }

  double _getGlowSize() {
    switch (_stage) {
      case WelcomeStage.intro:
      case WelcomeStage.welcome:
      case WelcomeStage.validating:
        return 380.0;
      case WelcomeStage.morphing:
      case WelcomeStage.nameInput:
      case WelcomeStage.apiKeyInput:
        return 120.0;
      case WelcomeStage.homeTransition:
      case WelcomeStage.home:
        return 160.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0D0F),
      body: Stack(
        children: [
          // Efeito de glow superior esquerdo (esconde na home para limpar a tela)
          if (_stage != WelcomeStage.home)
            Positioned(
              top: -80,
              left: -80,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF6C3CE9).withOpacity(0.06),
                ),
              ),
            ),
          // Efeito de glow inferior direito (esconde na home)
          if (_stage != WelcomeStage.home)
            Positioned(
              bottom: -80,
              right: -80,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF4299E1).withOpacity(0.06),
                ),
              ),
            ),
          // Glow central atrás da logo (segue o tamanho e alinhamento do container)
          if (_stage != WelcomeStage.home)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: AnimatedAlign(
                alignment: _getLogoAlignment(),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeInOutCubic,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeInOutCubic,
                  width: _getGlowSize(),
                  height: _getGlowSize(),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF6C3CE9).withOpacity(0.04),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
          // Mockup da Home Page (fades in na transição/home)
          if (_stage == WelcomeStage.homeTransition || _stage == WelcomeStage.home)
            AnimatedOpacity(
              opacity: _homeOpacity,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut,
              child: IgnorePointer(
                ignoring: _stage != WelcomeStage.home,
                child: Stack(
                  children: [
                    // Mock da AppBar
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 56,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0B0D0F),
                          border: Border(
                            bottom: BorderSide(color: Color(0xFF262930), width: 1),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            const Icon(Icons.menu, color: Colors.white70),
                            const SizedBox(width: 16),
                            // Container do Seletor de Modelo Mock
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF131619),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text(
                                    'Gemini 1.5 Flash',
                                    style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 16),
                                ],
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.add_comment_outlined, color: Colors.white70),
                          ],
                        ),
                      ),
                    ),
                    
                    // Conteúdo do EmptyState (abaixo do logo)
                    Align(
                      alignment: const Alignment(0.0, 0.18),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) {
                                return const LinearGradient(
                                  colors: [Color(0xFF4299E1), Color(0xFF6C3CE9), Color(0xFFED64A6)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(bounds);
                              },
                              child: Text(
                                'Vamos lá, ${_nameController.text}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Escreva uma mensagem ou envie uma foto para iniciar o chat com o assistente.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white.withOpacity(0.38),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Mock da barra de Input no rodapé
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: const BoxDecoration(
                          color: Color(0xFF0B0D0F),
                          border: Border(
                            top: BorderSide(color: Color(0xFF262930), width: 1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 48,
                              width: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFF131619),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.add_photo_alternate_outlined, color: Colors.white70),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF131619),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Digite uma mensagem...',
                                  style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              height: 48,
                              width: 48,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF6C3CE9),
                              ),
                              child: const Icon(Icons.arrow_upward, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          SafeArea(
            child: Stack(
              children: [
                // Logo animada e com alinhamento flexível
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: AnimatedAlign(
                    alignment: _getLogoAlignment(),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeInOutCubic,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeInOutCubic,
                      width: _getLogoSize(),
                      height: _getLogoSize(),
                      child: _startLogoAnimation
                          ? ApertureLogo(
                              size: _getLogoSize(),
                              animationType: _logoAnimType,
                              color: const Color(0xFF6C3CE9),
                              onIntroComplete: () {
                                if (mounted && _stage == WelcomeStage.intro) {
                                  setState(() {
                                    _stage = WelcomeStage.welcome;
                                    _welcomeOpacity = 1.0;
                                  });
                                }
                              },
                            )
                          : const SizedBox(),
                    ),
                  ),
                ),
                
                // Card de Boas-vindas (fade out ao clicar em Começar)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 40.0, left: 24.0, right: 24.0),
                    child: AnimatedOpacity(
                      opacity: _welcomeOpacity,
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOut,
                      child: IgnorePointer(
                        ignoring: _stage != WelcomeStage.welcome,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Título com gradiente premium
                            ShaderMask(
                              shaderCallback: (bounds) {
                                return const LinearGradient(
                                  colors: [
                                    Color(0xFF4299E1),
                                    Color(0xFF6C3CE9),
                                    Color(0xFFED64A6),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(bounds);
                              },
                              child: const Text(
                                'AI Chat',
                                style: TextStyle(
                                  fontSize: 44,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Bem-vindo ao seu assistente de IA',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 0.5),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Conecte-se com o Gemini para criar, aprender e conversar de forma inteligente.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.5),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 48),
                            // Botão "Começar" estilo premium
                            Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF4299E1),
                                    Color(0xFF6C3CE9),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF6C3CE9).withOpacity(0.25),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _onStartPressed,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'Começar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Formulário do Nome do Usuário (fade in após o morph)
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: AnimatedOpacity(
                      opacity: _inputOpacity,
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOut,
                      child: IgnorePointer(
                        ignoring: _stage != WelcomeStage.nameInput,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Como posso te chamar?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Digite seu nome para iniciar a conversa.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                            const SizedBox(height: 36),
                            // Campo de texto minimalista premium
                            TextField(
                              controller: _nameController,
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                              decoration: InputDecoration(
                                hintText: 'Seu nome...',
                                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                                filled: true,
                                fillColor: const Color(0xFF131619),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFF6C3CE9), width: 2),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Botão Continuar
                            Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF4299E1),
                                    Color(0xFF6C3CE9),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF6C3CE9).withOpacity(0.25),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _onNameSubmitted,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'Continuar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Formulário de Chave de API do Gemini (fade in após continuar nome)
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: AnimatedOpacity(
                      opacity: _apiKeyOpacity,
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOut,
                      child: IgnorePointer(
                        ignoring: _stage != WelcomeStage.apiKeyInput,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Chave de API do Gemini',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Insira sua chave de API para habilitar as respostas do modelo.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                            const SizedBox(height: 36),
                            // Campo de texto password-style para API key
                            TextField(
                              controller: _apiKeyController,
                              obscureText: _obscureApiKey,
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                              decoration: InputDecoration(
                                hintText: 'AIzaSy...',
                                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                                filled: true,
                                fillColor: const Color(0xFF131619),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureApiKey ? Icons.visibility_off : Icons.visibility,
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureApiKey = !_obscureApiKey;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFF6C3CE9), width: 2),
                                ),
                              ),
                            ),
                            if (_errorMessage != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                              ),
                            ],
                            const SizedBox(height: 16),
                            // Checkbox para simular falha na validação
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Checkbox(
                                  value: _simulateFailure,
                                  activeColor: const Color(0xFF6C3CE9),
                                  onChanged: (val) {
                                    setState(() {
                                      _simulateFailure = val ?? false;
                                    });
                                  },
                                ),
                                const Text(
                                  'Simular falha de validação',
                                  style: TextStyle(color: Colors.white70, fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Link de ajuda para obter chave de API
                            GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Acesse: https://aistudio.google.com/'),
                                    backgroundColor: Color(0xFF6C3CE9),
                                  ),
                                );
                              },
                              child: const Text(
                                'Como obter uma chave de API gratuita?',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF4299E1),
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Botão Finalizar
                            Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF4299E1),
                                    Color(0xFF6C3CE9),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF6C3CE9).withOpacity(0.25),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _onApiKeySubmitted,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'Concluir',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
