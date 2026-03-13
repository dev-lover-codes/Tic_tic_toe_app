import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'router/app_router.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppStateProvider(),
      child: const TicTacToeApp(),
    ),
  );
}

class AppStateProvider with ChangeNotifier {
  String selectedEmoji = '😀';

  void setEmoji(String emoji) {
    selectedEmoji = emoji;
    notifyListeners();
  }
}

class TicTacToeApp extends StatelessWidget {
  const TicTacToeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Tic-Tac-Toe Neon',
      theme: AppTheme.darkTheme, // We stick with dartTheme for Neon style
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
