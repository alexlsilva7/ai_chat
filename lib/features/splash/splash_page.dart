// ignore_for_file: deprecated_member_use
import 'package:ai_chat/core/ui/theme/app_theme.dart';
import 'package:ai_chat/features/home/home_viewmodel.dart';
import 'package:ai_chat/data/datasources/remote/ia_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home/home_page.dart';
import '../../logo_widget.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  // Controle para o splash clássico
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Controle e estados para o fluxo Welcome
  WelcomeStage _stage = WelcomeStage.intro;
  double _welcomeOpacity = 0.0;
  double _inputOpacity = 0.0;
  double _apiKeyOpacity = 0.0;
  bool _startLogoAnimation = false;
  ApertureAnimationType _logoAnimType = ApertureAnimationType.welcomeSequence;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _apiKeyFocusNode = FocusNode();

  bool _obscureApiKey = true;
  String? _errorMessage;

  bool _hasApiKey = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkApiKey();
  }

  Future<void> _checkApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final key = prefs.getString('gemini_api_key') ?? '';
    if (mounted) {
      setState(() {
        _hasApiKey = key.isNotEmpty;
        _isLoading = false;
      });
      if (_hasApiKey) {
        _runStandardSplash();
      } else {
        _runWelcomeSplash();
      }
    }
  }

  void _runStandardSplash() {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _fadeController.forward();

    // Redireciona para a HomePage após 2 segundos
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const HomePage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  void _runWelcomeSplash() {
    // Inicia a animação da logo logo após o primeiro frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _startLogoAnimation = true;
        });
      }
    });
  }

  void _onStartPressed() {
    setState(() {
      _stage = WelcomeStage.morphing;
      _welcomeOpacity = 0.0;
      _logoAnimType = ApertureAnimationType.welcomeMorph;
    });

    // Aguarda o término da animação do morph e do deslocamento (1s)
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _stage = WelcomeStage.nameInput;
          _inputOpacity = 1.0;
        });
        _nameFocusNode.requestFocus();
      }
    });
  }

  void _onNameSubmitted() {
    if (_nameController.text.trim().isEmpty) return;

    setState(() {
      _inputOpacity = 0.0;
      _logoAnimType = ApertureAnimationType.drawing;
    });

    // Desvanece o form de nome e esmaece o de API Key em seguida (500ms)
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _stage = WelcomeStage.apiKeyInput;
          _apiKeyOpacity = 1.0;
        });
        _apiKeyFocusNode.requestFocus();
      }
    });
  }

  void _onApiKeySubmitted() async {
    final apiKey = _apiKeyController.text.trim();
    if (apiKey.isEmpty) {
      setState(() {
        _errorMessage = "Por favor, insira a chave de API.";
      });
      return;
    }

    if (apiKey.length < 15) {
      setState(() {
        _errorMessage = "A chave de API deve ter no mínimo 15 caracteres.";
      });
      return;
    }

    setState(() {
      _stage = WelcomeStage.validating;
      _apiKeyOpacity = 0.0;
      _errorMessage = null;
      _logoAnimType = ApertureAnimationType.spinAndStop;
    });

    final startTime = DateTime.now();
    
    // Validação real da chave contra o endpoint da API
    final isValid = await _validateApiKey(apiKey);
    
    final elapsed = DateTime.now().difference(startTime);
    final remainingDelay = const Duration(seconds: 3) - elapsed;
    if (remainingDelay > Duration.zero) {
      await Future.delayed(remainingDelay);
    }

    if (!mounted) return;

    if (isValid) {
      final name = _nameController.text.trim();
      final viewModel = context.read<HomeViewModel>();

      // Salva nome e chave no viewModel
      await viewModel.saveUserName(name);
      await viewModel.saveApiKey(apiKey);

      setState(() {
        _stage = WelcomeStage.homeTransition;
        _logoAnimType = ApertureAnimationType.none;
      });

      // Aguarda 1s para o movimento se completar e faz transição para a HomePage
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const HomePage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 500),
            ),
          );
        }
      });
    } else {
      // Caso de Falha: volta ao canto com a animação de desenho
      setState(() {
        _stage = WelcomeStage.apiKeyInput;
        _apiKeyOpacity = 1.0;
        _logoAnimType = ApertureAnimationType.drawing;
        _errorMessage = "Chave de API inválida ou sem conexão. Insira uma chave válida.";
      });
      _apiKeyFocusNode.requestFocus();
    }
  }

  Future<bool> _validateApiKey(String apiKey) async {
    try {
      final iaService = context.read<IAService>();
      final models = await iaService.getAvailableModels(apiKey);
      return models.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Alignment _getLogoAlignment() {
    switch (_stage) {
      case WelcomeStage.intro:
      case WelcomeStage.welcome:
      case WelcomeStage.validating:
        return const Alignment(0.0, -0.35);
      case WelcomeStage.morphing:
      case WelcomeStage.nameInput:
      case WelcomeStage.apiKeyInput:
        return Alignment.topLeft;
      case WelcomeStage.homeTransition:
      case WelcomeStage.home:
        return const Alignment(0.0, -0.3); // Alinhamento exato no EmptyState
    }
  }

  double _getLogoSize() {
    switch (_stage) {
      case WelcomeStage.intro:
      case WelcomeStage.welcome:
      case WelcomeStage.validating:
        return 150.0;
      case WelcomeStage.morphing:
      case WelcomeStage.nameInput:
      case WelcomeStage.apiKeyInput:
        return 60.0;
      case WelcomeStage.homeTransition:
      case WelcomeStage.home:
        return 80.0; // Tamanho do logo na EmptyState
    }
  }

  double _getGlowSize() {
    switch (_stage) {
      case WelcomeStage.intro:
      case WelcomeStage.welcome:
      case WelcomeStage.validating:
        return 380.0;
      case WelcomeStage.morphing:
      case WelcomeStage.nameInput:
      case WelcomeStage.apiKeyInput:
        return 120.0;
      case WelcomeStage.homeTransition:
      case WelcomeStage.home:
        return 160.0;
    }
  }

  @override
  void dispose() {
    if (_hasApiKey) {
      _fadeController.dispose();
    }
    _nameController.dispose();
    _apiKeyController.dispose();
    _nameFocusNode.dispose();
    _apiKeyFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0B0D0F),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF6C3CE9),
          ),
        ),
      );
    }

    if (_hasApiKey) {
      // Retorna o Splash clássico original
      return Scaffold(
        backgroundColor: AppTheme.darkBg,
        body: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Hero(
                  tag: 'aperture_logo',
                  child: ApertureLogo(size: 120),
                ),
                const SizedBox(height: 25),
                ShaderMask(
                  shaderCallback: (bounds) {
                    return AppTheme.geminiGradient.createShader(bounds);
                  },
                  child: Text(
                    'Gemini Clone',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Assistente de IA Educacional',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white30,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Caso contrário, mostra o fluxo completo de Welcome / API Key
    return _buildWelcomeFlow();
  }

  Widget _buildWelcomeFlow() {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0D0F),
      body: Stack(
        children: [
          // Efeito de glow superior esquerdo
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6C3CE9).withOpacity(0.06),
              ),
            ),
          ),
          // Efeito de glow inferior direito
          Positioned(
            bottom: -80,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4299E1).withOpacity(0.06),
              ),
            ),
          ),
          // Glow central atrás da logo
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: AnimatedAlign(
              alignment: _getLogoAlignment(),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInOutCubic,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeInOutCubic,
                width: _getGlowSize(),
                height: _getGlowSize(),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF6C3CE9).withOpacity(0.04),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Stack(
              children: [
                // Logo animada e com alinhamento flexível
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: AnimatedAlign(
                    alignment: _getLogoAlignment(),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeInOutCubic,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeInOutCubic,
                      width: _getLogoSize(),
                      height: _getLogoSize(),
                      child: _startLogoAnimation
                          ? Hero(
                              tag: 'aperture_logo',
                              child: ApertureLogo(
                                size: _getLogoSize(),
                                animationType: _logoAnimType,
                                color: const Color(0xFF6C3CE9),
                                onIntroComplete: () {
                                  if (mounted && _stage == WelcomeStage.intro) {
                                    setState(() {
                                      _stage = WelcomeStage.welcome;
                                      _welcomeOpacity = 1.0;
                                    });
                                  }
                                },
                              ),
                            )
                          : const SizedBox(),
                    ),
                  ),
                ),

                // Card de Boas-vindas (fade out ao clicar em Começar)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 40.0, left: 24.0, right: 24.0),
                    child: AnimatedOpacity(
                      opacity: _welcomeOpacity,
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOut,
                      child: IgnorePointer(
                        ignoring: _stage != WelcomeStage.welcome,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Título com gradiente premium
                            ShaderMask(
                              shaderCallback: (bounds) {
                                return const LinearGradient(
                                  colors: [
                                    Color(0xFF4299E1),
                                    Color(0xFF6C3CE9),
                                    Color(0xFFED64A6),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(bounds);
                              },
                              child: const Text(
                                'AI Chat',
                                style: TextStyle(
                                  fontSize: 44,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Bem-vindo ao seu assistente de IA',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 0.5),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Conecte-se com o Gemini para criar, aprender e conversar de forma inteligente.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.5),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 48),
                            // Botão "Começar" estilo premium
                            Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF4299E1),
                                    Color(0xFF6C3CE9),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF6C3CE9).withOpacity(0.25),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _onStartPressed,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'Começar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Formulário do Nome do Usuário (fade in após o morph)
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: AnimatedOpacity(
                      opacity: _inputOpacity,
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOut,
                      child: IgnorePointer(
                        ignoring: _stage != WelcomeStage.nameInput,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Como posso te chamar?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Digite seu nome para iniciar a conversa.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                            const SizedBox(height: 36),
                            // Campo de texto minimalista premium
                            TextField(
                              controller: _nameController,
                              focusNode: _nameFocusNode,
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                hintText: 'Seu nome...',
                                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                                filled: true,
                                fillColor: const Color(0xFF131619),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFF6C3CE9), width: 2),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Botão Continuar
                            Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF4299E1),
                                    Color(0xFF6C3CE9),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF6C3CE9).withOpacity(0.25),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _onNameSubmitted,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'Continuar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Formulário de Chave de API do Gemini (fade in após continuar nome)
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: AnimatedOpacity(
                      opacity: _apiKeyOpacity,
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOut,
                      child: IgnorePointer(
                        ignoring: _stage != WelcomeStage.apiKeyInput,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Chave de API do Gemini',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Insira sua chave de API para habilitar as respostas do modelo.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                            const SizedBox(height: 36),
                            // Campo de texto password-style para API key
                            TextField(
                              controller: _apiKeyController,
                              focusNode: _apiKeyFocusNode,
                              obscureText: _obscureApiKey,
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                              decoration: InputDecoration(
                                hintText: 'AIzaSy...',
                                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                                filled: true,
                                fillColor: const Color(0xFF131619),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureApiKey ? Icons.visibility_off : Icons.visibility,
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureApiKey = !_obscureApiKey;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFF6C3CE9), width: 2),
                                ),
                              ),
                            ),
                            if (_errorMessage != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                              ),
                            ],
                            const SizedBox(height: 16),
                            // Link de ajuda para obter chave de API
                            GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Acesse: https://aistudio.google.com/'),
                                    backgroundColor: Color(0xFF6C3CE9),
                                  ),
                                );
                              },
                              child: const Text(
                                'Como obter uma chave de API gratuita?',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF4299E1),
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 36),
                            // Botão Finalizar
                            Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF4299E1),
                                    Color(0xFF6C3CE9),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF6C3CE9).withOpacity(0.25),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _onApiKeySubmitted,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'Concluir',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
