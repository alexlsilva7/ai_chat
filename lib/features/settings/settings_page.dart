import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/ui/theme/app_theme.dart';
import '../home/viewmodels/settings_viewmodel.dart';
import '../splash/splash_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();
  bool _obscureApiKey = true;

  @override
  void initState() {
    super.initState();
    // Preenche os campos com os dados atuais salvos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settingsVM = context.read<SettingsViewModel>();
      _nameController.text = settingsVM.userName;
      _apiKeyController.text = settingsVM.apiKey;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  void _saveApiKey() async {
    final settingsVM = context.read<SettingsViewModel>();
    await settingsVM.saveApiKeyCommand.execute(_apiKeyController.text.trim());

    if (mounted) {
      if (settingsVM.saveApiKeyCommand.value.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chave de API salva e validada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              settingsVM.apiKeyValidationError ?? 'Erro ao salvar API Key',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _saveUserName() async {
    final settingsVM = context.read<SettingsViewModel>();
    await settingsVM.saveUserName(_nameController.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nome atualizado!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _resetApp() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        title: const Text('Resetar aplicativo?'),
        content: const Text(
          'Isso apagará suas configurações locais e chave de API. Você voltará para a tela inicial.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white60)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Resetar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Limpa tudo do SharedPreferences

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const SplashPage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsVM = context.watch<SettingsViewModel>();
    // ignore: deprecated_member_use
    final isSavingKey = settingsVM.saveApiKeyCommand.isRunning;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Configurações',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(color: AppTheme.borderLight, height: 1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          // SEÇÃO: PERFIL
          const Text(
            'Perfil',
            style: TextStyle(color: AppTheme.accentBlue, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Seu Nome',
              labelStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: AppTheme.darkSurface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              suffixIcon: IconButton(
                icon: const Icon(Icons.check, color: AppTheme.accentPurple),
                onPressed: _saveUserName,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // SEÇÃO: INTELIGÊNCIA ARTIFICIAL
          const Text(
            'Inteligência Artificial',
            style: TextStyle(color: AppTheme.accentPurple, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _apiKeyController,
            obscureText: _obscureApiKey,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Gemini API Key',
              labelStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: AppTheme.darkSurface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              errorText: settingsVM.apiKeyValidationError,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureApiKey ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white54,
                ),
                onPressed: () {
                  setState(() {
                    _obscureApiKey = !_obscureApiKey;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentPurple.withValues(alpha: 0.15),
                foregroundColor: AppTheme.accentPurple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: isSavingKey ? null : _saveApiKey,
              child: isSavingKey
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accentPurple),
                    )
                  : const Text('Validar e Salvar Chave', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 48),

          // SEÇÃO: SISTEMA
          const Text(
            'Sistema',
            style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent,
              side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.35)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.delete_forever),
            label: const Text('Resetar Aplicativo e Apagar Dados', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: _resetApp,
          ),
        ],
      ),
    );
  }
}
