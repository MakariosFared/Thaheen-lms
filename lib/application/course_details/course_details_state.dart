import 'package:equatable/equatable.dart';
import '../../data/models/course_model.dart';
import '../../data/models/lesson_model.dart';
import '../../data/models/section_model.dart';
import '../../domain/entities/lesson_progress.dart';

class LessonItemViewData extends Equatable {
  final LessonModel lesson;
  final LessonStatus status;
  final bool isUnlocked;
  final LessonProgress? progress;
  final int globalIndex;

  const LessonItemViewData({
    required this.lesson,
    required this.status,
    required this.isUnlocked,
    required this.globalIndex,
    this.progress,
  });

  double get watchedFraction {
    if (status == LessonStatus.completed) return 1.0;
    if (progress == null || lesson.durationSec <= 0) return 0.0;
    return (progress!.lastPositionSec / lesson.durationSec).clamp(0.0, 1.0);
  }

  double get watchedPercent => (watchedFraction * 100).clamp(0.0, 100.0);

  @override
  List<Object?> get props => [
        lesson,
        status,
        isUnlocked,
        progress,
        globalIndex,
      ];
}

class SectionItemViewData extends Equatable {
  final SectionModel section;
  final List<LessonItemViewData> lessons;

  const SectionItemViewData({
    required this.section,
    required this.lessons,
  });

  @override
  List<Object?> get props => [section, lessons];
}

abstract class CourseDetailsState extends Equatable {
  const CourseDetailsState();

  @override
  List<Object?> get props => [];
}

class CourseDetailsInitial extends CourseDetailsState {}

class CourseDetailsLoading extends CourseDetailsState {}

class CourseDetailsLoaded extends CourseDetailsState {
  final CourseModel course;
  final List<SectionItemViewData> sections;
  final double progressPercent;
  final int completedLessonsCount;
  final int totalLessonsCount;

  const CourseDetailsLoaded({
    required this.course,
    required this.sections,
    required this.progressPercent,
    required this.completedLessonsCount,
    required this.totalLessonsCount,
  });

  @override
  List<Object?> get props => [
        course,
        sections,
        progressPercent,
        completedLessonsCount,
        totalLessonsCount,
      ];
}

class CourseDetailsError extends CourseDetailsState {
  final String message;

  const CourseDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}
