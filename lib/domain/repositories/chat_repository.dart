import 'package:result_dart/result_dart.dart';
import '../entities/chat_session.dart';
import '../entities/chat_message.dart';

abstract class ChatRepository {
  Future<Result<List<ChatSession>>> getSessions();
  Future<Result<ChatSession>> createSession(String model);
  Future<Result<Unit>> deleteSession(String id);
  Future<Result<List<ChatMessage>>> getMessages(String sessionId);
  Future<Result<ChatMessage>> sendMessage(String sessionId, String content, String? imagePath, String model);
  Stream<Result<String>> sendMessageStream(String sessionId, String content, String? imagePath, String model);
  Future<Result<List<String>>> getAvailableModels();
  Future<Result<Unit>> updateSessionModel(String sessionId, String model);
}
