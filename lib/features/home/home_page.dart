import 'package:ai_chat/features/home/viewmodels/settings_viewmodel.dart';
import 'package:ai_chat/features/home/viewmodels/session_viewmodel.dart';
import 'package:ai_chat/features/home/viewmodels/chat_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:result_command/result_command.dart';
import '../../core/ui/theme/app_theme.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/chat_input.dart';
import 'widgets/custom_drawer.dart';
import 'widgets/empty_state.dart';
import 'widgets/model_selector.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  int _lastMessageCount = 0;
  String? _lastSessionId;
  double _lastBottomInset = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Garante que os dados sejam carregados assim que a tela abre
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsViewModel>().init();
      context.read<SessionViewModel>().init();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();

    // 1. Obtém a altura da área inserida na base da tela (o espaço ocupado pelo teclado)
    final bottomInset = View.of(context).viewInsets.bottom;

    // 2. Compara com o valor anterior para detectar quando o teclado sobe
    if (bottomInset > _lastBottomInset && bottomInset > 0) {
      // O teclado abriu (a altura base aumentou e é maior que zero)

      // 3. Garante de forma segura que o scroll controller está anexado à view da lista
      if (_scrollController.hasClients) {
        // 4. Como nossa lista é invertida (reverse: true), o offset 0 é o final da conversa.
        // Se já estivermos próximos ao fim do chat (offset < 100), efetuamos o scroll.
        if (_scrollController.offset < 100) {
          _scrollToBottom();
        }
      }
    }

    // 5. Salva o valor atual para que a próxima mudança de tela possa ser comparada
    _lastBottomInset = bottomInset;
  }

  void _scrollToBottom({bool fromTop = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        Future.delayed(const Duration(milliseconds: 50), () {
          if (_scrollController.hasClients) {
            if (fromTop) {
              _scrollController.jumpTo(
                _scrollController.position.maxScrollExtent,
              );
            }
            _scrollController.animateTo(
              0.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsVM = context.watch<SettingsViewModel>();
    final sessionVM = context.watch<SessionViewModel>();
    final chatVM = context.watch<ChatViewModel>();
    
    final messages = chatVM.messages;
    // ignore: deprecated_member_use
    final isRunning = chatVM.sendMessageCommand.isRunning;

    bool shouldScroll = false;
    bool isNewSession = false;
    if (_lastSessionId != sessionVM.currentSession?.id) {
      shouldScroll = true;
      isNewSession = true;
      _lastSessionId = sessionVM.currentSession?.id;
    }
    if (_lastMessageCount != messages.length) {
      shouldScroll = true;
      _lastMessageCount = messages.length;
    }
    if (isRunning) {
      shouldScroll = true;
    }

    if (shouldScroll && (messages.isNotEmpty || isRunning)) {
      _scrollToBottom(fromTop: isNewSession);
    }

    // Lê se o comando está no estado de Falha
    if (chatVM.sendMessageCommand.value is FailureCommand) {
      final error = (chatVM.sendMessageCommand.value as FailureCommand).error;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 4),
          ),
        );
        // Retorna o comando para Idle (descanso) para não ficar mostrando o erro infinitamente
        chatVM.sendMessageCommand.reset();
      });
    }

    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: const ModelSelector(),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            tooltip: 'Nova Conversa',
            onPressed: () {
              sessionVM.createSessionCommand.execute(settingsVM.selectedModel);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Nova conversa iniciada'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(color: AppTheme.borderLight, height: 1),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty && !isRunning
                ? EmptyState(userName: settingsVM.userName)
                : ListView.builder(
                    reverse: true,
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final reversedIndex = messages.length - 1 - index;
                      return ChatBubble(message: messages[reversedIndex]);
                    },
                  ),
          ),
          const ChatInput(),
        ],
      ),
    );
  }
}
