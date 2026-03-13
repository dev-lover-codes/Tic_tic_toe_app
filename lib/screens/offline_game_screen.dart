import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'dart:async';
import '../theme/app_theme.dart';
import '../widgets/glass_panel.dart';
import '../widgets/game_board.dart';
import '../providers/app_state.dart';
import '../models/stage_progress.dart';
import '../services/ai_service.dart';

class OfflineGameScreen extends StatefulWidget {
  const OfflineGameScreen({super.key});
  @override
  State<OfflineGameScreen> createState() => _OfflineGameScreenState();
}

class _OfflineGameScreenState extends State<OfflineGameScreen> {
  static const _aiEmoji = '🤖';
  List<String> _board = List.filled(9, '');
  bool _isPlayerTurn = true;
  String? _result; // 'win' | 'lose' | 'draw'
  int _moveCount = 0;
  bool _aiThinking = false;
  late ConfettiController _confetti;
  Timer? _aiTimer;

  late AppState _appState;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _appState = context.read<AppState>();
      _confetti = ConfettiController(duration: const Duration(seconds: 3));
      _resetBoard();
    }
  }

  void _resetBoard() {
    setState(() {
      _board = List.filled(9, '');
      _isPlayerTurn = true;
      _result = null;
      _moveCount = 0;
      _aiThinking = false;
    });
  }

  Future<void> _handleTap(int index) async {
    if (!_isPlayerTurn || _board[index].isNotEmpty || _result != null || _aiThinking) return;
    final playerEmoji = _appState.selectedEmoji;

    setState(() {
      _board[index] = playerEmoji;
      _moveCount++;
      _isPlayerTurn = false;
    });

    final res = AiService.checkGameResult(_board, playerEmoji, _aiEmoji);
    if (res != null) {
      _handleResult(res);
      return;
    }
    await _doAiMove();
  }

  Future<void> _doAiMove() async {
    setState(() => _aiThinking = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    final playerEmoji = _appState.selectedEmoji;
    final move = AiService.getMove(
      board: _board,
      difficulty: _appState.selectedDifficulty,
      aiEmoji: _aiEmoji,
      playerEmoji: playerEmoji,
    );

    if (move == -1) {
      setState(() => _aiThinking = false);
      return;
    }

    setState(() {
      _board[move] = _aiEmoji;
      _moveCount++;
      _isPlayerTurn = true;
      _aiThinking = false;
    });

    final res = AiService.checkGameResult(_board, playerEmoji, _aiEmoji);
    if (res != null) _handleResult(res);
  }

  void _handleResult(String result) {
    setState(() => _result = result);
    if (result == 'win') {
      _confetti.play();
      final stars = _calculateStars(_moveCount);
      _appState.completeStage(
          _appState.selectedDifficulty, _appState.selectedStage, stars);
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) _showResultDialog(result, stars);
      });
    } else {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) _showResultDialog(result, 0);
      });
    }
  }

  int _calculateStars(int moves) {
    if (moves <= 5) return 3;
    if (moves <= 7) return 2;
    return 1;
  }

  void _showResultDialog(String result, int stars) {
    if (!mounted) return;
    final appState = _appState;
    final isLastStage = appState.selectedStage == LevelProgress.stagesPerLevel - 1;

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      pageBuilder: (_, __, ___) => _ResultDialog(
        result: result,
        stars: stars,
        playerEmoji: appState.selectedEmoji,
        stage: appState.selectedStage,
        difficulty: appState.selectedDifficulty,
        isLastStage: isLastStage,
        onPlayAgain: () {
          Navigator.of(context).pop();
          _resetBoard();
        },
        onNextStage: () {
          Navigator.of(context).pop();
          appState.selectStage(
              appState.selectedDifficulty, appState.selectedStage + 1);
          _resetBoard();
        },
        onBack: () {
          Navigator.of(context).pop();
          context.pop();
        },
      ),
    );
  }

  @override
  void dispose() {
    _confetti.dispose();
    _aiTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final playerEmoji = appState.selectedEmoji;
    final diffLabel = appState.selectedDifficulty.name.toUpperCase();
    final stageLabel = 'Stage ${appState.selectedStage + 1}';

    return Scaffold(
      body: GradientBackground(
        child: Stack(children: [
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              colors: [AppTheme.primary, AppTheme.accent, AppTheme.warning, AppTheme.success],
              numberOfParticles: 30,
            ),
          ),
          SafeArea(
            child: Column(children: [
              _GameHeader(
                diffLabel: diffLabel,
                stageLabel: stageLabel,
                onBack: () => context.pop(),
                onReset: _resetBoard,
              ),
              const SizedBox(height: 16),
              _ScoreRow(
                playerEmoji: playerEmoji,
                aiEmoji: _aiEmoji,
                isPlayerTurn: _isPlayerTurn,
                aiThinking: _aiThinking,
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GameBoard(
                  board: _board,
                  playerEmoji: playerEmoji,
                  opponentEmoji: _aiEmoji,
                  isPlayerTurn: _isPlayerTurn && !_aiThinking,
                  gameOver: _result != null,
                  onTap: _handleTap,
                ),
              ),
              const SizedBox(height: 20),
              if (_aiThinking) ...[
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Text('🤖 is thinking…', style: TextStyle(color: AppTheme.primary.withValues(alpha: 0.8))),
                ]),
              ],
            ]),
          ),
        ]),
      ),
    );
  }
}

