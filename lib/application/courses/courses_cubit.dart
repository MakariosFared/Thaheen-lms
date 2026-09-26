import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/course_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../../domain/utils/progress_calculator.dart';
import 'courses_state.dart';

class CoursesCubit extends Cubit<CoursesState> {
  final ICourseRepository courseRepository;
  final IProgressRepository progressRepository;

  CoursesCubit({
    required this.courseRepository,
    required this.progressRepository,
  }) : super(CoursesInitial());

  Future<void> loadCourses() async {
    emit(CoursesLoading());
    await _fetchAndEmitCourses();
  }

  Future<void> refreshProgress() async {
    // If already loaded or error, silently refresh or show updated data
    await _fetchAndEmitCourses();
  }

  Future<void> _fetchAndEmitCourses() async {
    try {
      final courses = await courseRepository.getCourses();
      final allProgress = await progressRepository.getAllProgress();

      final courseItems = courses.map((course) {
        final lessons = course.allLessons;
        int completedCount = 0;
        final lessonRatios = <double>[];

        for (final lesson in lessons) {
          final progress = allProgress[lesson.id];
          final isCompleted = progress?.isCompleted ??
              ProgressCalculator.isLessonCompleted(
                positionSec: progress?.lastPositionSec ?? 0,
                durationSec: lesson.durationSec,
              );
          if (isCompleted) {
            completedCount++;
            lessonRatios.add(1.0);
          } else if (progress != null &&
              progress.lastPositionSec > 0 &&
              lesson.durationSec > 0) {
            final ratio = (progress.lastPositionSec / lesson.durationSec)
                .clamp(0.0, 1.0);
            lessonRatios.add(ratio);
          } else {
            lessonRatios.add(0.0);
          }
        }

        final percent = ProgressCalculator.calculateWeightedCourseProgress(
          totalLessons: lessons.length,
          lessonRatios: lessonRatios,
        );

        return CourseItemViewData(
          course: course,
          progressPercent: percent,
          completedLessonsCount: completedCount,
          totalLessonsCount: lessons.length,
        );
      }).toList();

      // Find latest in-progress lesson for Continue Watching banner
      final latestProgress =
          await progressRepository.getLatestInProgressLesson();
      ContinueWatchingData? continueWatching;

      if (latestProgress != null) {
        final match = await courseRepository
            .findLessonWithCourse(latestProgress.lessonId);
        if (match != null) {
          continueWatching = ContinueWatchingData(
            course: match.course,
            lesson: match.lesson,
            progress: latestProgress,
          );
        }
      }

      emit(CoursesLoaded(
        courses: courseItems,
        continueWatching: continueWatching,
      ));
    } catch (e) {
      emit(CoursesError('حدث خطأ أثناء تحميل الدورات: ${e.toString()}'));
    }
  }
}
