import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:provider/provider.dart';
import 'package:result_dart/result_dart.dart';

import '../../../core/ui/theme/app_theme.dart';
import '../../../domain/entities/chat_message.dart';
import '../../../domain/entities/chat_session.dart';
import '../../../domain/repositories/chat_repository.dart';
import '../../../domain/repositories/settings_repository.dart';
import '../../../domain/validators/api_key_validator.dart';
import '../viewmodels/settings_viewmodel.dart';
import 'gemini_star_widget.dart';

class ModelMetadata {
  final String displayName;
  final String description;
  final IconData icon;
  final List<String> badges;
  final Color primaryColor;

  const ModelMetadata({
    required this.displayName,
    required this.description,
    required this.icon,
    required this.badges,
    required this.primaryColor,
  });
}

ModelMetadata getModelMetadata(String modelName) {
  if (modelName.contains('3.5-flash') || modelName.contains('3.5')) {
    return const ModelMetadata(
      displayName: 'Gemini 3.5 Flash',
      description: 'Modelo de última geração equilibrado para velocidade e raciocínio avançado.',
      icon: Icons.psychology_rounded,
      badges: ['Recomendado', 'Inteligente'],
      primaryColor: AppTheme.accentPurple,
    );
  } else if (modelName.contains('3.1-flash-lite') || modelName.contains('flash-lite')) {
    return const ModelMetadata(
      displayName: 'Gemini 3.1 Lite',
      description: 'Modelo extremamente rápido e eficiente, perfeito para tarefas cotidianas.',
      icon: Icons.bolt_rounded,
      badges: ['Mais Rápido', 'Leve'],
      primaryColor: AppTheme.accentBlue,
    );
  } else if (modelName.contains('2.5-flash') || modelName.contains('2.5')) {
    return const ModelMetadata(
      displayName: 'Gemini 2.5 Flash',
      description: 'Modelo rápido e versátil de geração anterior.',
      icon: Icons.offline_bolt_rounded,
      badges: ['Veloz'],
      primaryColor: AppTheme.accentPink,
    );
  } else if (modelName.contains('pro')) {
    return const ModelMetadata(
      displayName: 'Gemini Pro',
      description: 'Modelo de alta capacidade para raciocínios complexos e escrita detalhada.',
      icon: Icons.stars_rounded,
      badges: ['Premium', 'Raciocínio'],
      primaryColor: AppTheme.accentPink,
    );
  } else {
    // Tenta formatar nomes brutos de modelos, ex: gemini-1.5-flash -> Gemini 1.5 Flash
    String pretty = modelName
        .split('-')
        .map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
        .join(' ');
    
    return ModelMetadata(
      displayName: pretty,
      description: 'Modelo Gemini integrado dinamicamente no projeto.',
      icon: Icons.smart_toy_rounded,
      badges: ['Disponível'],
      primaryColor: Colors.tealAccent,
    );
  }
}

class ModelSelector extends StatelessWidget {
  const ModelSelector({super.key});

