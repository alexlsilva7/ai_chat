import 'package:ai_chat/core/ui/theme/app_theme.dart';
import 'package:ai_chat/features/splash/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class MyApp extends StatelessWidget {
  final List<SingleChildWidget> providers;

  const MyApp({super.key, required this.providers});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers,
      child: MaterialApp(
        title: 'AI Chat',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const SplashPage(),
      ),
    );
  }
}
