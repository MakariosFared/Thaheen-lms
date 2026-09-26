import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/course_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../../domain/entities/lesson_progress.dart';
import '../../domain/utils/progress_calculator.dart';
import 'course_details_state.dart';

class CourseDetailsCubit extends Cubit<CourseDetailsState> {
  final String courseId;
  final ICourseRepository courseRepository;
  final IProgressRepository progressRepository;

  CourseDetailsCubit({
    required this.courseId,
    required this.courseRepository,
    required this.progressRepository,
  }) : super(CourseDetailsInitial());

  Future<void> loadCourseDetails() async {
    emit(CourseDetailsLoading());
    await _fetchAndEmitCourseDetails();
  }

  Future<void> refresh() async {
    await _fetchAndEmitCourseDetails();
  }

  Future<void> _fetchAndEmitCourseDetails() async {
    try {
      final course = await courseRepository.getCourseById(courseId);
      if (course == null) {
        emit(const CourseDetailsError('لم يتم العثور على الدورة المطلوبة'));
        return;
      }

      final allProgress = await progressRepository.getAllProgress();

      // Sequential unlock across all lessons in order
      bool isPreviousCompleted = true; // First lesson is unlocked
      int globalIndex = 0;
      int completedLessonsCount = 0;
      final totalLessonsCount = course.allLessons.length;

      final sectionViewDataList = <SectionItemViewData>[];

      for (final section in course.sections) {
        final lessonViewDataList = <LessonItemViewData>[];

        for (final lesson in section.lessons) {
          final progress = allProgress[lesson.id];
          final isUnlocked = ProgressCalculator.isLessonUnlocked(
            lessonIndex: globalIndex,
            isPreviousLessonCompleted: isPreviousCompleted,
          );

          final status = ProgressCalculator.getLessonStatus(
            isUnlocked: isUnlocked,
            progress: progress,
            durationSec: lesson.durationSec,
          );

          final isThisCompleted = status == LessonStatus.completed;
          if (isThisCompleted) {
            completedLessonsCount++;
          }

          lessonViewDataList.add(LessonItemViewData(
            lesson: lesson,
            status: status,
            isUnlocked: isUnlocked,
            progress: progress,
            globalIndex: globalIndex,
          ));

          // For the next lesson in sequence
          isPreviousCompleted = isThisCompleted;
          globalIndex++;
        }

        sectionViewDataList.add(SectionItemViewData(
          section: section,
          lessons: lessonViewDataList,
        ));
      }

      final percent = ProgressCalculator.calculateCourseProgressPercent(
        totalLessons: totalLessonsCount,
        completedLessonsCount: completedLessonsCount,
      );

      emit(CourseDetailsLoaded(
        course: course,
        sections: sectionViewDataList,
        progressPercent: percent,
        completedLessonsCount: completedLessonsCount,
        totalLessonsCount: totalLessonsCount,
      ));
    } catch (e) {
      emit(CourseDetailsError('حدث خطأ أثناء تحميل بيانات الدورة: ${e.toString()}'));
    }
  }
}
