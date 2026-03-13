import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../services/ai_service.dart';

class GameBoard extends StatefulWidget {
  final List<String> board; // 9 cells: '' | playerEmoji | aiEmoji
  final String playerEmoji;
  final String opponentEmoji;
  final bool isPlayerTurn;
  final bool gameOver;
  final Function(int index) onTap;

  const GameBoard({
    super.key,
    required this.board,
    required this.playerEmoji,
    required this.opponentEmoji,
    required this.isPlayerTurn,
    required this.gameOver,
    required this.onTap,
  });

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> with TickerProviderStateMixin {
  final List<AnimationController?> _cellCtrls = List.filled(9, null);
  final List<Animation<double>?> _cellScales = List.filled(9, null);
  List<int>? _winLine;

  late AnimationController _winLineCtrl;
  late Animation<double> _winLineAnim;

  @override
  void initState() {
    super.initState();
    _winLineCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _winLineAnim =
        Tween(begin: 0.0, end: 1.0).animate(_winLineCtrl);

    for (int i = 0; i < 9; i++) {
      final ctrl = AnimationController(
          vsync: this, duration: const Duration(milliseconds: 350));
      final scale = Tween(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: ctrl, curve: Curves.elasticOut));
      _cellCtrls[i] = ctrl;
      _cellScales[i] = scale;

      if (widget.board[i].isNotEmpty) ctrl.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(GameBoard old) {
    super.didUpdateWidget(old);
    for (int i = 0; i < 9; i++) {
      if (old.board[i].isEmpty && widget.board[i].isNotEmpty) {
        _cellCtrls[i]?.reset();
        _cellCtrls[i]?.forward();
        HapticFeedback.lightImpact();
      }
    }
    final newWinLine = AiService.winLine(widget.board);
    if (newWinLine != null && _winLine == null) {
      _winLine = newWinLine;
      _winLineCtrl.forward();
    }
    if (widget.board.every((c) => c.isEmpty)) {
      _winLine = null;
      _winLineCtrl.reset();
      for (var c in _cellCtrls) {
        c?.reset();
      }
    }
  }

  @override
  void dispose() {
    _winLineCtrl.dispose();
    for (final c in _cellCtrls) {
      c?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppTheme.bgCard.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.2), width: 1),
              boxShadow: [
                BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.08),
                    blurRadius: 30,
                    spreadRadius: 2),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 9,
              itemBuilder: (_, i) => _buildCell(i),
            ),
          ),
          // Win-line overlay
          if (_winLine != null)
            AnimatedBuilder(
              animation: _winLineAnim,
              builder: (_, __) => CustomPaint(
                painter: _WinLinePainter(
                    line: _winLine!, progress: _winLineAnim.value),
                size: Size.infinite,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCell(int index) {
    final content = widget.board[index];
    final isEmpty = content.isEmpty;
    final canTap = isEmpty && widget.isPlayerTurn && !widget.gameOver;

    return GestureDetector(
      onTap: canTap ? () => widget.onTap(index) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isEmpty
              ? (canTap
                  ? AppTheme.primary.withValues(alpha: 0.04)
                  : Colors.white.withValues(alpha: 0.03))
              : (content == widget.playerEmoji
                  ? AppTheme.primary.withValues(alpha: 0.12)
                  : AppTheme.accent.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEmpty
                ? AppTheme.primary.withValues(alpha: 0.15)
                : (content == widget.playerEmoji
                    ? AppTheme.primary.withValues(alpha: 0.4)
                    : AppTheme.accent.withValues(alpha: 0.35)),
            width: 1.2,
          ),
        ),
        child: Center(
          child: isEmpty
              ? (canTap
                  ? Icon(Icons.add,
                      color: AppTheme.primary.withValues(alpha: 0.15), size: 28)
                  : null)
              : ScaleTransition(
                  scale: _cellScales[index]!,
                  child: Text(content,
                      style: TextStyle(
                          fontSize: 36,
                          shadows: content == widget.playerEmoji
                              ? [
                                  Shadow(
                                      color: AppTheme.primary
                                          .withValues(alpha: 0.6),
                                      blurRadius: 14)
                                ]
                              : null)),
                ),
        ),
      ),
    );
  }
}

class _WinLinePainter extends CustomPainter {
  final List<int> line;
  final double progress;

  _WinLinePainter({required this.line, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    const padding = 24.0;
    const cellSize = (1.0 / 3.0);

    Offset indexToCenter(int i) {
      final row = i ~/ 3;
      final col = i % 3;
      final x = padding + (col + 0.5) * (size.width - padding * 2) * cellSize;
      final y = padding + (row + 0.5) * (size.height - padding * 2) * cellSize;
      return Offset(x, y);
    }

    final start = indexToCenter(line.first);
    final end = indexToCenter(line.last);
    final current = Offset.lerp(start, end, progress)!;

    final paint = Paint()
      ..color = AppTheme.primary
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawLine(start, current, paint);

    // Solid line on top
    paint.maskFilter = null;
    paint.strokeWidth = 3;
    paint.color = AppTheme.primary;
    canvas.drawLine(start, current, paint);
  }

  @override
  bool shouldRepaint(_WinLinePainter old) =>
      old.progress != progress || old.line != line;
}
