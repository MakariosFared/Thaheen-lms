import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/lesson_model.dart';
import '../../data/repositories/course_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../../domain/utils/progress_calculator.dart';
import 'lesson_player_state.dart';

class LessonPlayerCubit extends Cubit<LessonPlayerState> {
  final ICourseRepository courseRepository;
  final IProgressRepository progressRepository;

  LessonPlayerCubit({
    required this.courseRepository,
    required this.progressRepository,
  }) : super(const LessonPlayerState());

  Future<void> initialize(String lessonId) async {
    emit(state.copyWith(status: PlayerStatus.loading, errorMessage: null));

    try {
      final match = await courseRepository.findLessonWithCourse(lessonId);
      if (match == null) {
        emit(state.copyWith(
          status: PlayerStatus.error,
          errorMessage: 'لم يتم العثور على الدرس المطلوب',
        ));
        return;
      }

      final course = match.course;
      final lesson = match.lesson;

      // Find next lesson across all sections in the course
      final allLessons = course.allLessons;
      final currentIndex = allLessons.indexWhere((l) => l.id == lessonId);
      LessonModel? nextLesson;
      if (currentIndex >= 0 && currentIndex < allLessons.length - 1) {
        nextLesson = allLessons[currentIndex + 1];
      }

      // Load progress and saved speed
      final progress = await progressRepository.getLessonProgress(lessonId);
      final lastSpeed = await progressRepository.getLastPlaybackSpeed();

      final isAlreadyCompleted = progress?.isCompleted ??
          ProgressCalculator.isLessonCompleted(
            positionSec: progress?.lastPositionSec ?? 0,
            durationSec: lesson.durationSec,
          );

      final resumePosition = progress?.lastPositionSec ?? 0;

      emit(state.copyWith(
        status: PlayerStatus.ready,
        course: course,
        lesson: lesson,
        nextLesson: nextLesson,
        progress: progress,
        initialPositionSec: resumePosition,
        currentPositionSec: resumePosition,
        totalDurationSec: lesson.durationSec,
        playbackSpeed: lastSpeed,
        isCompleted: isAlreadyCompleted,
        isNextLessonUnlocked: isAlreadyCompleted,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PlayerStatus.error,
        errorMessage: 'تعذر تحميل بيانات المشغل: ${e.toString()}',
      ));
    }
  }

  Future<void> onPositionChanged(int positionSec, int durationSec) async {
    if (state.status != PlayerStatus.ready || state.lesson == null) return;

    final actualDuration = durationSec > 0 ? durationSec : state.totalDurationSec;
    final isNewlyCompleted = !state.isCompleted &&
        ProgressCalculator.isLessonCompleted(
          positionSec: positionSec,
          durationSec: actualDuration,
        );

    final isCompletedNow = state.isCompleted || isNewlyCompleted;

    emit(state.copyWith(
      currentPositionSec: positionSec,
      totalDurationSec: actualDuration,
      isCompleted: isCompletedNow,
      isNextLessonUnlocked: isCompletedNow,
    ));

    // Persist position to Hive
    await progressRepository.updatePosition(
      lessonId: state.lesson!.id,
      positionSec: positionSec,
      durationSec: actualDuration,
    );
  }

  Future<void> setPlaybackSpeed(double speed) async {
    emit(state.copyWith(playbackSpeed: speed));
    await progressRepository.saveLastPlaybackSpeed(speed);
  }

  void setPlaying(bool isPlaying) {
    emit(state.copyWith(isPlaying: isPlaying));
  }

  Future<void> markCompleted() async {
    if (state.lesson == null) return;
    emit(state.copyWith(
      isCompleted: true,
      isNextLessonUnlocked: true,
    ));
    await progressRepository.markLessonCompleted(
      lessonId: state.lesson!.id,
      durationSec: state.totalDurationSec,
    );
  }
}
