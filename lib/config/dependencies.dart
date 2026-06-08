import 'package:ai_chat/data/datasources/local/chat_local_datasource.dart';
import 'package:ai_chat/data/datasources/local/chat_local_datasource_impl.dart';
import 'package:ai_chat/data/datasources/local/database_helper.dart';
import 'package:ai_chat/data/datasources/remote/gemini_ia_service.dart';
import 'package:ai_chat/data/datasources/remote/ia_service.dart';
import 'package:ai_chat/data/repositories/chat_repository_impl.dart';
import 'package:ai_chat/domain/repositories/chat_repository.dart';
import 'package:ai_chat/domain/validators/api_key_validator.dart';
import 'package:ai_chat/features/home/viewmodels/settings_viewmodel.dart';
import 'package:ai_chat/features/home/viewmodels/session_viewmodel.dart';
import 'package:ai_chat/features/home/viewmodels/chat_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_chat/domain/repositories/settings_repository.dart';
import 'package:ai_chat/data/repositories/settings_repository_impl.dart';

Future<List<SingleChildWidget>> getAppProviders() async {
  final prefs = await SharedPreferences.getInstance();

  return [
    Provider<DatabaseHelper>(create: (_) => DatabaseHelper.instance),
    ProxyProvider<DatabaseHelper, ChatLocalDataSource>(
      update: (_, dbHelper, _) => ChatLocalDataSourceImpl(dbHelper),
    ),
    Provider<IAService>(create: (_) => GeminiIAService()),
    ProxyProvider2<ChatLocalDataSource, IAService, ChatRepository>(
      update: (_, localDS, remoteDS, _) => ChatRepositoryImpl(localDS, remoteDS),
    ),
    Provider<SharedPreferences>.value(value: prefs),
    ProxyProvider<SharedPreferences, SettingsRepository>(
      update: (_, prefs, previous) => SettingsRepositoryImpl(prefs),
    ),
    ChangeNotifierProvider<SettingsViewModel>(
      create: (context) => SettingsViewModel(
        context.read<SettingsRepository>(),
        context.read<ChatRepository>(),
        ApiKeyValidator(),
      ),
    ),
    ChangeNotifierProvider<SessionViewModel>(
      create: (context) => SessionViewModel(context.read<ChatRepository>()),
    ),
    ChangeNotifierProvider<ChatViewModel>(
      create: (context) => ChatViewModel(context.read<ChatRepository>()),
    ),
  ];
}
