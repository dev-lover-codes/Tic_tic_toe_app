import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_panel.dart';
import '../providers/app_state.dart';
import '../models/stage_progress.dart';

class StageSelectionScreen extends StatelessWidget {
  const StageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: GradientBackground(
          child: SafeArea(
            child: Column(children: [
              _header(context),
              _TabBar(),
              Expanded(child: _TabContent()),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        Expanded(
          child: Text('Stage Select',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge),
        ),
        const SizedBox(width: 48),
      ]),
    );
  }
}

class _TabBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const tabs = [
      {'label': 'EASY', 'color': AppTheme.success},
      {'label': 'NORMAL', 'color': AppTheme.warning},
      {'label': 'IMPOSSIBLE', 'color': AppTheme.danger},
    ];

    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: TabBar(
        indicator: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.5)),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: AppTheme.primary,
        unselectedLabelColor: Colors.grey,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1),
        unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        tabs: List.generate(3, (i) => Tab(text: tabs[i]['label'] as String)),
      ),
    );
  }
}

class _TabContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TabBarView(
      children: GameDifficulty.values
          .map((d) => _DifficultyGrid(difficulty: d))
          .toList(),
    );
  }
}

class _DifficultyGrid extends StatelessWidget {
  final GameDifficulty difficulty;
  const _DifficultyGrid({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isUnlocked = appState.isDifficultyUnlocked(difficulty);
    final level = appState.getLevelProgress(difficulty);

    if (!isUnlocked) {
      return Center(
        child: GlassPanel(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.lock_rounded, size: 56, color: Colors.grey),
            const SizedBox(height: 12),
            Text('Complete ${_prevLevel(difficulty)} first!',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center),
          ]),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.85),
      itemCount: LevelProgress.stagesPerLevel,
      itemBuilder: (_, i) {
        final progress = level.stage(i);
        final unlocked = level.isStageUnlocked(i);
        return _StageTile(
          stageNumber: i + 1,
          progress: progress,
          isUnlocked: unlocked,
          onTap: unlocked
              ? () {
                  appState.selectStage(difficulty, i);
                  context.push('/game/offline');
                }
              : null,
        );
      },
    );
  }

  String _prevLevel(GameDifficulty d) {
    if (d == GameDifficulty.normal) return 'all Easy stages';
    if (d == GameDifficulty.impossible) return 'all Normal stages';
    return '';
  }
}

class _StageTile extends StatelessWidget {
  final int stageNumber;
  final StageProgress progress;
  final bool isUnlocked;
  final VoidCallback? onTap;

  const _StageTile({
    required this.stageNumber,
    required this.progress,
    required this.isUnlocked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = progress.isCompleted;
    final borderColor = isCompleted
        ? AppTheme.success.withValues(alpha: 0.6)
        : isUnlocked
            ? AppTheme.primary.withValues(alpha: 0.4)
            : Colors.white10;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isCompleted
              ? AppTheme.success.withValues(alpha: 0.08)
              : isUnlocked
                  ? AppTheme.primary.withValues(alpha: 0.06)
                  : Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isUnlocked)
              const Icon(Icons.lock_rounded, color: Colors.grey, size: 24)
            else
              Text('$stageNumber',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: isCompleted ? AppTheme.success : AppTheme.primary)),
            const SizedBox(height: 6),
            if (isCompleted)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (i) => Icon(
                    i < progress.stars ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 14,
                    color: i < progress.stars ? AppTheme.warning : Colors.grey,
                  ),
                ),
              )
            else if (isUnlocked)
              Text('PLAY',
                  style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.primary.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1)),
          ],
        ),
      ),
    );
  }
}
