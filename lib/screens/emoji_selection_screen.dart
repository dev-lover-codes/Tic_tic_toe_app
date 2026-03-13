import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_panel.dart';
import '../providers/app_state.dart';

class EmojiSelectionScreen extends StatefulWidget {
  const EmojiSelectionScreen({super.key});
  @override
  State<EmojiSelectionScreen> createState() => _EmojiSelectionScreenState();
}

class _EmojiSelectionScreenState extends State<EmojiSelectionScreen> {
  static const _emojis = [
    '😀', '😎', '🤩', '🥷',
    '🐱', '🐸', '🔥', '⭐',
    '🦊', '🎮', '👾', '🚀',
    '🌈', '💎', '🏆', '🎯',
  ];

  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = context.read<AppState>().selectedEmoji;
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(children: [
            _header(context),
            Expanded(
              child: Column(children: [
                const SizedBox(height: 12),
                Text('Choose Your Piece',
                    style: Theme.of(context).textTheme.headlineLarge,
                    textAlign: TextAlign.center),
                const SizedBox(height: 4),
                Text('Your emoji, your identity on the board',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center),
                const SizedBox(height: 24),
                // Preview selected emoji
                _SelectedPreview(emoji: _selected),
                const SizedBox(height: 24),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1,
                    ),
                    itemCount: _emojis.length,
                    itemBuilder: (_, i) => _EmojiTile(
                      emoji: _emojis[i],
                      isSelected: _selected == _emojis[i],
                      onTap: () => setState(() => _selected = _emojis[i]),
                    ),
                  ),
                ),
                _bottomBar(context, appState),
              ]),
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

  Widget _bottomBar(BuildContext context, AppState appState) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        color: AppTheme.bgDark.withValues(alpha: 0.8),
        border: const Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Column(children: [
        NeonButton(
          label: 'CONFIRM SELECTION',
          icon: Icons.check_circle_rounded,
          onTap: () {
            appState.selectEmoji(_selected);
            if (appState.isOnlineMode) {
              context.push('/auth');
            } else {
              context.push('/stages');
            }
          },
        ),
        const SizedBox(height: 10),
        Text.rich(TextSpan(
          text: 'Selected: ',
          style: const TextStyle(color: Colors.grey, fontSize: 13),
          children: [
            TextSpan(
              text: '$_selected (Opponent: 🤖)',
              style: const TextStyle(
                  color: AppTheme.primary, fontWeight: FontWeight.bold),
            ),
          ],
        )),
      ]),
    );
  }
}

class _SelectedPreview extends StatefulWidget {
  final String emoji;
  const _SelectedPreview({required this.emoji});
  @override
  State<_SelectedPreview> createState() => _SelectedPreviewState();
}

class _SelectedPreviewState extends State<_SelectedPreview>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _scale = Tween(begin: 0.5, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _ctrl.value = 1.0;
  }

  @override
  void didUpdateWidget(_SelectedPreview old) {
    super.didUpdateWidget(old);
    if (old.emoji != widget.emoji) {
      _ctrl.reset();
      _ctrl.forward();
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
      borderRadius: 100,
      child: ScaleTransition(
        scale: _scale,
        child: Text(widget.emoji, style: const TextStyle(fontSize: 52)),
      ),
    );
  }
}

class _EmojiTile extends StatefulWidget {
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;
  const _EmojiTile({required this.emoji, required this.isSelected, required this.onTap});
  @override
  State<_EmojiTile> createState() => _EmojiTileState();
}

class _EmojiTileState extends State<_EmojiTile> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _scale = Tween(begin: 1.0, end: 1.15)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    if (widget.isSelected) _ctrl.forward();
  }

  @override
  void didUpdateWidget(_EmojiTile old) {
    super.didUpdateWidget(old);
    if (widget.isSelected && !old.isSelected) _ctrl.forward();
    if (!widget.isSelected && old.isSelected) _ctrl.reverse();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppTheme.primary.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isSelected ? AppTheme.primary : Colors.white12,
              width: widget.isSelected ? 2 : 1,
            ),
            boxShadow: widget.isSelected
                ? [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.4), blurRadius: 16, spreadRadius: 1)]
                : null,
          ),
          child: Center(child: Text(widget.emoji, style: const TextStyle(fontSize: 30))),
        ),
      ),
    );
  }
}
