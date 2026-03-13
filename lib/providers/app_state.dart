import 'package:flutter/foundation.dart';
import '../models/stage_progress.dart';
import '../services/local_storage_service.dart';

/// Global app state shared across all screens.
class AppState with ChangeNotifier {
  final LocalStorageService storage;

  String _selectedEmoji = '😀';
  GameDifficulty _selectedDifficulty = GameDifficulty.easy;
  int _selectedStage = 0;
  bool _isOnlineMode = false;

  AppState({required this.storage}) {
    _selectedEmoji = storage.getEmoji();
  }

  String get selectedEmoji => _selectedEmoji;
  GameDifficulty get selectedDifficulty => _selectedDifficulty;
  int get selectedStage => _selectedStage;
  bool get isOnlineMode => _isOnlineMode;

  void selectEmoji(String emoji) {
    _selectedEmoji = emoji;
    storage.saveEmoji(emoji);
    notifyListeners();
  }

  void selectMode({required bool isOnline}) {
    _isOnlineMode = isOnline;
    notifyListeners();
  }

  void selectStage(GameDifficulty difficulty, int stage) {
    _selectedDifficulty = difficulty;
    _selectedStage = stage;
    notifyListeners();
  }

  LevelProgress getLevelProgress(GameDifficulty d) =>
      storage.getLevelProgress(d);

  Future<void> completeStage(
      GameDifficulty difficulty, int stageIndex, int stars) async {
    await storage.saveStageCompleted(difficulty, stageIndex, stars);
    notifyListeners();
  }

  bool isDifficultyUnlocked(GameDifficulty d) =>
      storage.isDifficultyUnlocked(d);
}
