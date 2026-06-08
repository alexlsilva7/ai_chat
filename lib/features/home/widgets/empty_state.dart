import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../../../logo_widget.dart';
import '../../../core/ui/theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  final String userName;
  const EmptyState({super.key, this.userName = 'Alex'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Hero(
              tag: 'aperture_logo',
              child: ApertureLogo(
                size: 80,
                animationType: ApertureAnimationType.spin,
              ),
            ),
            const SizedBox(height: 24),
            ShaderMask(
              shaderCallback: (bounds) {
                return AppTheme.geminiGradient.createShader(bounds);
              },
              child: Text(
                'Vamos lá, $userName',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white38,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

@Preview(name: 'Empty State')
Widget emptyStatePreview() {
  return const Scaffold(
    backgroundColor: Colors.black, // O fundo é escuro no app
    body: EmptyState(),
  );
}
