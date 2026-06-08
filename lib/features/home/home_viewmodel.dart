import 'package:flutter/material.dart';
import 'package:result_command/result_command.dart';
import 'package:result_dart/result_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../domain/entities/chat_session.dart';
import '../../../domain/entities/chat_message.dart';
import '../../../domain/repositories/chat_repository.dart';
import '../../../domain/validators/api_key_validator.dart';

class HomeViewModel extends ChangeNotifier {
  final ChatRepository _repository;
  final ApiKeyValidator _apiKeyValidator;

  HomeViewModel(this._repository, this._apiKeyValidator) {
    _init();
    loadSessionsCommand.addListener(notifyListeners);
    selectSessionCommand.addListener(notifyListeners);
    createSessionCommand.addListener(notifyListeners);
    deleteSessionCommand.addListener(notifyListeners);
    sendMessageCommand.addListener(notifyListeners);
    loadModelsCommand.addListener(notifyListeners);
  }

  @override
  void dispose() {
    loadSessionsCommand.removeListener(notifyListeners);
    selectSessionCommand.removeListener(notifyListeners);
    createSessionCommand.removeListener(notifyListeners);
    deleteSessionCommand.removeListener(notifyListeners);
    sendMessageCommand.removeListener(notifyListeners);
    loadModelsCommand.removeListener(notifyListeners);
    super.dispose();
  }

  List<ChatSession> _sessions = [];
  List<ChatSession> get sessions => _sessions;

  ChatSession? _currentSession;
  ChatSession? get currentSession => _currentSession;

  List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => _messages;

  String _selectedModel = 'gemini-3.5-flash';
  String get selectedModel => _selectedModel;

  List<String> _availableModels = [
    'gemini-3.5-flash',
    'gemini-3.1-flash-lite',
    'gemini-2.5-flash',
  ];
  List<String> get availableModels => _availableModels;

  String? _attachedImagePath;
  String? get attachedImagePath => _attachedImagePath;

  String _apiKey = '';
  String get apiKey => _apiKey;

  String _userName = 'Alex';
  String get userName => _userName;

  String? _apiKeyValidationError;
  String? get apiKeyValidationError => _apiKeyValidationError;

  String? _sendMessageError;
  String? get sendMessageError => _sendMessageError;

  void clearSendMessageError() {
    _sendMessageError = null;
    notifyListeners();
  }

  late final loadSessionsCommand = Command0<List<ChatSession>>(loadSessions);

  AsyncResult<List<ChatSession>> loadSessions() async {
    final result = await _repository.getSessions();
    return result.map((list) {
      _sessions = list;
      notifyListeners();
      return list;
    });
  }

  late final loadModelsCommand = Command0<List<String>>(getAvailableModels);

  AsyncResult<List<String>> getAvailableModels() async {
    final result = await _repository.getAvailableModels();
    return result.map((list) {
      final defaults = [
        'gemini-3.5-flash',
        'gemini-3.1-flash-lite',
        'gemini-2.5-flash',
      ];
      if (list.isNotEmpty) {
        final merged = <String>{
          ...defaults,
          ...list,
        }.toList();
        _availableModels = merged;
      } else {
        _availableModels = defaults;
      }
      notifyListeners();
      return _availableModels;
    });
  }

  late final selectSessionCommand = Command1<List<ChatMessage>, ChatSession>(
    selectSession,
  );

  AsyncResult<List<ChatMessage>> selectSession(ChatSession session) async {
    _currentSession = session;
    if (!_availableModels.contains(session.model)) {
      _availableModels = [..._availableModels, session.model];
    }
    _selectedModel = session.model;
    notifyListeners();
    final result = await _repository.getMessages(session.id);
    return result.map((list) {
      _messages = list;
      notifyListeners();
      return list;
    });
  }

  late final createSessionCommand = Command0<ChatSession>(createSession);

  AsyncResult<ChatSession> createSession() async {
    final result = await _repository.createSession(_selectedModel);
    return result.map((session) {
      _currentSession = session;
      _messages = [];
      loadSessionsCommand.execute();
      notifyListeners();
      return session;
    });
  }

  late final deleteSessionCommand = Command1<Unit, String>(deleteSession);

