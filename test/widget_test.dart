import 'package:flutter_test/flutter_test.dart';
import 'package:ai_chat/domain/entities/chat_session.dart';
import 'package:ai_chat/domain/entities/chat_message.dart';

void main() {
  group('Testes de Entidades - Serialização', () {
    test('Conversão de ChatSession de/para Map', () {
      final date = DateTime.now();
      final session = ChatSession(
        id: '123',
        title: 'Conversa de Teste',
        model: 'gemini-1.5-flash',
        createdAt: date,
      );

      final map = session.toMap();
      expect(map['id'], '123');
      expect(map['title'], 'Conversa de Teste');
      expect(map['model'], 'gemini-1.5-flash');
      expect(map['created_at'], date.millisecondsSinceEpoch);

      final fromMap = ChatSession.fromMap(map);
      expect(fromMap.id, '123');
      expect(fromMap.title, 'Conversa de Teste');
      expect(fromMap.model, 'gemini-1.5-flash');
      expect(fromMap.createdAt.millisecondsSinceEpoch, date.millisecondsSinceEpoch);
    });

    test('Conversão de ChatMessage de/para Map', () {
      final date = DateTime.now();
      final message = ChatMessage(
        id: 'msg_1',
        sessionId: '123',
        role: 'user',
        content: 'Olá Gemini!',
        imagePath: '/path/to/image.jpg',
        createdAt: date,
      );

      final map = message.toMap();
      expect(map['id'], 'msg_1');
      expect(map['session_id'], '123');
      expect(map['role'], 'user');
      expect(map['content'], 'Olá Gemini!');
      expect(map['image_path'], '/path/to/image.jpg');
      expect(map['created_at'], date.millisecondsSinceEpoch);

      final fromMap = ChatMessage.fromMap(map);
      expect(fromMap.id, 'msg_1');
      expect(fromMap.sessionId, '123');
      expect(fromMap.role, 'user');
      expect(fromMap.content, 'Olá Gemini!');
      expect(fromMap.imagePath, '/path/to/image.jpg');
      expect(fromMap.createdAt.millisecondsSinceEpoch, date.millisecondsSinceEpoch);
    });
  });
}
