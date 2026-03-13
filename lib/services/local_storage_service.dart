import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/stage_progress.dart';

class LocalStorageService {
  static const _keyPrefix = 'ttt_progress_';
  static const _keyEmoji = 'ttt_emoji';

  final SharedPreferences _prefs;

  LocalStorageService._(this._prefs);

  static Future<LocalStorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorageService._(prefs);
  }

  // ── Emoji ────────────────────────────────────────────────────────────────
  String getEmoji() => _prefs.getString(_keyEmoji) ?? '😀';
  Future<void> saveEmoji(String emoji) => _prefs.setString(_keyEmoji, emoji);

  // ── Stage Progress ────────────────────────────────────────────────────────
  String _levelKey(GameDifficulty d) => '$_keyPrefix${d.name}';

  LevelProgress getLevelProgress(GameDifficulty difficulty) {
    final raw = _prefs.getString(_levelKey(difficulty));
    if (raw == null) return LevelProgress(difficulty: difficulty);

    final list = (jsonDecode(raw) as List)
        .map((e) => StageProgress.fromJson(e as Map<String, dynamic>))
        .toList();

    return LevelProgress.withStages(difficulty: difficulty, stages: list);
  }

  Future<void> saveStageCompleted(
      GameDifficulty difficulty, int stageIndex, int stars) async {
    final level = getLevelProgress(difficulty);
    final updated = level.stages.map((s) {
      if (s.stageIndex == stageIndex) {
        return s.copyWith(
          isCompleted: true,
          stars: s.stars < stars ? stars : s.stars, // keep best
        );
      }
      return s;
    }).toList();

    await _prefs.setString(
      _levelKey(difficulty),
      jsonEncode(updated.map((s) => s.toJson()).toList()),
    );
  }

  bool isDifficultyUnlocked(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.easy:
        return true;
      case GameDifficulty.normal:
        return getLevelProgress(GameDifficulty.easy).isFullyCompleted;
      case GameDifficulty.impossible:
        return getLevelProgress(GameDifficulty.normal).isFullyCompleted;
    }
  }

  Future<void> clearAll() async {
    for (final d in GameDifficulty.values) {
      await _prefs.remove(_levelKey(d));
    }
    await _prefs.remove(_keyEmoji);
  }
}
