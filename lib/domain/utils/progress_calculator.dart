import '../entities/lesson_progress.dart';

class ProgressCalculator {
  // Completion threshold is 90% (0.9)
  static const double completionThreshold = 0.9;

  // Returns true if the lesson has reached 90% watched based on position and duration.
  static bool isLessonCompleted({
    required int positionSec,
    required int durationSec,
  }) {
    if (durationSec <= 0 || positionSec < 0) {
      return false;
    }
    return (positionSec / durationSec) >= completionThreshold;
  }

  // Determines if a lesson in a sequential list is unlocked.
  // The first lesson (index 0) is always unlocked.
  // Subsequent lessons are unlocked if and only if the previous lesson was completed.
  static bool isLessonUnlocked({
    required int lessonIndex,
    required bool isPreviousLessonCompleted,
  }) {
    if (lessonIndex <= 0) {
      return true;
    }
    return isPreviousLessonCompleted;
  }

  // Calculates the course completion percentage between 0.0 and 100.0.
  // Handles 0 total lessons gracefully by returning 0.0.
  static double calculateCourseProgressPercent({
    required int totalLessons,
    required int completedLessonsCount,
  }) {
    if (totalLessons <= 0 || completedLessonsCount <= 0) {
      return 0.0;
    }
    if (completedLessonsCount >= totalLessons) {
      return 100.0;
    }
    return (completedLessonsCount / totalLessons) * 100.0;
  }

  // Calculates real-time weighted course progress percentage taking partial lesson progress into account.
  static double calculateWeightedCourseProgress({
    required int totalLessons,
    required List<double> lessonRatios,
  }) {
    if (totalLessons <= 0 || lessonRatios.isEmpty) {
      return 0.0;
    }
    final sum = lessonRatios.fold<double>(
      0.0,
      (prev, element) => prev + element.clamp(0.0, 1.0),
    );
    final percent = (sum / totalLessons) * 100.0;
    return percent.clamp(0.0, 100.0);
  }

  // Determines the status of a specific lesson.
  static LessonStatus getLessonStatus({
    required bool isUnlocked,
    required LessonProgress? progress,
    required int durationSec,
  }) {
    if (!isUnlocked) {
      return LessonStatus.locked;
    }

    if (progress != null) {
      if (progress.isCompleted ||
          isLessonCompleted(
            positionSec: progress.lastPositionSec,
            durationSec: durationSec > 0 ? durationSec : progress.durationSec,
          )) {
        return LessonStatus.completed;
      }
      if (progress.lastPositionSec > 0) {
        return LessonStatus.inProgress;
      }
    }

    return LessonStatus.notStarted;
  }
}