  AsyncResult<Unit> deleteSession(String sessionId) async {
    final result = await _repository.deleteSession(sessionId);
    return result.map((_) {
      if (_currentSession?.id == sessionId) {
        _currentSession = null;
        _messages = [];
      }
      loadSessionsCommand.execute();
      notifyListeners();
      return unit;
    });
  }

  late final sendMessageCommand = Command1<ChatMessage, String>(sendMessage);

  AsyncResult<ChatMessage> sendMessage(String content) async {
    if (_currentSession == null) {
      final sessionResult = await _repository.createSession(_selectedModel);
      if (sessionResult.isError()) {
        return Failure(sessionResult.exceptionOrNull()!);
      }
      _currentSession = sessionResult.getOrNull();
      _messages = [];
      notifyListeners();
    }

    final sessionId = _currentSession!.id;
    final imagePath = _attachedImagePath;

    _attachedImagePath = null;

    final tempUserMessage = ChatMessage(
      id: 'msg_user_temp_${DateTime.now().millisecondsSinceEpoch}',
      sessionId: sessionId,
      role: 'user',
      content: content,
      imagePath: imagePath,
      createdAt: DateTime.now(),
    );

    final tempModelMessage = ChatMessage(
      id: 'msg_model_temp_${DateTime.now().millisecondsSinceEpoch}',
      sessionId: sessionId,
      role: 'model',
      content: '',
      createdAt: DateTime.now(),
    );

    _messages = List.from(_messages)
      ..add(tempUserMessage)
      ..add(tempModelMessage);
    notifyListeners();

    try {
      final stream = _repository.sendMessageStream(
        sessionId,
        content,
        imagePath,
        _selectedModel,
      );

      String currentResponse = '';

      await for (final chunkResult in stream) {
        if (chunkResult.isSuccess()) {
          currentResponse += chunkResult.getOrNull()!;
          final updatedMsg = tempModelMessage.copyWith(
            content: currentResponse,
          );
          _messages = List.from(_messages);
          _messages[_messages.length - 1] = updatedMsg;
          notifyListeners();
        } else {
          final error = chunkResult.exceptionOrNull()!;
          _sendMessageError = error.toString().replaceAll('Exception: ', '');
          await _loadMessagesForCurrentSession();
          notifyListeners();
          return Failure(error);
        }
      }

      await _loadMessagesForCurrentSession();
      loadSessionsCommand.execute();
      return Success(_messages.last);
    } catch (e) {
      _sendMessageError = e.toString().replaceAll('Exception: ', '');
      await _loadMessagesForCurrentSession();
      notifyListeners();
      return Failure(Exception(e.toString()));
    }
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _apiKey = prefs.getString('gemini_api_key') ?? '';
    _userName = prefs.getString('user_name') ?? 'Alex';
    notifyListeners();

    await loadSessionsCommand.execute();

    if (_sessions.isNotEmpty) {
      selectSessionCommand.execute(_sessions.first);
    } else {
      createSessionCommand.execute();
    }
  }

  void selectModel(String model) {
    _selectedModel = model;
    if (_currentSession != null) {
      _repository.updateSessionModel(_currentSession!.id, model);
      _currentSession = ChatSession(
        id: _currentSession!.id,
        title: _currentSession!.title,
        model: model,
        createdAt: _currentSession!.createdAt,
      );
      loadSessionsCommand.execute();
    }
    notifyListeners();
  }

  void attachImage(String? path) {
    _attachedImagePath = path;
    notifyListeners();
  }

  Future<Result<Unit>> saveApiKey(String key) async {
    final validationResult = _apiKeyValidator.validate(key);
    if (!validationResult.isValid) {
      _apiKeyValidationError = validationResult.exceptions
          .map((e) => e.message)
          .join(', ');
      notifyListeners();
      return Failure(Exception(_apiKeyValidationError));
    }

    _apiKeyValidationError = null;
    _apiKey = key;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gemini_api_key', key);

    await loadModelsCommand.execute();

    notifyListeners();
    return const Success(unit);
  }

  Future<void> saveUserName(String name) async {
    _userName = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    notifyListeners();
  }

  Future<void> _loadMessagesForCurrentSession() async {
    if (_currentSession != null) {
      final result = await _repository.getMessages(_currentSession!.id);
      if (result.isSuccess()) {
        _messages = result.getOrNull()!;
        notifyListeners();
      }
    }
  }
}
