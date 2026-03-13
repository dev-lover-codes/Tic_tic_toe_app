import 'package:go_router/go_router.dart';
import '../screens/welcome_screen.dart';
import '../screens/game_screen.dart';
import '../screens/mode_selection_screen.dart';
import '../screens/emoji_selection_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/modes',
      builder: (context, state) => const ModeSelectionScreen(),
    ),
    GoRoute(
      path: '/emojis',
      builder: (context, state) => const EmojiSelectionScreen(),
    ),
    GoRoute(
      path: '/game',
      builder: (context, state) => const GameScreen(),
    ),
  ],
);
