import 'dart:io';
import 'package:ai_chat/features/home/viewmodels/settings_viewmodel.dart';
import 'package:ai_chat/features/home/viewmodels/session_viewmodel.dart';
import 'package:ai_chat/features/home/viewmodels/chat_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../../core/ui/theme/app_theme.dart';

class ChatInput extends StatefulWidget {
  const ChatInput({super.key});

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    _focusNode.onKeyEvent = (node, event) {
      if (event is KeyDownEvent &&
          event.logicalKey == LogicalKeyboardKey.enter &&
          HardwareKeyboard.instance.isControlPressed) {
        final settingsVM = context.read<SettingsViewModel>();
        final chatVM = context.read<ChatViewModel>();
        // ignore: deprecated_member_use
        final isRunning = chatVM.sendMessageCommand.isRunning;
        final isApiKeyMissing = settingsVM.apiKey.isEmpty;
        final hasAttachment = chatVM.attachedImagePath != null;
        final showSendIcon = _hasText || hasAttachment;

        if (!isRunning && !isApiKeyMissing && showSendIcon) {
          _sendMessage();
          return KeyEventResult.handled;
        }
      }
      return KeyEventResult.ignored;
    };
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasText = _textController.text.trim().isNotEmpty;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (image != null) {
        final directory = await getApplicationDocumentsDirectory();
        final path = directory.path;
        final fileName = 'img_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedFile = await File(image.path).copy('$path/$fileName');

        if (mounted) {
          context.read<ChatViewModel>().attachImage(savedFile.path);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar imagem: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                  color: AppTheme.accentPurple,
                ),
                title: const Text('Câmera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: AppTheme.accentBlue,
                ),
                title: const Text('Galeria'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _sendMessage() async {
    final text = _textController.text.trim();
    final settingsVM = context.read<SettingsViewModel>();
    final sessionVM = context.read<SessionViewModel>();
    final chatVM = context.read<ChatViewModel>();

    if (text.isNotEmpty || chatVM.attachedImagePath != null) {
      _textController.clear();
      _focusNode.requestFocus();

      if (sessionVM.currentSession == null) {
        await sessionVM.createSessionCommand.execute(settingsVM.selectedModel);
        if (sessionVM.createSessionCommand.value.isFailure) return;
      }

      await chatVM.sendMessageCommand.execute(
        SendMessagePayload(
          sessionId: sessionVM.currentSession!.id,
          model: settingsVM.selectedModel,
          content: text,
          imagePath: chatVM.attachedImagePath,
        ),
      );

      if (chatVM.sendMessageCommand.value.isSuccess) {
        sessionVM.loadSessionsCommand.execute();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsVM = context.watch<SettingsViewModel>();
    final chatVM = context.watch<ChatViewModel>();

    bool isRunning = chatVM.sendMessageCommand.value.isRunning;
    bool isApiKeyMissing = settingsVM.apiKey.isEmpty;
    bool hasAttachment = chatVM.attachedImagePath != null;
    bool showSendIcon = _hasText || hasAttachment;

    return Container(
          decoration: BoxDecoration(
            color: AppTheme.darkSurface.withValues(alpha: 0.95),
            border: const Border(
              top: BorderSide(color: AppTheme.borderLight, width: 1),
            ),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            top: 10,
            left: 12,
            right: 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasAttachment)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Stack(
                      children: [
                        Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.accentPurple,
                              width: 1.5,
                            ),
                            image: DecorationImage(
                              image: FileImage(
                                File(chatVM.attachedImagePath!),
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => chatVM.attachImage(null),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: Colors.white70,
                    ),
                    onPressed: (isRunning || isApiKeyMissing)
                        ? null
                        : _showAttachmentMenu,
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.darkBg,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppTheme.borderLight),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: TextField(
                        controller: _textController,
                        focusNode: _focusNode,
                        minLines: 1,
                        maxLines: 5,
                        enabled: !isApiKeyMissing,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          hintText: isApiKeyMissing
                              ? 'Configure a API Key no menu lateral'
                              : 'Digite uma mensagem...',
                          hintStyle: const TextStyle(
                            color: Colors.white24,
                            fontSize: 15,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: (isRunning || isApiKeyMissing)
                        ? null
                        : (showSendIcon ? _sendMessage : null),
                    child: Container(
                      height: 42,
                      width: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: showSendIcon && !isRunning && !isApiKeyMissing
                            ? AppTheme.geminiGradient
                            : null,
                        color: showSendIcon && !isRunning && !isApiKeyMissing
                            ? null
                            : Colors.white10,
                      ),
                      child: isRunning
                          ? const Padding(
                              padding: EdgeInsets.all(11.0),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Icon(
                              showSendIcon ? Icons.send : Icons.mic,
                              color: showSendIcon && !isApiKeyMissing
                                  ? Colors.white
                                  : Colors.white54,
                              size: 18,
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
  }
}
