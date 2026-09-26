import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/courses_screen.dart';
import '../screens/course_details_screen.dart';
import '../screens/lesson_player_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const CoursesScreen();
      },
      routes: [
        GoRoute(
          path: 'course/:id',
          builder: (BuildContext context, GoRouterState state) {
            final courseId = state.pathParameters['id'] ?? '';
            return CourseDetailsScreen(courseId: courseId);
          },
        ),
        GoRoute(
          path: 'lesson/:id',
          builder: (BuildContext context, GoRouterState state) {
            final lessonId = state.pathParameters['id'] ?? '';
            return LessonPlayerScreen(lessonId: lessonId);
          },
        ),
      ],
    ),
  ],
);
