import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../theme/app_theme.dart';
import '../widgets/glass_panel.dart';
import '../providers/app_state.dart';
import '../services/matchmaking_service.dart';

class MatchmakingScreen extends StatefulWidget {
  const MatchmakingScreen({super.key});
  @override
  State<MatchmakingScreen> createState() => _MatchmakingScreenState();
}

class _MatchmakingScreenState extends State<MatchmakingScreen>
    with SingleTickerProviderStateMixin {
  final _service = MatchmakingService();
  late AnimationController _rotCtrl;
  StreamSubscription? _queueSub;
  bool _searching = false;
  String? _matchId;
  String _status = 'Tap to find a match';

  @override
  void initState() {
    super.initState();
    _rotCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..repeat();
  }

  @override
  void dispose() {
    _rotCtrl.dispose();
    _queueSub?.cancel();
    if (_searching && _matchId == null) _service.leaveQueue();
    super.dispose();
  }

  Future<void> _startSearch() async {
    final emoji = context.read<AppState>().selectedEmoji;
    setState(() { _searching = true; _status = 'Searching for opponent…'; });

    try {
      final matchId = await _service.findOrCreateMatch(emoji);
      if (!mounted) return;

      if (matchId.isNotEmpty) {
        // Found an opponent immediately
        setState(() => _matchId = matchId);
        context.pushReplacement('/game/online', extra: matchId);
      } else {
        // Waiting in queue – listen for our queue entry to be matched
        _queueSub = _service.watchQueueEntry().listen((id) {
          if (id != null && mounted) {
            setState(() => _matchId = id);
            _queueSub?.cancel();
            context.pushReplacement('/game/online', extra: id);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() { _searching = false; _status = 'Failed to connect. Try again.'; });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
        ));
      }
    }
  }

  Future<void> _cancel() async {
    _queueSub?.cancel();
    await _service.leaveQueue();
    if (mounted) {
      setState(() { _searching = false; _status = 'Search cancelled.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 16, 16, 0),
              child: Row(children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded),
                  onPressed: () async {
                    final router = GoRouter.of(context);
                    if (_searching) await _cancel();
                    if (mounted) router.pop();
                  },
                ),
                Expanded(
                  child: Text('Matchmaking', textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge),
                ),
                const SizedBox(width: 48),
              ]),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Spinning radar animation
                      RotationTransition(
                        turns: _rotCtrl,
                        child: Container(
                          width: 160, height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppTheme.primary.withValues(alpha: _searching ? 0.8 : 0.3),
                                width: 2),
                            boxShadow: _searching ? [
                              BoxShadow(color: AppTheme.primary.withValues(alpha: 0.2),
                                  blurRadius: 30, spreadRadius: 5),
                            ] : null,
                          ),
                          child: Center(
                            child: Text(appState.selectedEmoji,
                                style: const TextStyle(fontSize: 64)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Orbiting dots
                      if (_searching) ...[
                        const SizedBox(height: 8),
                        Row(mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (i) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: _PulseDot(delay: Duration(milliseconds: i * 200)),
                          )),
                        ),
                      ],
                      const SizedBox(height: 24),
                      NeonGlowText(_status,
                          style: Theme.of(context).textTheme.titleMedium,
                          color: _searching ? AppTheme.primary : AppTheme.textSecondary),
                      const SizedBox(height: 8),
                      Text('Your emoji: ${appState.selectedEmoji}',
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 40),
                      if (!_searching)
                        NeonButton(
                          label: 'FIND MATCH',
                          icon: Icons.search_rounded,
                          onTap: _startSearch,
                          wide: false,
                        )
                      else
                        OutlinedButton.icon(
                          onPressed: _cancel,
                          icon: const Icon(Icons.close_rounded),
                          label: const Text('CANCEL'),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  final Duration delay;
  const _PulseDot({required this.delay});
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _anim = Tween(begin: 0.3, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 10, height: 10,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.primary,
        ),
      ),
    );
  }
}
