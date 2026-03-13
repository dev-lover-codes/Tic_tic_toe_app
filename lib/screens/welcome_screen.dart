import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_panel.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _gridCtrl;
  late Animation<double> _gridRotation;
  late Animation<double> _gridScale;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _gridCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..forward();
    _gridRotation = Tween(begin: -0.15, end: 0.0).animate(
        CurvedAnimation(parent: _gridCtrl, curve: const Interval(0, 0.6, curve: Curves.easeOut)));
    _gridScale = Tween(begin: 0.7, end: 1.0).animate(
        CurvedAnimation(parent: _gridCtrl, curve: const Interval(0, 0.6, curve: Curves.easeOut)));
    _fadeIn = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _gridCtrl, curve: const Interval(0.4, 1.0, curve: Curves.easeIn)));
  }

  @override
  void dispose() {
    _gridCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Stack(children: [
          // Decorative orbs
          Positioned(top: -80, left: -80,
              child: _orb(AppTheme.primary.withValues(alpha: 0.15), 280)),
          Positioned(bottom: -60, right: -60,
              child: _orb(AppTheme.accent.withValues(alpha: 0.12), 240)),
          SafeArea(
            child: Column(children: [
              const Spacer(),
              // Animated logo grid
              AnimatedBuilder(
                animation: _gridCtrl,
                builder: (_, __) => Transform.rotate(
                  angle: _gridRotation.value,
                  child: Transform.scale(
                    scale: _gridScale.value,
                    child: _logoGrid(),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              // Title
              FadeTransition(
                opacity: _fadeIn,
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('NEON ', style: Theme.of(context).textTheme.displayLarge),
                    NeonGlowText('GRID',
                        style: Theme.of(context).textTheme.displayLarge),
                  ]),
                  const SizedBox(height: 12),
                  DefaultTextStyle(
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: AppTheme.textSecondary, fontStyle: FontStyle.italic),
                    child: AnimatedTextKit(
                      animatedTexts: [
                        TyperAnimatedText('Challenge the AI or a friend.',
                            speed: const Duration(milliseconds: 60)),
                        TyperAnimatedText('Who will claim the grid?',
                            speed: const Duration(milliseconds: 60)),
                        TyperAnimatedText('The ultimate Tic-Tac-Toe experience.',
                            speed: const Duration(milliseconds: 60)),
                      ],
                      repeatForever: true,
                    ),
                  ),
                ]),
              ),
              const Spacer(),
              FadeTransition(
                opacity: _fadeIn,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(children: [
                    NeonButton(
                      label: 'PLAY NOW',
                      icon: Icons.play_arrow_rounded,
                      onTap: () => context.push('/modes'),
                    ),
                    const SizedBox(height: 16),
                    _buildStatBar(context),
                  ]),
                ),
              ),
              const SizedBox(height: 48),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _logoGrid() {
    const cells = ['', '✕', '', '✕', '○', '', '', '', '✕'];
    return SizedBox(
      width: 200, height: 200,
      child: GlassPanel(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, mainAxisSpacing: 8, crossAxisSpacing: 8),
          itemCount: 9,
          itemBuilder: (_, i) => Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: i < 6 ? BorderSide(color: AppTheme.primary.withValues(alpha: 0.3), width: 1.5) : BorderSide.none,
                right: (i + 1) % 3 != 0 ? BorderSide(color: AppTheme.primary.withValues(alpha: 0.3), width: 1.5) : BorderSide.none,
              ),
            ),
            child: Center(
              child: Text(cells[i],
                  style: TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold,
                      color: cells[i] == '✕' ? AppTheme.primary : Colors.white54,
                      shadows: cells[i] == '✕' ? [Shadow(color: AppTheme.primary.withValues(alpha: 0.8), blurRadius: 12)] : null)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _orb(Color color, double size) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color, blurRadius: 80, spreadRadius: 40)],
      ),
    );
  }

  Widget _buildStatBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: GlassPanel(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        borderRadius: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _stat('Levels', '3'),
            _divider(),
            _stat('Stages', '45'),
            _divider(),
            _stat('Rating', '⭐⭐⭐'),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String val) => Column(
        children: [
          Text(label.toUpperCase(),
              style: const TextStyle(fontSize: 9, color: Colors.grey, letterSpacing: 1.5)),
          const SizedBox(height: 4),
          Text(val,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold,
                  color: Colors.white)),
        ],
      );

  Widget _divider() =>
      Container(width: 1, height: 30, color: AppTheme.primary.withValues(alpha: 0.2));
}
