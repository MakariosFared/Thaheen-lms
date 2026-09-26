import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/lesson_progress.dart';
import '../../domain/utils/progress_calculator.dart';

abstract class IProgressRepository {
  Future<void> init();
  Future<LessonProgress?> getLessonProgress(String lessonId);
  Future<Map<String, LessonProgress>> getAllProgress();
  Future<void> saveLessonProgress(LessonProgress progress);
  Future<void> updatePosition({
    required String lessonId,
    required int positionSec,
    required int durationSec,
  });
  Future<void> markLessonCompleted({
    required String lessonId,
    int? durationSec,
  });
  Future<LessonProgress?> getLatestInProgressLesson();
  Future<double> getLastPlaybackSpeed();
  Future<void> saveLastPlaybackSpeed(double speed);
  Future<bool> getIsDarkMode();
  Future<void> saveIsDarkMode(bool isDark);
  Future<void> clearAll();
}

class ProgressRepository implements IProgressRepository {
  static const String progressBoxName = 'lesson_progress_box';
  static const String settingsBoxName = 'app_settings_box';
  static const String keyLastPlaybackSpeed = 'last_playback_speed';
  static const String keyIsDarkMode = 'is_dark_mode';

  Box<String>? _progressBox;
  Box<dynamic>? _settingsBox;

  @override
  Future<void> init() async {
    await Hive.initFlutter();
    _progressBox = await Hive.openBox<String>(progressBoxName);
    _settingsBox = await Hive.openBox<dynamic>(settingsBoxName);
  }

  Box<String> get progressBox {
    if (_progressBox == null || !_progressBox!.isOpen) {
      throw StateError('ProgressRepository not initialized. Call init() first.');
    }
    return _progressBox!;
  }

  Box<dynamic> get settingsBox {
    if (_settingsBox == null || !_settingsBox!.isOpen) {
      throw StateError('ProgressRepository not initialized. Call init() first.');
    }
    return _settingsBox!;
  }

  @override
  Future<LessonProgress?> getLessonProgress(String lessonId) async {
    final rawJson = progressBox.get(lessonId);
    if (rawJson == null) return null;
    try {
      final Map<String, dynamic> decoded =
          json.decode(rawJson) as Map<String, dynamic>;
      return LessonProgress.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Map<String, LessonProgress>> getAllProgress() async {
    final map = <String, LessonProgress>{};
    for (final key in progressBox.keys) {
      final lessonId = key.toString();
      final progress = await getLessonProgress(lessonId);
      if (progress != null) {
        map[lessonId] = progress;
      }
    }
    return map;
  }

  @override
  Future<void> saveLessonProgress(LessonProgress progress) async {
    final encoded = json.encode(progress.toJson());
    await progressBox.put(progress.lessonId, encoded);
  }

  @override
  Future<void> updatePosition({
    required String lessonId,
    required int positionSec,
    required int durationSec,
  }) async {
    final existing = await getLessonProgress(lessonId);
    final isAlreadyCompleted = existing?.isCompleted ?? false;
    final reaches90Percent = ProgressCalculator.isLessonCompleted(
      positionSec: positionSec,
      durationSec: durationSec,
    );

    final updated = LessonProgress(
      lessonId: lessonId,
      lastPositionSec: positionSec,
      durationSec: durationSec,
      isCompleted: isAlreadyCompleted || reaches90Percent,
      lastWatchedAt: DateTime.now(),
    );

    await saveLessonProgress(updated);
  }

  @override
  Future<void> markLessonCompleted({
    required String lessonId,
    int? durationSec,
  }) async {
    final existing = await getLessonProgress(lessonId);
    final updated = LessonProgress(
      lessonId: lessonId,
      lastPositionSec: existing?.lastPositionSec ?? (durationSec ?? 0),
      durationSec: durationSec ?? existing?.durationSec ?? 0,
      isCompleted: true,
      lastWatchedAt: DateTime.now(),
    );

    await saveLessonProgress(updated);
  }

  @override
  Future<LessonProgress?> getLatestInProgressLesson() async {
    final all = await getAllProgress();
    final inProgressList = all.values.where((p) {
      final isCompleted = p.isCompleted ||
          ProgressCalculator.isLessonCompleted(
            positionSec: p.lastPositionSec,
            durationSec: p.durationSec,
          );
      return !isCompleted && p.lastPositionSec > 0 && p.lastWatchedAt != null;
    }).toList();

    if (inProgressList.isEmpty) return null;

    inProgressList.sort((a, b) => b.lastWatchedAt!.compareTo(a.lastWatchedAt!));
    return inProgressList.first;
  }

  @override
  Future<double> getLastPlaybackSpeed() async {
    final speed = settingsBox.get(keyLastPlaybackSpeed, defaultValue: 1.0);
    if (speed is num) {
      return speed.toDouble();
    }
    return 1.0;
  }

  @override
  Future<void> saveLastPlaybackSpeed(double speed) async {
    await settingsBox.put(keyLastPlaybackSpeed, speed);
  }

  @override
  Future<bool> getIsDarkMode() async {
    final isDark = settingsBox.get(keyIsDarkMode, defaultValue: false);
    if (isDark is bool) {
      return isDark;
    }
    return false;
  }

  @override
  Future<void> saveIsDarkMode(bool isDark) async {
    await settingsBox.put(keyIsDarkMode, isDark);
  }

  @override
  Future<void> clearAll() async {
    await progressBox.clear();
    await settingsBox.clear();
  }
}
