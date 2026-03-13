import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_panel.dart';
import '../widgets/game_board.dart';
import '../models/match_model.dart';
import '../services/matchmaking_service.dart';

class OnlineGameScreen extends StatefulWidget {
  final String matchId;
  const OnlineGameScreen({super.key, required this.matchId});
  @override
  State<OnlineGameScreen> createState() => _OnlineGameScreenState();
}

class _OnlineGameScreenState extends State<OnlineGameScreen> {
  final _service = MatchmakingService();
  final _uid = FirebaseAuth.instance.currentUser!.uid;
  late ConfettiController _confetti;
  bool _resultShown = false;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Stack(children: [
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              colors: [AppTheme.primary, AppTheme.accent, AppTheme.warning],
              numberOfParticles: 30,
            ),
          ),
          StreamBuilder<MatchModel>(
            stream: _service.watchMatch(widget.matchId),
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
              }
              final match = snap.data!;
              final me = match.player1?.uid == _uid ? match.player1! : match.player2!;
              final opponent = match.player1?.uid == _uid ? match.player2 : match.player1;
              final isMyTurn = match.currentTurnUid == _uid && match.status == MatchStatus.playing;
              // Convert board: '' | uid → '' | emoji
              final displayBoard = match.board.map((cell) {
                if (cell.isEmpty) return '';
                if (cell == me.uid) return me.emoji;
                return opponent?.emoji ?? '?';
              }).toList();

              // Show result when game finishes
              if (match.status == MatchStatus.finished && !_resultShown) {
                _resultShown = true;
                final ctx = context; // capture before async gap
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  final didWin = match.winnerUid == _uid;
                  final isDraw = match.winnerUid == null;
                  if (didWin) _confetti.play();
                  _showResultDialog(
                    context: ctx,
                    didWin: didWin,
                    isDraw: isDraw,
                    myEmoji: me.emoji,
                    opponentEmoji: opponent?.emoji ?? '?',
                    onPlayAgain: () {
                      Navigator.of(ctx).pop();
                      ctx.pushReplacement('/matchmaking');
                    },
                    onHome: () {
                      Navigator.of(ctx).pop();
                      ctx.go('/');
                    },
                  );
                });
              }

              return SafeArea(
                child: Column(children: [
                  _header(context, me.emoji, opponent?.emoji ?? '?'),
                  const SizedBox(height: 16),
                  _turnIndicator(context, isMyTurn, me.emoji, opponent?.emoji ?? '?'),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GameBoard(
                      board: displayBoard,
                      playerEmoji: me.emoji,
                      opponentEmoji: opponent?.emoji ?? '?',
                      isPlayerTurn: isMyTurn,
                      gameOver: match.status == MatchStatus.finished,
                      onTap: (index) {
                        if (!isMyTurn) return;
                        _service.makeMove(
                          matchId: widget.matchId,
                          boardIndex: index,
                          me: me,
                          opponent: opponent!,
                          currentBoard: match.board,
                        );
                      },
                    ),
                  ),
                ]),
              );
            },
          ),
        ]),
      ),
    );
  }

  Widget _header(BuildContext context, String myEmoji, String oppEmoji) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 12, 0),
      child: Row(children: [
        IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () async {
            final nav = Navigator.of(context);
            final router = GoRouter.of(context);
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                backgroundColor: AppTheme.bgCard,
                title: const Text('Leave Match?'),
                content: const Text('You will forfeit this match.'),
                actions: [
                  TextButton(onPressed: () => nav.pop(false), child: const Text('Stay')),
                  TextButton(
                    onPressed: () => nav.pop(true),
                    child: const Text('Leave', style: TextStyle(color: AppTheme.danger)),
                  ),
                ],
              ),
            );
            if (confirmed == true && mounted) {
              await _service.leaveQueue();
              if (mounted) router.go('/');
            }
          },
        ),
        Expanded(child: Column(children: [
          const Text('ONLINE MATCH', style: TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 2)),
          Text('vs Opponent', style: Theme.of(context).textTheme.titleMedium),
        ])),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Text('$myEmoji vs $oppEmoji', style: const TextStyle(fontSize: 22)),
        ),
      ]),
    );
  }

  Widget _turnIndicator(BuildContext ctx, bool isMyTurn, String myEmoji, String oppEmoji) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(children: [
        _PlayerBadge(emoji: myEmoji, label: 'You', isActive: isMyTurn),
        Expanded(child: Center(
          child: NeonGlowText(isMyTurn ? 'YOUR TURN' : "THEIR TURN",
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
        )),
        _PlayerBadge(emoji: oppEmoji, label: 'Opponent', isActive: !isMyTurn),
      ]),
    );
  }

  void _showResultDialog({
    required BuildContext context,
    required bool didWin,
    required bool isDraw,
    required String myEmoji,
    required String opponentEmoji,
    required VoidCallback onPlayAgain,
    required VoidCallback onHome,
  }) {
    final emoji = didWin ? '🎉' : isDraw ? '🤝' : '😢';
    final title = didWin ? 'You Won!' : isDraw ? "Draw!" : 'You Lost';
    final color = didWin ? AppTheme.success : isDraw ? AppTheme.warning : AppTheme.danger;

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      pageBuilder: (_, __, ___) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: GlassPanel(
            padding: const EdgeInsets.all(28),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(emoji, style: const TextStyle(fontSize: 64)),
              const SizedBox(height: 12),
              NeonGlowText(title,
                  style: Theme.of(context).textTheme.headlineLarge,
                  color: color),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(myEmoji, style: const TextStyle(fontSize: 36)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: const Text('VS', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w900)),
                ),
                Text(opponentEmoji, style: const TextStyle(fontSize: 36)),
              ]),
              const SizedBox(height: 28),
              NeonButton(label: 'PLAY AGAIN', icon: Icons.refresh_rounded, onTap: onPlayAgain),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onHome,
                icon: const Icon(Icons.home_rounded),
                label: const Text('HOME'),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _PlayerBadge extends StatelessWidget {
  final String emoji, label;
  final bool isActive;
  const _PlayerBadge({required this.emoji, required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primary.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isActive ? AppTheme.primary.withValues(alpha: 0.6) : Colors.white12,
            width: isActive ? 1.5 : 1),
      ),
      child: Column(children: [
        Text(emoji, style: const TextStyle(fontSize: 26)),
        Text(label, style: TextStyle(fontSize: 11, color: isActive ? AppTheme.primary : Colors.grey, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
