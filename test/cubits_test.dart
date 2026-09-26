import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:thaheen_lms/application/courses/courses_cubit.dart';
import 'package:thaheen_lms/application/courses/courses_state.dart';
import 'package:thaheen_lms/application/course_details/course_details_cubit.dart';
import 'package:thaheen_lms/application/course_details/course_details_state.dart';
import 'package:thaheen_lms/data/models/course_model.dart';
import 'package:thaheen_lms/data/models/lesson_model.dart';
import 'package:thaheen_lms/data/models/section_model.dart';
import 'package:thaheen_lms/data/repositories/course_repository.dart';
import 'package:thaheen_lms/data/repositories/progress_repository.dart';
import 'package:thaheen_lms/domain/entities/lesson_progress.dart';

class MockCourseRepository extends Mock implements ICourseRepository {}

class MockProgressRepository extends Mock implements IProgressRepository {}

void main() {
  late MockCourseRepository mockCourseRepo;
  late MockProgressRepository mockProgressRepo;

  final sampleLesson1 = const LessonModel(
    id: 'l1',
    title: 'Lesson 1',
    durationSec: 100,
    video: 'assets/videos/lesson1.mp4',
  );

  final sampleLesson2 = const LessonModel(
    id: 'l2',
    title: 'Lesson 2',
    durationSec: 100,
    video: 'assets/videos/lesson2.mp4',
  );

  final sampleCourse = CourseModel(
    id: 'c1',
    title: 'Course 1',
    instructor: 'Instructor 1',
    description: 'Description 1',
    thumbnail: 'assets/images/anatomy.png',
    sections: [
      SectionModel(
        id: 's1',
        title: 'Section 1',
        lessons: [sampleLesson1, sampleLesson2],
      )
    ],
  );

  setUp(() {
    mockCourseRepo = MockCourseRepository();
    mockProgressRepo = MockProgressRepository();
  });

  group('CoursesCubit Tests', () {
    blocTest<CoursesCubit, CoursesState>(
      'emits [CoursesLoading, CoursesLoaded] when loadCourses succeeds',
      build: () {
        when(() => mockCourseRepo.getCourses())
            .thenAnswer((_) async => [sampleCourse]);
        when(() => mockProgressRepo.getAllProgress()).thenAnswer((_) async => {
              'l1': const LessonProgress(
                lessonId: 'l1',
                lastPositionSec: 95,
                durationSec: 100,
                isCompleted: true,
              ),
            });
        when(() => mockProgressRepo.getLatestInProgressLesson())
            .thenAnswer((_) async => null);

        return CoursesCubit(
          courseRepository: mockCourseRepo,
          progressRepository: mockProgressRepo,
        );
      },
      act: (cubit) => cubit.loadCourses(),
      expect: () => [
        isA<CoursesLoading>(),
        isA<CoursesLoaded>().having(
          (s) => s.courses.first.progressPercent,
          'progressPercent',
          50.0, // 1 out of 2 lessons completed = 50%
        ),
      ],
    );
  });

  group('CourseDetailsCubit Tests', () {
    blocTest<CourseDetailsCubit, CourseDetailsState>(
      'unlocks first lesson and locks second lesson when first is incomplete',
      build: () {
        when(() => mockCourseRepo.getCourseById('c1'))
            .thenAnswer((_) async => sampleCourse);
        when(() => mockProgressRepo.getAllProgress())
            .thenAnswer((_) async => {});

        return CourseDetailsCubit(
          courseId: 'c1',
          courseRepository: mockCourseRepo,
          progressRepository: mockProgressRepo,
        );
      },
      act: (cubit) => cubit.loadCourseDetails(),
      expect: () => [
        isA<CourseDetailsLoading>(),
        isA<CourseDetailsLoaded>()
            .having(
              (s) => s.sections.first.lessons[0].isUnlocked,
              'lesson 1 is unlocked',
              isTrue,
            )
            .having(
              (s) => s.sections.first.lessons[1].isUnlocked,
              'lesson 2 is locked',
              isFalse,
            ),
      ],
    );
  });
}
