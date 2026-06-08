import 'package:flutter/material.dart';
import 'package:result_command/result_command.dart';
import 'package:result_dart/result_dart.dart';
import '../../../../domain/entities/chat_message.dart';
import '../../../../domain/repositories/chat_repository.dart';

class SendMessagePayload {
  final String sessionId;
  final String content;
  final String model;
  final String? imagePath;

  SendMessagePayload({
    required this.sessionId,
    required this.content,
    required this.model,
    this.imagePath,
  });
}

class ChatViewModel extends ChangeNotifier {
  final ChatRepository _chatRepository;

  ChatViewModel(this._chatRepository);

  @override
  void dispose() {
    loadMessagesCommand.dispose();
    sendMessageCommand.dispose();
    super.dispose();
  }

  List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => _messages;

  String? _attachedImagePath;
  String? get attachedImagePath => _attachedImagePath;

  late final loadMessagesCommand = Command1<List<ChatMessage>, String>((sessionId) async {
    final result = await _chatRepository.getMessages(sessionId);
    return result.map((list) {
      _messages = list;
      notifyListeners();
      return list;
    });
  });

  late final sendMessageCommand = Command1<ChatMessage, SendMessagePayload>((payload) async {
    _attachedImagePath = null;

    final tempUserMessage = ChatMessage(
      id: 'temp_user',
      sessionId: payload.sessionId,
      role: 'user',
      content: payload.content,
      imagePath: payload.imagePath,
      createdAt: DateTime.now(),
    );
    final tempModelMessage = ChatMessage(
      id: 'temp_model',
      sessionId: payload.sessionId,
      role: 'model',
      content: '', 
      createdAt: DateTime.now(),
    );

    _messages = [..._messages, tempUserMessage, tempModelMessage];
    notifyListeners();

    try {
      final stream = _chatRepository.sendMessageStream(
        payload.sessionId,
        payload.content,
        payload.imagePath,
        payload.model,
      );

      String currentResponse = '';
      await for (final chunkResult in stream) {
        if (chunkResult.isSuccess()) {
          currentResponse += chunkResult.getOrNull()!;
          _messages = [
            ..._messages.sublist(0, _messages.length - 1),
            tempModelMessage.copyWith(content: currentResponse)
          ];
          notifyListeners();
        } else {
          loadMessagesCommand.execute(payload.sessionId);
          return Failure(chunkResult.exceptionOrNull()!);
        }
      }

      loadMessagesCommand.execute(payload.sessionId);
      return Success(_messages.last);
    } catch (e) {
      loadMessagesCommand.execute(payload.sessionId);
      return Failure(Exception(e.toString()));
    }
  });

  void attachImage(String? path) {
    _attachedImagePath = path;
    notifyListeners();
  }

  void clearMessages() {
    _messages = [];
    notifyListeners();
  }
}
