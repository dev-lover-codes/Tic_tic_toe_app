import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../main.dart';
import '../widgets/glass_panel.dart';

class EmojiSelectionScreen extends StatefulWidget {
  const EmojiSelectionScreen({super.key});

  @override
  State<EmojiSelectionScreen> createState() => _EmojiSelectionScreenState();
}

class _EmojiSelectionScreenState extends State<EmojiSelectionScreen> {
  final List<String> availableEmojis = [
    '😀', '😎', '🤖', '👻', '🐱', '🐸', '🔥', '⭐'
  ];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -50,
            right: -50,
            child: _buildGlow(AppTheme.primaryColor.withValues(alpha: 0.1), 250),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: _buildGlow(AppTheme.primaryColor.withValues(alpha: 0.05), 250),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    children: [
                      Text('Choose Your Piece', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                      SizedBox(height: 8),
                      Text("Select the emoji you want to play as. The classic 'X' just got an upgrade.",
                          textAlign: TextAlign.center, style: TextStyle(color: Colors.white60, fontSize: 16)),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1,
                    ),
                    itemCount: availableEmojis.length,
                    itemBuilder: (context, index) {
                      final emoji = availableEmojis[index];
                      final isSelected = appState.selectedEmoji == emoji;
                      return _buildEmojiCard(emoji, isSelected, () {
                        appState.setEmoji(emoji);
                      });
                    },
                  ),
                ),
                _buildConfirmAction(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlow(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 100,
            spreadRadius: 50,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          const Expanded(
            child: Text(
              'Tic-Tac-Toe',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(width: 48), // Balance for centering
        ],
      ),
    );
  }

  Widget _buildEmojiCard(String emoji, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 48),
            ),
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: NeonGlowText(
                  'SELECTED',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmAction(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.backgroundDark,
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              context.push('/game');
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              shadowColor: AppTheme.primaryColor,
              elevation: 10,
            ),
            child: const Text('Confirm Selection', style: TextStyle(fontSize: 18, color: Colors.black)),
          ),
          const SizedBox(height: 16),
          const Text.rich(
            TextSpan(
              text: 'Playing against: ',
              style: TextStyle(color: Colors.grey, fontSize: 14),
              children: [
                TextSpan(
                  text: 'O ',
                  style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                ),
                TextSpan(text: '(Standard)'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