  void _showModelBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withAlpha(160),
      builder: (modalContext) {
        return ChangeNotifierProvider.value(
          value: context.read<SettingsViewModel>(),
          child: const ModelSelectionSheet(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SettingsViewModel>();
    final currentModel = viewModel.selectedModel;
    final metadata = getModelMetadata(currentModel);

    return InkWell(
      onTap: () => _showModelBottomSheet(context),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.darkSurface.withAlpha(200),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: metadata.primaryColor.withAlpha(120),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: metadata.primaryColor.withAlpha(15),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const GeminiStarWidget(size: 14),
            const SizedBox(width: 8),
            Text(
              metadata.displayName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white70,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class ModelSelectionSheet extends StatelessWidget {
  const ModelSelectionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SettingsViewModel>();
    final currentModel = viewModel.selectedModel;

    final defaultModels = [
      'gemini-3.5-flash',
      'gemini-3.1-flash-lite',
      'gemini-2.5-flash',
    ];

    // Adiciona o modelo atual temporariamente caso ele tenha sido selecionado na lista estendida
    final displayedModels = List<String>.from(defaultModels);
    if (!defaultModels.contains(currentModel)) {
      displayedModels.add(currentModel);
    }

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.darkSurface.withAlpha(220),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: const Border(
              top: BorderSide(
                color: AppTheme.borderLight,
                width: 1.5,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Row(
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => AppTheme.geminiGradient.createShader(bounds),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Modelo de Inteligência',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Escolha o cérebro do assistente para esta conversa.',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayedModels.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final modelName = displayedModels[index];
                    final isSelected = modelName == currentModel;
                    final metadata = getModelMetadata(modelName);

                    return InkWell(
                      onTap: () {
                        viewModel.selectModel(modelName);
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? metadata.primaryColor.withAlpha(20)
                              : AppTheme.darkCard.withAlpha(100),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? metadata.primaryColor.withAlpha(160)
                                : AppTheme.borderLight,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: metadata.primaryColor.withAlpha(30),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                metadata.icon,
                                color: metadata.primaryColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      metadata.displayName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (isSelected) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        gradient: AppTheme.geminiGradient,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'ATIVO',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              height: 16,
                              width: 16,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? metadata.primaryColor
                                      : Colors.white24,
                                  width: isSelected ? 5 : 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showExtendedModelsBottomSheet(context);
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white38,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppTheme.borderLight, width: 1),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline_rounded, size: 16, color: Colors.white30),
                    SizedBox(width: 8),
                    Text(
                      'Carregar mais modelos...',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

void _showExtendedModelsBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    barrierColor: Colors.black.withAlpha(160),
    builder: (modalContext) {
      return ChangeNotifierProvider.value(
        value: context.read<SettingsViewModel>(),
        child: const ExtendedModelSelectionSheet(),
      );
    },
  );
}

class ExtendedModelSelectionSheet extends StatefulWidget {
  const ExtendedModelSelectionSheet({super.key});

  @override
  State<ExtendedModelSelectionSheet> createState() => _ExtendedModelSelectionSheetState();
}

class _ExtendedModelSelectionSheetState extends State<ExtendedModelSelectionSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsViewModel>().loadModelsCommand.execute();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SettingsViewModel>();
    final models = viewModel.availableModels;
    final currentModel = viewModel.selectedModel;
    final isRunning = viewModel.loadModelsCommand.value.isRunning;
    final isFailure = viewModel.loadModelsCommand.value.isFailure;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.darkSurface.withAlpha(220),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: const Border(
              top: BorderSide(
                color: AppTheme.borderLight,
                width: 1.5,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 18),
                    onPressed: () {
                      Navigator.pop(context);
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        barrierColor: Colors.black.withAlpha(160),
                        builder: (modalContext) {
                          return ChangeNotifierProvider.value(
                            value: context.read<SettingsViewModel>(),
                            child: const ModelSelectionSheet(),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  ShaderMask(
                    shaderCallback: (bounds) => AppTheme.geminiGradient.createShader(bounds),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Modelos Adicionais',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Lista completa disponível para a sua API Key.',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (isRunning)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.0),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentPurple),
                    ),
                  ),
                )
              else if (isFailure)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30.0),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 36),
                      const SizedBox(height: 12),
                      const Text(
                        'Falha ao carregar modelos',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Verifique sua conexão e se a chave de API nas configurações está válida.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          viewModel.loadModelsCommand.execute();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white10,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: models.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final modelName = models[index];
                      final isSelected = modelName == currentModel;
                      final metadata = getModelMetadata(modelName);

                      return InkWell(
                        onTap: () {
                          viewModel.selectModel(modelName);
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? metadata.primaryColor.withAlpha(20)
                                : AppTheme.darkCard.withAlpha(100),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? metadata.primaryColor.withAlpha(160)
                                  : AppTheme.borderLight,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: metadata.primaryColor.withAlpha(30),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  metadata.icon,
                                  color: metadata.primaryColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        metadata.displayName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (isSelected) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 1.5),
                                        decoration: BoxDecoration(
                                          gradient: AppTheme.geminiGradient,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          'ATIVO',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                height: 16,
                                width: 16,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? metadata.primaryColor
                                        : Colors.white24,
                                    width: isSelected ? 5 : 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// MOCK PARA O WIDGET PREVIEW
class MockChatRepository implements ChatRepository {
  @override
  Future<Result<List<ChatSession>>> getSessions() async => const Success([]);
  @override
  Future<Result<ChatSession>> createSession(String model) async =>
      Success(ChatSession(id: '1', title: 'Session', model: model, createdAt: DateTime.now()));
  @override
  Future<Result<Unit>> deleteSession(String id) async => const Success(unit);
  @override
  Future<Result<List<ChatMessage>>> getMessages(String sessionId) async => const Success([]);
  @override
  Future<Result<ChatMessage>> sendMessage(
          String sessionId, String content, String? imagePath, String model) async =>
      Failure(Exception());
  @override
  Stream<Result<String>> sendMessageStream(
      String sessionId, String content, String? imagePath, String model) async* {}
  @override
  Future<Result<List<String>>> getAvailableModels() async =>
      const Success(['gemini-3.5-flash', 'gemini-3.1-flash-lite', 'gemini-2.5-flash']);
  @override
  Future<Result<Unit>> updateSessionModel(String sessionId, String model) async =>
      const Success(unit);
}

class MockSettingsRepository implements SettingsRepository {
  @override
  String get apiKey => 'mock_api_key';

  @override
  String get userName => 'Mock User';

  @override
  Future<void> saveApiKey(String key) async {}

  @override
  Future<void> saveUserName(String name) async {}
}

@Preview(name: 'Model Selector Button')
Widget modelSelectorPreview() {
  final repo = MockChatRepository();
  final settingsRepo = MockSettingsRepository();
  final validator = ApiKeyValidator();
  final viewModel = SettingsViewModel(settingsRepo, repo, validator);

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<SettingsViewModel>.value(value: viewModel),
    ],
    child: MaterialApp(
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const ModelSelector(),
        ),
        body: const Center(
          child: Text(
            'Clique no seletor acima para abrir as opções',
            style: TextStyle(color: Colors.white30),
          ),
        ),
      ),
    ),
  );
}

@Preview(name: 'Model Selection Sheet')
Widget modelSelectionSheetPreview() {
  final repo = MockChatRepository();
  final settingsRepo = MockSettingsRepository();
  final validator = ApiKeyValidator();
  final viewModel = SettingsViewModel(settingsRepo, repo, validator);

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<SettingsViewModel>.value(value: viewModel),
    ],
    child: MaterialApp(
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: EdgeInsets.only(top: 100),
            child: ModelSelectionSheet(),
          ),
        ),
      ),
    ),
  );
}

@Preview(name: 'Extended Model Selection Sheet')
Widget extendedModelSelectionSheetPreview() {
  final repo = MockChatRepository();
  final settingsRepo = MockSettingsRepository();
  final validator = ApiKeyValidator();
  final viewModel = SettingsViewModel(settingsRepo, repo, validator);

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<SettingsViewModel>.value(value: viewModel),
    ],
    child: MaterialApp(
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: EdgeInsets.only(top: 100),
            child: ExtendedModelSelectionSheet(),
          ),
        ),
      ),
    ),
  );
}
