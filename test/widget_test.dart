import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:thaheen_lms/data/models/course_model.dart';
import 'package:thaheen_lms/data/repositories/course_repository.dart';
import 'package:thaheen_lms/data/repositories/progress_repository.dart';
import 'package:thaheen_lms/main.dart';

class MockCourseRepository extends Mock implements ICourseRepository {}

class MockProgressRepository extends Mock implements IProgressRepository {}

void main() {
  late MockCourseRepository mockCourseRepo;
  late MockProgressRepository mockProgressRepo;

  setUp(() {
    mockCourseRepo = MockCourseRepository();
    mockProgressRepo = MockProgressRepository();

    when(() => mockCourseRepo.getCourses())
        .thenAnswer((_) async => <CourseModel>[]);
    when(() => mockProgressRepo.getAllProgress())
        .thenAnswer((_) async => {});
    when(() => mockProgressRepo.getLatestInProgressLesson())
        .thenAnswer((_) async => null);
    when(() => mockProgressRepo.getIsDarkMode())
        .thenAnswer((_) async => false);
  });

  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(
      courseRepository: mockCourseRepo,
      progressRepository: mockProgressRepo,
    ));

    expect(find.text('منصة تعليمية'), findsOneWidget);
  });
}
