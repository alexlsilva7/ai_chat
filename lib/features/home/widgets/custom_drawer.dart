import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/ui/theme/app_theme.dart';
import '../../settings/settings_page.dart'; // Importe a tela nova
import '../viewmodels/session_viewmodel.dart';
import '../viewmodels/chat_viewmodel.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionVM = context.watch<SessionViewModel>();
    final chatVM = context.read<ChatViewModel>();
    final sessions = sessionVM.sessions;
    final currentSession = sessionVM.currentSession;

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppTheme.darkBg,
              border: Border(bottom: BorderSide(color: AppTheme.borderLight, width: 1)),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => AppTheme.geminiGradient.createShader(bounds),
                    child: const Text(
                      'AI Chat',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.0),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('Histórico de Conversas', style: TextStyle(fontSize: 12, color: Colors.white30)),
                ],
              ),
            ),
          ),
          
          // Lista de Histórico
          Expanded(
            child: sessions.isEmpty
                ? const Center(
                    child: Text('Nenhuma conversa salva.', style: TextStyle(color: Colors.white30, fontSize: 13)),
                  )
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: sessions.length,
                    itemBuilder: (context, index) {
                      final session = sessions[index];
                      final isSelected = currentSession?.id == session.id;

                      return Dismissible(
                        key: Key(session.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.redAccent.withValues(alpha: 0.8),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20.0),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          sessionVM.deleteSessionCommand.execute(session.id);
                        },
                        child: ListTile(
                          selected: isSelected,
                          selectedColor: Colors.white,
                          selectedTileColor: AppTheme.accentPurple.withValues(alpha: 0.1),
                          leading: const Icon(Icons.chat_bubble_outline, size: 16),
                          title: Text(
                            session.title,
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.white : Colors.white70,
                            ),
                          ),
                          subtitle: Text(session.model, style: const TextStyle(fontSize: 11, color: Colors.white30)),
                          onTap: () {
                            sessionVM.selectSession(session);
                            chatVM.loadMessagesCommand.execute(session.id); // Carrega o chat
                            Navigator.of(context).pop();
                          },
                        ),
                      );
                    },
                  ),
          ),
          
          const Divider(color: AppTheme.borderLight, height: 1),
          
          // Botão Fixo de Configurações no Rodapé
          SafeArea(
            top: false,
            child: ListTile(
              leading: const Icon(Icons.settings_outlined, color: Colors.white70),
              title: const Text('Configurações', style: TextStyle(color: Colors.white70)),
              onTap: () {
                Navigator.of(context).pop(); // Fecha o drawer
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
