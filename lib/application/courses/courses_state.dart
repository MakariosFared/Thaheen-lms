import 'package:equatable/equatable.dart';
import '../../data/models/course_model.dart';
import '../../data/models/lesson_model.dart';
import '../../domain/entities/lesson_progress.dart';

class CourseItemViewData extends Equatable {
  final CourseModel course;
  final double progressPercent;
  final int completedLessonsCount;
  final int totalLessonsCount;

  const CourseItemViewData({
    required this.course,
    required this.progressPercent,
    required this.completedLessonsCount,
    required this.totalLessonsCount,
  });

  @override
  List<Object?> get props => [
        course,
        progressPercent,
        completedLessonsCount,
        totalLessonsCount,
      ];
}

class ContinueWatchingData extends Equatable {
  final CourseModel course;
  final LessonModel lesson;
  final LessonProgress progress;

  const ContinueWatchingData({
    required this.course,
    required this.lesson,
    required this.progress,
  });

  double get watchedPercent {
    final duration = lesson.durationSec > 0
        ? lesson.durationSec
        : (progress.durationSec > 0 ? progress.durationSec : 1);
    final ratio = progress.lastPositionSec / duration;
    return (ratio.clamp(0.0, 1.0) * 100);
  }

  @override
  List<Object?> get props => [course, lesson, progress];
}

abstract class CoursesState extends Equatable {
  const CoursesState();

  @override
  List<Object?> get props => [];
}

class CoursesInitial extends CoursesState {}

class CoursesLoading extends CoursesState {}

class CoursesLoaded extends CoursesState {
  final List<CourseItemViewData> courses;
  final ContinueWatchingData? continueWatching;

  const CoursesLoaded({
    required this.courses,
    this.continueWatching,
  });

  @override
  List<Object?> get props => [courses, continueWatching];
}

class CoursesError extends CoursesState {
  final String message;

  const CoursesError(this.message);

  @override
  List<Object?> get props => [message];
}
