import 'package:flutter_test/flutter_test.dart';
import 'package:thaheen_lms/domain/entities/lesson_progress.dart';
import 'package:thaheen_lms/domain/utils/progress_calculator.dart';

void main() {
  group('ProgressCalculator - 90% Completion Rule', () {
    test('returns false when position is below 90% of duration', () {
      // 50 / 100 = 50%
      expect(
        ProgressCalculator.isLessonCompleted(positionSec: 50, durationSec: 100),
        isFalse,
      );

      // 89 / 100 = 89%
      expect(
        ProgressCalculator.isLessonCompleted(positionSec: 89, durationSec: 100),
        isFalse,
      );

      // 70 / 80 = 87.5%
      expect(
        ProgressCalculator.isLessonCompleted(positionSec: 70, durationSec: 80),
        isFalse,
      );
    });

    test('returns true when position reaches or exceeds 90% of duration', () {
      // Exactly 90% (90 / 100)
      expect(
        ProgressCalculator.isLessonCompleted(positionSec: 90, durationSec: 100),
        isTrue,
      );

      // Exactly 90% (72 / 80)
      expect(
        ProgressCalculator.isLessonCompleted(positionSec: 72, durationSec: 80),
        isTrue,
      );

      // Exceeds 90% (95 / 100, 100 / 100)
      expect(
        ProgressCalculator.isLessonCompleted(positionSec: 95, durationSec: 100),
        isTrue,
      );
      expect(
        ProgressCalculator.isLessonCompleted(positionSec: 100, durationSec: 100),
        isTrue,
      );
    });

    test('handles edge cases safely (zero or negative values)', () {
      expect(
        ProgressCalculator.isLessonCompleted(positionSec: 0, durationSec: 0),
        isFalse,
      );
      expect(
        ProgressCalculator.isLessonCompleted(positionSec: -10, durationSec: 100),
        isFalse,
      );
      expect(
        ProgressCalculator.isLessonCompleted(positionSec: 50, durationSec: -100),
        isFalse,
      );
    });
  });

  group('ProgressCalculator - Sequential Unlock Rule', () {
    test('first lesson (index 0) is always unlocked regardless of status', () {
      expect(
        ProgressCalculator.isLessonUnlocked(
          lessonIndex: 0,
          isPreviousLessonCompleted: false,
        ),
        isTrue,
      );

      expect(
        ProgressCalculator.isLessonUnlocked(
          lessonIndex: 0,
          isPreviousLessonCompleted: true,
        ),
        isTrue,
      );
    });

    test('subsequent lessons are locked if previous lesson is not completed', () {
      expect(
        ProgressCalculator.isLessonUnlocked(
          lessonIndex: 1,
          isPreviousLessonCompleted: false,
        ),
        isFalse,
      );

      expect(
        ProgressCalculator.isLessonUnlocked(
          lessonIndex: 2,
          isPreviousLessonCompleted: false,
        ),
        isFalse,
      );
    });

    test('subsequent lessons become unlocked once previous lesson is completed', () {
      expect(
        ProgressCalculator.isLessonUnlocked(
          lessonIndex: 1,
          isPreviousLessonCompleted: true,
        ),
        isTrue,
      );

      expect(
        ProgressCalculator.isLessonUnlocked(
          lessonIndex: 3,
          isPreviousLessonCompleted: true,
        ),
        isTrue,
      );
    });
  });

  group('ProgressCalculator - Course Progress % Calculation', () {
    test('returns 0.0% when course has no lessons or 0 completed lessons', () {
      expect(
        ProgressCalculator.calculateCourseProgressPercent(
          totalLessons: 0,
          completedLessonsCount: 0,
        ),
        equals(0.0),
      );

      expect(
        ProgressCalculator.calculateCourseProgressPercent(
          totalLessons: 5,
          completedLessonsCount: 0,
        ),
        equals(0.0),
      );
    });

    test('calculates correct fractional percentages', () {
      // 1 out of 4 = 25%
      expect(
        ProgressCalculator.calculateCourseProgressPercent(
          totalLessons: 4,
          completedLessonsCount: 1,
        ),
        equals(25.0),
      );

      // 2 out of 4 = 50%
      expect(
        ProgressCalculator.calculateCourseProgressPercent(
          totalLessons: 4,
          completedLessonsCount: 2,
        ),
        equals(50.0),
      );

      // 3 out of 4 = 75%
      expect(
        ProgressCalculator.calculateCourseProgressPercent(
          totalLessons: 4,
          completedLessonsCount: 3,
        ),
        equals(75.0),
      );
    });

    test('returns 100.0% when all lessons are completed', () {
      expect(
        ProgressCalculator.calculateCourseProgressPercent(
          totalLessons: 5,
          completedLessonsCount: 5,
        ),
        equals(100.0),
      );
    });
  });

  group('ProgressCalculator - LessonStatus Evaluation', () {
    test('returns locked status when lesson is not unlocked', () {
      final status = ProgressCalculator.getLessonStatus(
        isUnlocked: false,
        progress: null,
        durationSec: 100,
      );
      expect(status, equals(LessonStatus.locked));
    });

    test('returns notStarted when unlocked with no progress recorded', () {
      final status = ProgressCalculator.getLessonStatus(
        isUnlocked: true,
        progress: null,
        durationSec: 100,
      );
      expect(status, equals(LessonStatus.notStarted));
    });

    test('returns inProgress when watched partially under 90%', () {
      const progress = LessonProgress(
        lessonId: 'l1',
        lastPositionSec: 30,
        durationSec: 100,
        isCompleted: false,
      );
      final status = ProgressCalculator.getLessonStatus(
        isUnlocked: true,
        progress: progress,
        durationSec: 100,
      );
      expect(status, equals(LessonStatus.inProgress));
    });

    test('returns completed when reached 90% or flag is set', () {
      const progressWithFlag = LessonProgress(
        lessonId: 'l1',
        lastPositionSec: 20,
        durationSec: 100,
        isCompleted: true,
      );
      expect(
        ProgressCalculator.getLessonStatus(
          isUnlocked: true,
          progress: progressWithFlag,
          durationSec: 100,
        ),
        equals(LessonStatus.completed),
      );

      const progress90Percent = LessonProgress(
        lessonId: 'l1',
        lastPositionSec: 90,
        durationSec: 100,
        isCompleted: false,
      );
      expect(
        ProgressCalculator.getLessonStatus(
          isUnlocked: true,
          progress: progress90Percent,
          durationSec: 100,
        ),
        equals(LessonStatus.completed),
      );
    });
  });
}
