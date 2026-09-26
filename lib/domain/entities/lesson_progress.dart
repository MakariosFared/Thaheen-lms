import 'package:equatable/equatable.dart';

enum LessonStatus {
  notStarted,
  inProgress,
  completed,
  locked,
}

class LessonProgress extends Equatable {
  final String lessonId;
  final int lastPositionSec;
  final int durationSec;
  final bool isCompleted;
  final DateTime? lastWatchedAt;

  const LessonProgress({
    required this.lessonId,
    this.lastPositionSec = 0,
    this.durationSec = 0,
    this.isCompleted = false,
    this.lastWatchedAt,
  });

  LessonProgress copyWith({
    String? lessonId,
    int? lastPositionSec,
    int? durationSec,
    bool? isCompleted,
    DateTime? lastWatchedAt,
  }) {
    return LessonProgress(
      lessonId: lessonId ?? this.lessonId,
      lastPositionSec: lastPositionSec ?? this.lastPositionSec,
      durationSec: durationSec ?? this.durationSec,
      isCompleted: isCompleted ?? this.isCompleted,
      lastWatchedAt: lastWatchedAt ?? this.lastWatchedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lessonId': lessonId,
      'lastPositionSec': lastPositionSec,
      'durationSec': durationSec,
      'isCompleted': isCompleted,
      'lastWatchedAt': lastWatchedAt?.toIso8601String(),
    };
  }

  factory LessonProgress.fromJson(Map<String, dynamic> json) {
    return LessonProgress(
      lessonId: json['lessonId'] as String,
      lastPositionSec: (json['lastPositionSec'] as num?)?.toInt() ?? 0,
      durationSec: (json['durationSec'] as num?)?.toInt() ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
      lastWatchedAt: json['lastWatchedAt'] != null
          ? DateTime.tryParse(json['lastWatchedAt'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [
        lessonId,
        lastPositionSec,
        durationSec,
        isCompleted,
        lastWatchedAt,
      ];
}
