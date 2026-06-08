import '../../../domain/entities/chat_message.dart';

abstract class IAService {
  Future<String> generateContent({
    required String apiKey,
    required String model,
    required List<ChatMessage> history,
    required String currentPrompt,
    String? currentImagePath,
  });

  Stream<String> generateContentStream({
    required String apiKey,
    required String model,
    required List<ChatMessage> history,
    required String currentPrompt,
    String? currentImagePath,
  });

  Future<List<String>> getAvailableModels(String apiKey);
}
