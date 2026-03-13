import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../theme/app_theme.dart';
import '../main.dart';
import '../widgets/glass_panel.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final List<String> board = List.generate(9, (index) => '');
  bool isPlayerTurn = true;
  int playerScore = 3;
  int computerScore = 2;
  String robotEmoji = '🤖';
  String? winner;

  void handleTap(int index) {
    if (board[index] != '' || winner != null || !isPlayerTurn) return;

    final appState = Provider.of<AppStateProvider>(context, listen: false);

    setState(() {
      board[index] = appState.selectedEmoji;
      isPlayerTurn = false;
      winner = checkWinner();
      if (winner == null && !board.contains('')) {
        winner = 'Draw';
      }
    });

    if (winner == null) {
      Future.delayed(const Duration(milliseconds: 500), computerMove);
    } else {
      updateScore();
    }
  }

  void computerMove() {
    List<int> available = [];
    for (int i = 0; i < board.length; i++) {
      if (board[i] == '') available.add(i);
    }

    if (available.isNotEmpty) {
      int move = available[Random().nextInt(available.length)];
      setState(() {
        board[move] = robotEmoji;
        isPlayerTurn = true;
        winner = checkWinner();
        if (winner == null && !board.contains('')) {
          winner = 'Draw';
        }
      });
      if (winner != null) updateScore();
    }
  }

  String? checkWinner() {
    const lines = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6]
    ];
    for (var line in lines) {
      if (board[line[0]] != '' &&
          board[line[0]] == board[line[1]] &&
          board[line[0]] == board[line[2]]) {
        return board[line[0]];
      }
    }
    return null;
  }

  void updateScore() {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    if (winner == appState.selectedEmoji) {
      playerScore++;
    } else if (winner == robotEmoji) {
      computerScore++;
    }
  }

  void resetGame() {
    setState(() {
      board.fillRange(0, 9, '');
      winner = null;
      isPlayerTurn = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);

    // Dynamic background mesh effect can be simulated with gradient
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Color(0xFF0F252A),
              AppTheme.backgroundDark,
            ],
            center: Alignment.topLeft,
            radius: 1.5,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      _buildScoreBoard(appState.selectedEmoji),
                      const SizedBox(height: 32),
                      _buildTurnIndicator(appState.selectedEmoji),
                      const SizedBox(height: 32),
                      _buildGrid(appState.selectedEmoji),
                      const SizedBox(height: 40),
                      if (winner != null) ...[
                        Text(
                          winner == 'Draw' ? 'It\'s a Draw!' : '$winner Wins!',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: resetGame,
                          child: const Text('PLAY AGAIN'),
                        )
                      ] else ...[
                        _buildInfoMessage(),
                      ]
                    ],
                  ),
                ),
              ),
              _buildBottomNav(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppTheme.primaryColor),
            onPressed: () {},
          ),
          const Text(
            'TIC-TAC-NEON',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: resetGame,
            icon: const Icon(Icons.refresh, color: AppTheme.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBoard(String myEmoji) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.2),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(myEmoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    const Text('PLAYER', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('$playerScore', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(robotEmoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    const Text('ROBOT', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('$computerScore', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTurnIndicator(String myEmoji) {
    return Column(
      children: [
        const Text('CURRENT TURN', style: TextStyle(color: AppTheme.primaryColor, letterSpacing: 2, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(isPlayerTurn ? myEmoji : robotEmoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 8),
            Text(
              isPlayerTurn ? 'Your Move' : 'Robot\'s Move',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildGrid(String myEmoji) {
    return AspectRatio(
      aspectRatio: 1,
      child: GlassPanel(
        padding: const EdgeInsets.all(12),
        borderRadius: 24,
        child: Stack(
          children: [
            // Internal Grid Lines (Simulated with position/dividers)
            // Just simple glowing lines could be done with a CustomPaint or just relying on buttons.
            // For simplicity, we use the grid itself.
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                final isMyEmoji = board[index] == myEmoji;
                return GestureDetector(
                  onTap: () => handleTap(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.1)),
                    ),
                    child: Center(
                      child: board[index] != ''
                          ? (isMyEmoji 
                              ? NeonGlowText(board[index], style: const TextStyle(fontSize: 48))
                              : Text(board[index], style: const TextStyle(fontSize: 48, color: Colors.white54)))
                          : null,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.info, color: AppTheme.primaryColor, size: 20),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'You need 1 more win to level up your neon rank!',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundDark.withValues(alpha: 0.8),
        border: Border(top: BorderSide(color: AppTheme.primaryColor.withValues(alpha: 0.2))),
      ),
      padding: const EdgeInsets.only(top: 8, bottom: 24, left: 16, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.sports_esports, 'Play', true, () {}),
          _buildNavItem(Icons.leaderboard, 'Ranks', false, () {}),
          _buildNavItem(Icons.person, 'Profile', false, () {}),
          _buildNavItem(Icons.home, 'Home', false, () { context.go('/'); }),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? AppTheme.primaryColor : Colors.grey),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? AppTheme.primaryColor : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
