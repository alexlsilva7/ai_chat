import '../../../domain/entities/chat_session.dart';
import '../../../domain/entities/chat_message.dart';

abstract class ChatLocalDataSource {
  Future<List<ChatSession>> getSessions();
  Future<void> saveSession(ChatSession session);
  Future<void> deleteSession(String id);
  
  Future<List<ChatMessage>> getMessages(String sessionId);
  Future<void> saveMessage(ChatMessage message);
  
  Future<void> updateSessionTitle(String sessionId, String title);
  Future<void> updateSessionModel(String sessionId, String model);
}
