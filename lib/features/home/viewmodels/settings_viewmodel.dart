import 'package:flutter/material.dart';
import 'package:result_command/result_command.dart';
import 'package:result_dart/result_dart.dart';
import '../../../../domain/repositories/chat_repository.dart';
import '../../../../domain/repositories/settings_repository.dart';
import '../../../../domain/validators/api_key_validator.dart';

class SettingsViewModel extends ChangeNotifier {
  final SettingsRepository _settingsRepository;
  final ChatRepository _chatRepository;
  final ApiKeyValidator _apiKeyValidator;

  SettingsViewModel(this._settingsRepository, this._chatRepository, this._apiKeyValidator);

  @override
  void dispose() {
    loadModelsCommand.dispose();
    saveApiKeyCommand.dispose();
    super.dispose();
  }

  String _selectedModel = 'gemini-3.5-flash';
  String get selectedModel => _selectedModel;

  List<String> _availableModels = ['gemini-3.5-flash', 'gemini-3.1-flash-lite', 'gemini-2.5-flash'];
  List<String> get availableModels => _availableModels;

  String? _apiKeyValidationError;
  String? get apiKeyValidationError => _apiKeyValidationError;

  String get apiKey => _settingsRepository.apiKey;
  String get userName => _settingsRepository.userName;

  void init() {
    if (apiKey.isNotEmpty) {
      loadModelsCommand.execute();
    }
  }

  late final loadModelsCommand = Command0<List<String>>(() async {
    final result = await _chatRepository.getAvailableModels();
    return result.map((list) {
      if (list.isNotEmpty) {
        _availableModels = {..._availableModels, ...list}.toList();
        notifyListeners();
      }
      return _availableModels;
    });
  });

  late final saveApiKeyCommand = Command1<Unit, String>((key) async {
    final validationResult = _apiKeyValidator.validate(key);
    if (!validationResult.isValid) {
      _apiKeyValidationError = validationResult.exceptions.map((e) => e.message).join(', ');
      notifyListeners();
      return Failure(Exception(_apiKeyValidationError));
    }

    _apiKeyValidationError = null;
    await _settingsRepository.saveApiKey(key);
    notifyListeners();
    
    await loadModelsCommand.execute();
    return const Success(unit);
  });

  void selectModel(String model) {
    _selectedModel = model;
    notifyListeners();
  }

  Future<void> saveUserName(String name) async {
    await _settingsRepository.saveUserName(name);
    notifyListeners();
  }
}
