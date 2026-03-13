import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_panel.dart';
import '../providers/app_state.dart';

class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(children: [
            _header(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                children: [
                  const SizedBox(height: 8),
                  Text('Select Mode',
                      style: Theme.of(context).textTheme.headlineLarge,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 4),
                  Text('Choose your battlefield',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 32),
                  _ModeCard(
                    icon: Icons.smart_toy_rounded,
                    tag: 'SOLO / LOCAL',
                    title: 'Offline Mode',
                    subtitle:
                        'Battle through 45 stages across Easy, Normal, and Impossible difficulties. Earn stars and prove your skill.',
                    gradientColors: [AppTheme.primary, const Color(0xFF0097A7)],
                    onTap: () {
                      context.read<AppState>().selectMode(isOnline: false);
                      context.push('/emojis');
                    },
                  ),
                  const SizedBox(height: 20),
                  _ModeCard(
                    icon: Icons.public_rounded,
                    tag: 'MULTIPLAYER',
                    title: 'Online Mode',
                    subtitle:
                        'Compete with real players worldwide. Sign in and enter the matchmaking queue.',
                    gradientColors: [AppTheme.accent, const Color(0xFF7C3AED)],
                    onTap: () {
                      context.read<AppState>().selectMode(isOnline: true);
                      context.push('/emojis');
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        Expanded(
          child: Text('Tic-Tac-Neon',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge),
        ),
        const SizedBox(width: 48),
      ]),
    );
  }
}

class _ModeCard extends StatefulWidget {
  final IconData icon;
  final String tag;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  State<_ModeCard> createState() => _ModeCardState();
}

class _ModeCardState extends State<_ModeCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween(begin: 1.0, end: 0.97).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) => _ctrl.reverse().then((_) => widget.onTap()),
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                widget.gradientColors[0].withValues(alpha: 0.15),
                widget.gradientColors[1].withValues(alpha: 0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
                color: widget.gradientColors[0].withValues(alpha: 0.35), width: 1.2),
            boxShadow: [
              BoxShadow(
                  color: widget.gradientColors[0].withValues(alpha: 0.1),
                  blurRadius: 20, spreadRadius: 1),
            ],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Image placeholder with gradient header
            Container(
              height: 140,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                gradient: LinearGradient(
                  colors: [
                    widget.gradientColors[0].withValues(alpha: 0.4),
                    widget.gradientColors[1].withValues(alpha: 0.2),
                  ],
                ),
              ),
              child: Stack(children: [
                Center(
                  child: Icon(widget.icon, size: 72,
                      color: widget.gradientColors[0].withValues(alpha: 0.7)),
                ),
                Positioned(
                  bottom: 12, left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: widget.gradientColors[0].withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: widget.gradientColors[0].withValues(alpha: 0.5)),
                    ),
                    child: Text(widget.tag,
                        style: TextStyle(
                            color: widget.gradientColors[0],
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5)),
                  ),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.title,
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(widget.subtitle, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: widget.onTap,
                    icon: Icon(widget.icon, color: Colors.black, size: 18),
                    label: Text('Select ${widget.title.split(' ').first}',
                        style: const TextStyle(color: Colors.black)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.gradientColors[0],
                      shadowColor: widget.gradientColors[0].withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
