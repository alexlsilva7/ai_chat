import 'package:flutter/material.dart';
import 'package:result_command/result_command.dart';
import 'package:result_dart/result_dart.dart';
import '../../../../domain/entities/chat_session.dart';
import '../../../../domain/repositories/chat_repository.dart';

class SessionViewModel extends ChangeNotifier {
  final ChatRepository _chatRepository;

  SessionViewModel(this._chatRepository);

  @override
  void dispose() {
    loadSessionsCommand.dispose();
    createSessionCommand.dispose();
    deleteSessionCommand.dispose();
    super.dispose();
  }

  List<ChatSession> _sessions = [];
  List<ChatSession> get sessions => _sessions;

  ChatSession? _currentSession;
  ChatSession? get currentSession => _currentSession;

  Future<void> init() async {
    await loadSessionsCommand.execute();
    if (_sessions.isNotEmpty) {
      selectSession(_sessions.first);
    }
  }

  late final loadSessionsCommand = Command0<List<ChatSession>>(() async {
    final result = await _chatRepository.getSessions();
    return result.map((list) {
      _sessions = list;
      notifyListeners();
      return list;
    });
  });

  late final createSessionCommand = Command1<ChatSession, String>((model) async {
    final result = await _chatRepository.createSession(model);
    return result.map((session) {
      _currentSession = session;
      notifyListeners();
      loadSessionsCommand.execute(); 
      return session;
    });
  });

  late final deleteSessionCommand = Command1<Unit, String>((sessionId) async {
    final result = await _chatRepository.deleteSession(sessionId);
    return result.map((_) {
      if (_currentSession?.id == sessionId) {
        clearCurrentSession();
      }
      loadSessionsCommand.execute();
      return unit;
    });
  });

  void selectSession(ChatSession session) {
    _currentSession = session;
    notifyListeners();
  }

  void clearCurrentSession() {
    _currentSession = null;
    notifyListeners();
  }

  Future<void> updateSessionModel(String model) async {
    if (_currentSession != null) {
      await _chatRepository.updateSessionModel(_currentSession!.id, model);
      _currentSession = ChatSession(
        id: _currentSession!.id,
        title: _currentSession!.title,
        model: model,
        createdAt: _currentSession!.createdAt,
      );
      notifyListeners();
      loadSessionsCommand.execute();
    }
  }
}
