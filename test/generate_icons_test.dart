import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_chat/logo_widget.dart';

void main() {
  test('Gera os PNGs de ícones a partir do ApertureLogoPainter', () async {
    const int size = 1024;
    final File iconFile = File('assets/icon.png');
    final File iconForegroundFile = File('assets/icon_foreground.png');

    // Cria o diretório de assets se não existir
    final Directory assetsDir = Directory('assets');
    if (!await assetsDir.exists()) {
      await assetsDir.create();
    }

    final painter = ApertureLogoPainter(
      color: const Color(0xFF6C3CE9),
      ringRotation: 0.0,
      coreRotation: 0.0,
      ringScale: 1.0,
      coreScale: 1.0,
      apertureValue: 1.0,
      gapWidthMultiplier: 1.0,
      segmentOpacities: List.filled(8, 1.0),
      useCoreGradient: false,
    );

    // 1. Gerar assets/icon_foreground.png (Fundo Transparente para Android Adaptive Icon)
    final recorderTrans = ui.PictureRecorder();
    final canvasTrans = Canvas(recorderTrans);
    
    canvasTrans.save();
    // Escala de 0.65 para que caiba na zona segura (safe zone) circular de Adaptive Icons
    const double scaleTrans = 0.65;
    const double offsetTrans = (size * (1 - scaleTrans)) / 2;
    canvasTrans.translate(offsetTrans, offsetTrans);
    canvasTrans.scale(scaleTrans);
    
    painter.paint(canvasTrans, Size(size.toDouble(), size.toDouble()));
    canvasTrans.restore();

    final pictureTrans = recorderTrans.endRecording();
    final imgTrans = await pictureTrans.toImage(size, size);
    final byteDataTrans = await imgTrans.toByteData(format: ui.ImageByteFormat.png);
    final bytesTrans = byteDataTrans!.buffer.asUint8List();
    await iconForegroundFile.writeAsBytes(bytesTrans);
    print('Foreground transparente gerado em: ${iconForegroundFile.path}');

    // 2. Gerar assets/icon.png (Com Fundo Opaco #0B0D0F para iOS, Windows, Web, Legados)
    final recorderBg = ui.PictureRecorder();
    final canvasBg = Canvas(recorderBg);

    // Pintar fundo escuro
    final paintBg = Paint()..color = const Color(0xFF0B0D0F);
    canvasBg.drawRect(Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()), paintBg);

    canvasBg.save();
    // Escala de 0.80 para uma boa margem de respiro nos sistemas operacionais
    const double scaleBg = 0.80;
    const double offsetBg = (size * (1 - scaleBg)) / 2;
    canvasBg.translate(offsetBg, offsetBg);
    canvasBg.scale(scaleBg);

    painter.paint(canvasBg, Size(size.toDouble(), size.toDouble()));
    canvasBg.restore();

    final pictureBg = recorderBg.endRecording();
    final imgBg = await pictureBg.toImage(size, size);
    final byteDataBg = await imgBg.toByteData(format: ui.ImageByteFormat.png);
    final bytesBg = byteDataBg!.buffer.asUint8List();
    await iconFile.writeAsBytes(bytesBg);
    print('Ícone com fundo opaco gerado em: ${iconFile.path}');
  });
}
