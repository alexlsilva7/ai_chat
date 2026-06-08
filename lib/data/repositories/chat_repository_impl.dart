import 'dart:developer';

import 'package:result_dart/result_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/chat_session.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/local/chat_local_datasource.dart';
import '../datasources/remote/ia_service.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatLocalDataSource _localDataSource;
  final IAService _iaService;

  ChatRepositoryImpl(this._localDataSource, this._iaService);

  @override
  Future<Result<List<ChatSession>>> getSessions() async {
    try {
      final sessions = await _localDataSource.getSessions();
      return Success(sessions);
    } catch (e) {
      log('Erro ao obter sessões de chat: $e');
      return Failure(Exception('Falha ao obter sessões locais: $e'));
    }
  }

  @override
  Future<Result<ChatSession>> createSession(String model) async {
    try {
      final session = ChatSession(
        id: 'session_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Nova Conversa',
        model: model,
        createdAt: DateTime.now(),
      );
      await _localDataSource.saveSession(session);
      return Success(session);
    } catch (e) {
      log('Erro ao criar sessão de chat: $e');
      return Failure(Exception('Falha ao criar sessão de chat: $e'));
    }
  }

  @override
  Future<Result<Unit>> deleteSession(String id) async {
    try {
      await _localDataSource.deleteSession(id);
      return const Success(unit);
    } catch (e) {
      log('Erro ao deletar sessão de chat: $e');
      return Failure(Exception('Falha ao deletar sessão de chat: $e'));
    }
  }

  @override
  Future<Result<List<ChatMessage>>> getMessages(String sessionId) async {
    try {
      final messages = await _localDataSource.getMessages(sessionId);
      return Success(messages);
    } catch (e) {
      log('Erro ao obter mensagens de chat: $e');
      return Failure(Exception('Falha ao obter mensagens locais: $e'));
    }
  }

  @override
  Future<Result<ChatMessage>> sendMessage(
    String sessionId,
    String content,
    String? imagePath,
    String model,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final apiKey = prefs.getString('gemini_api_key') ?? '';

      if (apiKey.isEmpty) {
        return Failure(
          Exception(
            'API Key do Gemini não está configurada! Por favor, configure-a no menu lateral.',
          ),
        );
      }

      // 1. Criar e salvar mensagem do usuário
      final userMessage = ChatMessage(
        id: 'msg_user_${DateTime.now().millisecondsSinceEpoch}',
        sessionId: sessionId,
        role: 'user',
        content: content,
        imagePath: imagePath,
        createdAt: DateTime.now(),
      );
      await _localDataSource.saveMessage(userMessage);

      // 2. Carregar o histórico da sessão
      final history = await _localDataSource.getMessages(sessionId);

      // 3. Atualizar título da sessão se for a primeira mensagem
      if (history.length == 1) {
        String newTitle = content;
        if (content.length > 30) {
          newTitle = '${content.substring(0, 27)}...';
        }
        await _localDataSource.updateSessionTitle(sessionId, newTitle);
      }

      // 4. Preparar histórico para a API (excluindo a que acabamos de adicionar, pois é passada separadamente no generateContent)
      final historyForAPI = history.sublist(0, history.length - 1);

      // 5. Enviar requisição para a IA
      final responseText = await _iaService.generateContent(
        apiKey: apiKey,
        model: model,
        history: historyForAPI,
        currentPrompt: content,
        currentImagePath: imagePath,
      );

      // 6. Criar e salvar a resposta da IA
      final modelMessage = ChatMessage(
        id: 'msg_model_${DateTime.now().millisecondsSinceEpoch}',
        sessionId: sessionId,
        role: 'model',
        content: responseText,
        createdAt: DateTime.now(),
      );
      await _localDataSource.saveMessage(modelMessage);

      return Success(modelMessage);
    } catch (e) {
      log('Erro ao enviar mensagem: $e');
      return Failure(Exception(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Stream<Result<String>> sendMessageStream(
    String sessionId,
    String content,
    String? imagePath,
    String model,
  ) async* {
    try {
      final prefs = await SharedPreferences.getInstance();
      final apiKey = prefs.getString('gemini_api_key') ?? '';

      if (apiKey.isEmpty) {
        yield Failure(
          Exception(
            'API Key do Gemini não está configurada! Por favor, configure-a no menu lateral.',
          ),
        );
        return;
      }

      // 1. Criar e salvar mensagem do usuário
      final userMessage = ChatMessage(
        id: 'msg_user_${DateTime.now().millisecondsSinceEpoch}',
        sessionId: sessionId,
        role: 'user',
        content: content,
        imagePath: imagePath,
        createdAt: DateTime.now(),
      );
      await _localDataSource.saveMessage(userMessage);

      // 2. Carregar o histórico da sessão
      final history = await _localDataSource.getMessages(sessionId);

      // 3. Atualizar título da sessão se for a primeira mensagem
      if (history.length == 1) {
        String newTitle = content;
        if (content.length > 30) {
          newTitle = '${content.substring(0, 27)}...';
        }
        await _localDataSource.updateSessionTitle(sessionId, newTitle);
      }

      // 4. Preparar histórico para a API
      final historyForAPI = history.sublist(0, history.length - 1);

      // 5. Enviar requisição em stream para a IA
      final stream = _iaService.generateContentStream(
        apiKey: apiKey,
        model: model,
        history: historyForAPI,
        currentPrompt: content,
        currentImagePath: imagePath,
      );

      String fullResponse = '';
      
      await for (final chunk in stream) {
        fullResponse += chunk;
        yield Success(chunk);
      }

      // 6. Salvar a resposta final no final do stream
      final modelMessage = ChatMessage(
        id: 'msg_model_${DateTime.now().millisecondsSinceEpoch}',
        sessionId: sessionId,
        role: 'model',
        content: fullResponse,
        createdAt: DateTime.now(),
      );
      await _localDataSource.saveMessage(modelMessage);

    } catch (e) {
      log('Erro ao transmitir mensagem: $e');
      yield Failure(Exception(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Result<List<String>>> getAvailableModels() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final apiKey = prefs.getString('gemini_api_key') ?? '';

      if (apiKey.isEmpty) {
        return const Success([]);
      }

      final models = await _iaService.getAvailableModels(apiKey);
      return Success(models);
    } catch (e) {
      log('Erro ao obter modelos remotos: $e');
      return Failure(Exception('Falha ao obter modelos remotos: $e'));
    }
  }

  @override
  Future<Result<Unit>> updateSessionModel(String sessionId, String model) async {
    try {
      await _localDataSource.updateSessionModel(sessionId, model);
      return const Success(unit);
    } catch (e) {
      log('Erro ao atualizar modelo da sessão: $e');
      return Failure(Exception('Falha ao atualizar modelo da sessão: $e'));
    }
  }
}
