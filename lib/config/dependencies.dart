import 'package:ai_chat/data/datasources/local/chat_local_datasource.dart';
import 'package:ai_chat/data/datasources/local/chat_local_datasource_impl.dart';
import 'package:ai_chat/data/datasources/local/database_helper.dart';
import 'package:ai_chat/data/datasources/remote/gemini_ia_service.dart';
import 'package:ai_chat/data/datasources/remote/ia_service.dart';
import 'package:ai_chat/data/repositories/chat_repository_impl.dart';
import 'package:ai_chat/domain/repositories/chat_repository.dart';
import 'package:ai_chat/domain/validators/api_key_validator.dart';
import 'package:ai_chat/features/home/home_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> get appProviders => [
  Provider<DatabaseHelper>(create: (_) => DatabaseHelper.instance),
  ProxyProvider<DatabaseHelper, ChatLocalDataSource>(
    update: (_, dbHelper, _) => ChatLocalDataSourceImpl(dbHelper),
  ),
  Provider<IAService>(create: (_) => GeminiIAService()),
  ProxyProvider2<ChatLocalDataSource, IAService, ChatRepository>(
    update: (_, localDS, remoteDS, _) => ChatRepositoryImpl(localDS, remoteDS),
  ),
  ChangeNotifierProvider<HomeViewModel>(
    create: (context) =>
        HomeViewModel(context.read<ChatRepository>(), ApiKeyValidator()),
  ),
];
