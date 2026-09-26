import 'package:equatable/equatable.dart';
import '../../data/models/course_model.dart';
import '../../data/models/lesson_model.dart';
import '../../domain/entities/lesson_progress.dart';

enum PlayerStatus {
  initial,
  loading,
  ready,
  error,
}

class LessonPlayerState extends Equatable {
  final PlayerStatus status;
  final CourseModel? course;
  final LessonModel? lesson;
  final LessonModel? nextLesson;
  final LessonProgress? progress;
  final int initialPositionSec;
  final int currentPositionSec;
  final int totalDurationSec;
  final double playbackSpeed;
  final bool isPlaying;
  final bool isCompleted;
  final bool isNextLessonUnlocked;
  final String? errorMessage;
  final String note;

  const LessonPlayerState({
    this.status = PlayerStatus.initial,
    this.course,
    this.lesson,
    this.nextLesson,
    this.progress,
    this.initialPositionSec = 0,
    this.currentPositionSec = 0,
    this.totalDurationSec = 0,
    this.playbackSpeed = 1.0,
    this.isPlaying = false,
    this.isCompleted = false,
    this.isNextLessonUnlocked = false,
    this.errorMessage,
    this.note = '',
  });

  LessonPlayerState copyWith({
    PlayerStatus? status,
    CourseModel? course,
    LessonModel? lesson,
    LessonModel? nextLesson,
    LessonProgress? progress,
    int? initialPositionSec,
    int? currentPositionSec,
    int? totalDurationSec,
    double? playbackSpeed,
    bool? isPlaying,
    bool? isCompleted,
    bool? isNextLessonUnlocked,
    String? errorMessage,
    String? note,
  }) {
    return LessonPlayerState(
      status: status ?? this.status,
      course: course ?? this.course,
      lesson: lesson ?? this.lesson,
      nextLesson: nextLesson ?? this.nextLesson,
      progress: progress ?? this.progress,
      initialPositionSec: initialPositionSec ?? this.initialPositionSec,
      currentPositionSec: currentPositionSec ?? this.currentPositionSec,
      totalDurationSec: totalDurationSec ?? this.totalDurationSec,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      isPlaying: isPlaying ?? this.isPlaying,
      isCompleted: isCompleted ?? this.isCompleted,
      isNextLessonUnlocked: isNextLessonUnlocked ?? this.isNextLessonUnlocked,
      errorMessage: errorMessage ?? this.errorMessage,
      note: note ?? this.note,
    );
  }

  double get progressFraction {
    if (totalDurationSec <= 0) return 0.0;
    return (currentPositionSec / totalDurationSec).clamp(0.0, 1.0);
  }

  @override
  List<Object?> get props => [
        status,
        course,
        lesson,
        nextLesson,
        progress,
        initialPositionSec,
        currentPositionSec,
        totalDurationSec,
        playbackSpeed,
        isPlaying,
        isCompleted,
        isNextLessonUnlocked,
        errorMessage,
        note,
      ];
}
