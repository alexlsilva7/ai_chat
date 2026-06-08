import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../domain/entities/chat_message.dart';
import 'ia_service.dart';

class GeminiIAService implements IAService {
  @override
  Future<String> generateContent({
    required String apiKey,
    required String model,
    required List<ChatMessage> history,
    required String currentPrompt,
    String? currentImagePath,
  }) async {
    String apiModelName = model;

    // Mapeamento especial para garantir compatibilidade caso nomes legíveis sejam informados
    if (model == 'Gemini 1.5 Flash') {
      apiModelName = 'gemini-1.5-flash';
    } else if (model == 'Gemini 1.5 Pro') {
      apiModelName = 'gemini-1.5-pro';
    } else if (model == 'Gemini 2.5 Flash') {
      apiModelName = 'gemini-2.5-flash';
    }

    final generativeModel = GenerativeModel(
      model: apiModelName,
      apiKey: apiKey,
    );

    final List<Content> contents = [];

    // 1. Mapear o histórico
    for (final msg in history) {
      final role = msg.role == 'user' ? 'user' : 'model';
      contents.add(Content(role, [TextPart(msg.content)]));
    }

    // 2. Mapear prompt atual e imagem
    final List<Part> currentParts = [];

    if (currentImagePath != null) {
      final file = File(currentImagePath);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();

        String mimeType = 'image/jpeg';
        if (currentImagePath.toLowerCase().endsWith('.png')) {
          mimeType = 'image/png';
        } else if (currentImagePath.toLowerCase().endsWith('.webp')) {
          mimeType = 'image/webp';
        } else if (currentImagePath.toLowerCase().endsWith('.gif')) {
          mimeType = 'image/gif';
        }

        currentParts.add(DataPart(mimeType, bytes));
      }
    }

    currentParts.add(TextPart(currentPrompt));
    contents.add(Content('user', currentParts));

    // 3. Gerar conteúdo
    final response = await generativeModel.generateContent(contents);

    if (response.text != null) {
      return response.text!;
    } else {
      throw Exception('Nenhum conteúdo retornado pelo modelo Gemini.');
    }
  }

  @override
  Stream<String> generateContentStream({
    required String apiKey,
    required String model,
    required List<ChatMessage> history,
    required String currentPrompt,
    String? currentImagePath,
  }) async* {
    String apiModelName = model;

    if (model == 'Gemini 1.5 Flash') {
      apiModelName = 'gemini-1.5-flash';
    } else if (model == 'Gemini 1.5 Pro') {
      apiModelName = 'gemini-1.5-pro';
    } else if (model == 'Gemini 2.5 Flash') {
      apiModelName = 'gemini-2.5-flash';
    }

    final generativeModel = GenerativeModel(
      model: apiModelName,
      apiKey: apiKey,
    );

    final List<Content> contents = [];

    for (final msg in history) {
      final role = msg.role == 'user' ? 'user' : 'model';
      contents.add(Content(role, [TextPart(msg.content)]));
    }

    final List<Part> currentParts = [];

    if (currentImagePath != null) {
      final file = File(currentImagePath);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        String mimeType = 'image/jpeg';
        if (currentImagePath.toLowerCase().endsWith('.png')) {
          mimeType = 'image/png';
        } else if (currentImagePath.toLowerCase().endsWith('.webp')) {
          mimeType = 'image/webp';
        } else if (currentImagePath.toLowerCase().endsWith('.gif')) {
          mimeType = 'image/gif';
        }
        currentParts.add(DataPart(mimeType, bytes));
      }
    }

    currentParts.add(TextPart(currentPrompt));
    contents.add(Content('user', currentParts));

    final responseStream = generativeModel.generateContentStream(contents);

    await for (final chunk in responseStream) {
      if (chunk.text != null) {
        yield chunk.text!;
      }
    }
  }

  @override
  Future<List<String>> getAvailableModels(String apiKey) async {
    try {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final models = data['models'] as List;

        final List<String> modelNames = [];
        for (final m in models) {
          final name = m['name'] as String;
          final supportedMethods = m['supportedGenerationMethods'] as List;
          if (supportedMethods.contains('generateContent')) {
            // Limpa o prefixo "models/"
            modelNames.add(name.replaceFirst('models/', ''));
          }
        }
        return modelNames;
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
