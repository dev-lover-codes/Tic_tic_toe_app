enum GameDifficulty { easy, normal, impossible }

class StageProgress {
  final int stageIndex; // 0-based
  final int stars; // 0-3
  final bool isCompleted;

  const StageProgress({
    required this.stageIndex,
    this.stars = 0,
    this.isCompleted = false,
  });

  StageProgress copyWith({int? stars, bool? isCompleted}) {
    return StageProgress(
      stageIndex: stageIndex,
      stars: stars ?? this.stars,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
        'stageIndex': stageIndex,
        'stars': stars,
        'isCompleted': isCompleted,
      };

  factory StageProgress.fromJson(Map<String, dynamic> json) => StageProgress(
        stageIndex: json['stageIndex'] as int,
        stars: json['stars'] as int,
        isCompleted: json['isCompleted'] as bool,
      );
}

class LevelProgress {
  static const int stagesPerLevel = 15;
  final GameDifficulty difficulty;
  final List<StageProgress> stages;

  LevelProgress({required this.difficulty})
      : stages = List.generate(
          stagesPerLevel,
          (i) => StageProgress(stageIndex: i),
        );

  LevelProgress.withStages({required this.difficulty, required this.stages});

  bool get isFullyCompleted => stages.every((s) => s.isCompleted);
  int get completedCount => stages.where((s) => s.isCompleted).length;

  bool isStageUnlocked(int index) {
    if (index == 0) return true;
    return stages[index - 1].isCompleted;
  }

  StageProgress stage(int index) => stages[index];
}
