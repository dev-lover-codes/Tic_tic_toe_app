import 'package:go_router/go_router.dart';
import '../screens/welcome_screen.dart';
import '../screens/mode_selection_screen.dart';
import '../screens/emoji_selection_screen.dart';
import '../screens/stage_selection_screen.dart';
import '../screens/offline_game_screen.dart';
import '../screens/auth_screen.dart';
import '../screens/matchmaking_screen.dart';
import '../screens/online_game_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const WelcomeScreen()),
    GoRoute(path: '/modes', builder: (context, state) => const ModeSelectionScreen()),
    GoRoute(path: '/emojis', builder: (context, state) => const EmojiSelectionScreen()),
    GoRoute(path: '/stages', builder: (context, state) => const StageSelectionScreen()),
    GoRoute(path: '/game/offline', builder: (context, state) => const OfflineGameScreen()),
    GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
    GoRoute(path: '/matchmaking', builder: (context, state) => const MatchmakingScreen()),
    GoRoute(
      path: '/game/online',
      builder: (context, state) {
        final matchId = state.extra as String;
        return OnlineGameScreen(matchId: matchId);
      },
    ),
  ],
);