class _GameHeader extends StatelessWidget {
  final String diffLabel, stageLabel;
  final VoidCallback onBack, onReset;
  const _GameHeader({required this.diffLabel, required this.stageLabel, required this.onBack, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 12, 0),
      child: Row(children: [
        IconButton(icon: const Icon(Icons.arrow_back_ios_rounded), onPressed: onBack),
        Expanded(child: Column(
          children: [
            Text(diffLabel, style: TextStyle(fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.w800, letterSpacing: 2)),
            Text(stageLabel, style: Theme.of(context).textTheme.titleLarge),
          ],
        )),
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          onPressed: onReset,
          tooltip: 'Restart',
        ),
      ]),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final String playerEmoji, aiEmoji;
  final bool isPlayerTurn, aiThinking;
  const _ScoreRow({required this.playerEmoji, required this.aiEmoji, required this.isPlayerTurn, required this.aiThinking});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(children: [
        _PlayerBadge(emoji: playerEmoji, label: 'You', isActive: isPlayerTurn && !aiThinking),
        Expanded(
          child: Column(children: [
            NeonGlowText(isPlayerTurn ? 'YOUR TURN' : 'AI TURN',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
          ]),
        ),
        _PlayerBadge(emoji: aiEmoji, label: 'AI', isActive: !isPlayerTurn),
      ]),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primary.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isActive ? AppTheme.primary.withValues(alpha: 0.6) : Colors.white12,
            width: isActive ? 1.5 : 1),
        boxShadow: isActive ? [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.25), blurRadius: 12)] : null,
      ),
      child: Column(children: [
        Text(emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 12, color: isActive ? AppTheme.primary : Colors.grey, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

// ── Result Dialog ─────────────────────────────────────────────────────────────
class _ResultDialog extends StatelessWidget {
  final String result, playerEmoji;
  final int stars, stage;
  final GameDifficulty difficulty;
  final bool isLastStage;
  final VoidCallback onPlayAgain, onNextStage, onBack;

  const _ResultDialog({
    required this.result, required this.playerEmoji, required this.stars,
    required this.stage, required this.difficulty, required this.isLastStage,
    required this.onPlayAgain, required this.onNextStage, required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final isWin = result == 'win';
    final isDraw = result == 'draw';
    final emoji = isWin ? '🎉' : isDraw ? '🤝' : '😢';
    final title = isWin ? 'Victory!' : isDraw ? "It's a Draw!" : 'Defeated!';
    final subtitle = isWin ? 'Great job! You crushed the AI!' : isDraw ? 'A close battle!' : 'The AI was too clever this time.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: GlassPanel(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(emoji, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 12),
            NeonGlowText(title,
                style: Theme.of(context).textTheme.headlineLarge,
                color: isWin ? AppTheme.success : isDraw ? AppTheme.warning : AppTheme.danger),
            const SizedBox(height: 6),
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
            if (isWin) ...[
              const SizedBox(height: 24),
              AnimatedStarRating(stars: stars),
              const SizedBox(height: 8),
              Text('$stars / 3 Stars', style: const TextStyle(color: AppTheme.warning, fontWeight: FontWeight.w700)),
            ],
            const SizedBox(height: 28),
            if (isWin && !isLastStage)
              NeonButton(label: 'NEXT STAGE', icon: Icons.arrow_forward_rounded, onTap: onNextStage),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: OutlinedButton.icon(
                onPressed: onPlayAgain,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('RETRY'),
              )),
              const SizedBox(width: 10),
              Expanded(child: OutlinedButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.grid_view_rounded, size: 18),
                label: const Text('STAGES'),
              )),
            ]),
          ]),
        ),
      ),
    );
  }
}
