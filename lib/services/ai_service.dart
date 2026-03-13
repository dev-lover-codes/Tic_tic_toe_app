import 'dart:math';
import '../models/stage_progress.dart';

class AiService {
  static final _rng = Random();

  /// Returns index 0-8 of next AI move. Returns -1 if board is full.
  static int getMove({
    required List<String> board,
    required GameDifficulty difficulty,
    required String aiEmoji,
    required String playerEmoji,
  }) {
    final available = _available(board);
    if (available.isEmpty) return -1;

    switch (difficulty) {
      case GameDifficulty.easy:
        return _easyMove(board, available, aiEmoji, playerEmoji);
      case GameDifficulty.normal:
        return _normalMove(board, available, aiEmoji, playerEmoji);
      case GameDifficulty.impossible:
        return _minimaxMove(board, aiEmoji, playerEmoji);
    }
  }

  // ── Easy: 80% random, 20% block or win ──────────────────────────────────
  static int _easyMove(List<String> board, List<int> available,
      String aiEmoji, String playerEmoji) {
    if (_rng.nextDouble() < 0.2) {
      final win = _findWinningMove(board, aiEmoji);
      if (win != -1) return win;
      final block = _findWinningMove(board, playerEmoji);
      if (block != -1) return block;
    }
    return available[_rng.nextInt(available.length)];
  }

  // ── Normal: always block / win, otherwise strategic-ish ─────────────────
  static int _normalMove(List<String> board, List<int> available,
      String aiEmoji, String playerEmoji) {
    // 1. Win if possible
    final win = _findWinningMove(board, aiEmoji);
    if (win != -1) return win;
    // 2. Block
    final block = _findWinningMove(board, playerEmoji);
    if (block != -1) return block;
    // 3. Take center
    if (board[4].isEmpty) return 4;
    // 4. Take a corner
    final corners = [0, 2, 6, 8].where((i) => board[i].isEmpty).toList();
    if (corners.isNotEmpty && _rng.nextDouble() < 0.7) {
      return corners[_rng.nextInt(corners.length)];
    }
    // 5. Random
    return available[_rng.nextInt(available.length)];
  }

  // ── Impossible: perfect minimax ──────────────────────────────────────────
  static int _minimaxMove(
      List<String> board, String aiEmoji, String playerEmoji) {
    int bestScore = -1000;
    int bestMove = -1;
    for (final idx in _available(board)) {
      final newBoard = List<String>.from(board)..[idx] = aiEmoji;
      final score =
          _minimax(newBoard, 0, false, aiEmoji, playerEmoji, -1000, 1000);
      if (score > bestScore) {
        bestScore = score;
        bestMove = idx;
      }
    }
    return bestMove;
  }

  static int _minimax(List<String> board, int depth, bool isMaximising,
      String aiEmoji, String playerEmoji, int alpha, int beta) {
    final winner = _checkWinner(board);
    if (winner == aiEmoji) return 10 - depth;
    if (winner == playerEmoji) return depth - 10;
    if (_available(board).isEmpty) return 0;

    if (isMaximising) {
      int best = -1000;
      for (final idx in _available(board)) {
        final b = List<String>.from(board)..[idx] = aiEmoji;
        best = max(best, _minimax(b, depth + 1, false, aiEmoji, playerEmoji, alpha, beta));
        alpha = max(alpha, best);
        if (beta <= alpha) break;
      }
      return best;
    } else {
      int best = 1000;
      for (final idx in _available(board)) {
        final b = List<String>.from(board)..[idx] = playerEmoji;
        best = min(best, _minimax(b, depth + 1, true, aiEmoji, playerEmoji, alpha, beta));
        beta = min(beta, best);
        if (beta <= alpha) break;
      }
      return best;
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  static int _findWinningMove(List<String> board, String emoji) {
    for (final idx in _available(board)) {
      final b = List<String>.from(board)..[idx] = emoji;
      if (_checkWinner(b) == emoji) return idx;
    }
    return -1;
  }

  static List<int> _available(List<String> board) {
    return [
      for (int i = 0; i < board.length; i++)
        if (board[i].isEmpty) i
    ];
  }

  static const _lines = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8],
    [0, 3, 6], [1, 4, 7], [2, 5, 8],
    [0, 4, 8], [2, 4, 6],
  ];

  static String? _checkWinner(List<String> board) {
    for (final line in _lines) {
      final a = board[line[0]], b = board[line[1]], c = board[line[2]];
      if (a.isNotEmpty && a == b && b == c) return a;
    }
    return null;
  }

  /// Returns the winning line indices if there is a winner, else null.
  static List<int>? winLine(List<String> board) {
    for (final line in _lines) {
      final a = board[line[0]], b = board[line[1]], c = board[line[2]];
      if (a.isNotEmpty && a == b && b == c) return line;
    }
    return null;
  }

  /// Check board status: 'player' emoji | 'ai' emoji | 'draw' | null (ongoing)
  static String? checkGameResult(
      List<String> board, String playerEmoji, String aiEmoji) {
    final w = _checkWinner(board);
    if (w == playerEmoji) return 'win';
    if (w == aiEmoji) return 'lose';
    if (_available(board).isEmpty) return 'draw';
    return null;
  }
}
