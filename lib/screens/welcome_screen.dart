import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_panel.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: MediaQuery.of(context).size.height * 0.2,
            left: -50,
            child: _buildGlow(AppTheme.primaryColor.withValues(alpha: 0.2), 250),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.2,
            right: -50,
            child: _buildGlow(Colors.blueAccent.withValues(alpha: 0.2), 320),
          ),
          // Scrollable Content
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    children: [
                      const SizedBox(height: 48),
                      Center(child: _buildTicTacToeGrid()),
                      const SizedBox(height: 48),
                      // Title Text
                      Text.rich(
                        TextSpan(
                          text: 'The Ultimate\n',
                          children: [
                            WidgetSpan(
                              child: NeonGlowText('Challenge',
                                  style: Theme.of(context).textTheme.displayLarge),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(height: 1.2),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Experience the classic game with a modern neon twist. Play against global players or master the AI.",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 40),
                      _buildActionButtons(context),
                      const SizedBox(height: 64),
                      _buildStatsBar(),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
                _buildBottomNav(context),
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
        color: color,
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.gamepad, color: AppTheme.primaryColor),
          ),
          const Text(
            'NEON GRID',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.settings, color: AppTheme.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildTicTacToeGrid() {
    return SizedBox(
      width: 200,
      height: 200,
      child: GlassPanel(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: 9,
          itemBuilder: (context, index) {
            final isX = index == 0 || index == 4 || index == 8;
            final isO = index == 2 || index == 6;
            return Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: index < 6
                      ? BorderSide(color: AppTheme.primaryColor.withValues(alpha: 0.3), width: 2)
                      : BorderSide.none,
                  right: (index + 1) % 3 != 0
                      ? BorderSide(color: AppTheme.primaryColor.withValues(alpha: 0.3), width: 2)
                      : BorderSide.none,
                ),
              ),
              child: Center(
                child: isX
                    ? const NeonGlowText('X', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold))
                    : (isO
                        ? Text(
                            'O',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          )
                        : null),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              context.push('/modes');
            },
            icon: const Icon(Icons.play_arrow, color: Colors.black),
            label: const Text('PLAY NOW', style: TextStyle(color: Colors.black, fontSize: 18)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 20),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: GlassPanel(
            onTap: () {},
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.group, color: Colors.white),
                SizedBox(width: 8),
                Text('MULTIPLAYER', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsBar() {
    return GlassPanel(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      borderRadius: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatColumn('Online', '1.2k', true),
          Container(width: 1, height: 30, color: AppTheme.primaryColor.withValues(alpha: 0.2)),
          _buildStatColumn('Matches', '450k+', false),
          Container(width: 1, height: 30, color: AppTheme.primaryColor.withValues(alpha: 0.2)),
          _buildStatColumn('Rating', '4.9/5', false),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, bool isPrimaryText) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isPrimaryText ? AppTheme.primaryColor : Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundDark.withValues(alpha: 0.8),
        border: Border(top: BorderSide(color: AppTheme.primaryColor.withValues(alpha: 0.1))),
      ),
      padding: const EdgeInsets.only(top: 8, bottom: 24, left: 16, right: 16),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, 'Home', true),
            _buildNavItem(Icons.sports_esports, 'Games', false),
            _buildNavItem(Icons.leaderboard, 'Rank', false),
            _buildNavItem(Icons.person, 'Profile', false),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
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
    );
  }
}
