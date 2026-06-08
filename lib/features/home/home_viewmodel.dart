import 'package:flutter/material.dart';
import 'package:result_command/result_command.dart';
import 'package:result_dart/result_dart.dart';
import '../../../domain/entities/chat_session.dart';
import '../../../domain/entities/chat_message.dart';
import '../../../domain/repositories/chat_repository.dart';
import '../../../domain/repositories/settings_repository.dart';
import '../../../domain/validators/api_key_validator.dart';

class HomeViewModel extends ChangeNotifier {
  final ChatRepository _chatRepository;
  final SettingsRepository _settingsRepository;
  final ApiKeyValidator _apiKeyValidator;

  HomeViewModel(
    this._chatRepository,
    this._settingsRepository,
    this._apiKeyValidator,
  ) {
    loadSessionsCommand.addListener(notifyListeners);
    selectSessionCommand.addListener(notifyListeners);
    createSessionCommand.addListener(notifyListeners);
    deleteSessionCommand.addListener(notifyListeners);
    sendMessageCommand.addListener(notifyListeners);
    loadModelsCommand.addListener(notifyListeners);
  }

  @override
  void dispose() {
    loadSessionsCommand.dispose();
    selectSessionCommand.dispose();
    createSessionCommand.dispose();
    deleteSessionCommand.dispose();
    sendMessageCommand.dispose();
    loadModelsCommand.dispose();
    super.dispose();
  }

  // --- Estados ---
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

  String? _apiKeyValidationError;
  String? get apiKeyValidationError => _apiKeyValidationError;

  // Usa o repositório para os dados locais, não mais variáveis perdidas
  String get apiKey => _settingsRepository.apiKey;
  String get userName => _settingsRepository.userName;

  // --- Inicialização ---
  Future<void> init() async {
    await loadSessionsCommand.execute();

    if (_sessions.isNotEmpty) {
      selectSessionCommand.execute(_sessions.first);
    } else {
      createSessionCommand.execute();
    }
  }

  // --- Comandos ---
  late final loadSessionsCommand = Command0<List<ChatSession>>(() async {
    final result = await _chatRepository.getSessions();
    return result.map((list) {
      _sessions = list;
      return list;
    });
  });

  late final loadModelsCommand = Command0<List<String>>(() async {
    final result = await _chatRepository.getAvailableModels();
    return result.map((list) {
      if (list.isNotEmpty) {
        // Une defaults com os carregados, evitando duplicatas
        _availableModels = {..._availableModels, ...list}.toList();
      }
      return _availableModels;
    });
  });

  late final selectSessionCommand = Command1<List<ChatMessage>, ChatSession>((session) async {
    _currentSession = session;
    if (!_availableModels.contains(session.model)) {
      _availableModels = [..._availableModels, session.model];
    }
    _selectedModel = session.model;
    
    // Mostra as mensagens da sessão
    final result = await _chatRepository.getMessages(session.id);
    return result.map((list) {
      _messages = list;
      return list;
    });
  });

  late final createSessionCommand = Command0<ChatSession>(() async {
    final result = await _chatRepository.createSession(_selectedModel);
    return result.map((session) {
      _currentSession = session;
      _messages = [];
      loadSessionsCommand.execute(); // Atualiza a lista lateral
      return session;
    });
  });

  late final deleteSessionCommand = Command1<Unit, String>((sessionId) async {
    final result = await _chatRepository.deleteSession(sessionId);
    return result.map((_) {
      if (_currentSession?.id == sessionId) {
        _currentSession = null;
        _messages = [];
      }
      loadSessionsCommand.execute();
      return unit;
    });
  });

  late final sendMessageCommand = Command1<ChatMessage, String>((content) async {
    // 1. Garante que exista uma sessão
    if (_currentSession == null) {
      final sessionResult = await _chatRepository.createSession(_selectedModel);
      if (sessionResult.isError()) {
        return Failure(sessionResult.exceptionOrNull()!);
      }
      _currentSession = sessionResult.getOrNull();
      _messages = [];
    }

    final sessionId = _currentSession!.id;
    final imagePath = _attachedImagePath;
    _attachedImagePath = null; // Limpa o anexo

    // 2. Insere balões temporários na UI para feedback instantâneo
    final tempUserMessage = ChatMessage(
      id: 'temp_user',
      sessionId: sessionId,
      role: 'user',
      content: content,
      imagePath: imagePath,
      createdAt: DateTime.now(),
    );
    final tempModelMessage = ChatMessage(
      id: 'temp_model',
      sessionId: sessionId,
      role: 'model',
      content: '', // Vazio enquanto digita
      createdAt: DateTime.now(),
    );

    _messages = [..._messages, tempUserMessage, tempModelMessage];
    notifyListeners();

    // 3. Comunicação em Stream com a IA
    try {
      final stream = _chatRepository.sendMessageStream(
        sessionId,
        content,
        imagePath,
        _selectedModel,
      );

      String currentResponse = '';
      await for (final chunkResult in stream) {
        if (chunkResult.isSuccess()) {
          currentResponse += chunkResult.getOrNull()!;
          _messages.last = tempModelMessage.copyWith(content: currentResponse);
          notifyListeners();
        } else {
          // Em caso de erro no chunk, restaura do banco
          await _loadMessagesForCurrentSession();
          return Failure(chunkResult.exceptionOrNull()!);
        }
      }

      await _loadMessagesForCurrentSession();
      loadSessionsCommand.execute(); // Atualiza o título na drawer
      return Success(_messages.last);
    } catch (e) {
      await _loadMessagesForCurrentSession();
      return Failure(Exception(e.toString()));
    }
  });

  // --- Funções Auxiliares (Síncronas / Configuracionais) ---
  void selectModel(String model) {
    _selectedModel = model;
    
    if (_currentSession != null) {
      // 1. Atualiza no banco (dispara e esquece)
      _chatRepository.updateSessionModel(_currentSession!.id, model);
      
      // 2. Atualiza a referência atual
      _currentSession = ChatSession(
        id: _currentSession!.id,
        title: _currentSession!.title,
        model: model,
        createdAt: _currentSession!.createdAt,
      );
      
      // 3. Atualiza a sessão na lista local (sem ir no banco)
      final index = _sessions.indexWhere((s) => s.id == _currentSession!.id);
      if (index != -1) {
        _sessions[index] = _currentSession!;
      }
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
      _apiKeyValidationError = validationResult.exceptions.map((e) => e.message).join(', ');
      notifyListeners();
      return Failure(Exception(_apiKeyValidationError));
    }

    _apiKeyValidationError = null;
    await _settingsRepository.saveApiKey(key);
    await loadModelsCommand.execute();
    notifyListeners();
    return const Success(unit);
  }

  Future<void> saveUserName(String name) async {
    await _settingsRepository.saveUserName(name);
    notifyListeners();
  }

  Future<void> _loadMessagesForCurrentSession() async {
    if (_currentSession != null) {
      final result = await _chatRepository.getMessages(_currentSession!.id);
      if (result.isSuccess()) {
        _messages = result.getOrNull()!;
        notifyListeners();
      }
    }
  }
}
