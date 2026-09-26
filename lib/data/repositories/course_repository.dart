import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/course_model.dart';
import '../models/lesson_model.dart';

abstract class ICourseRepository {
  Future<List<CourseModel>> getCourses();
  Future<CourseModel?> getCourseById(String id);
  Future<({CourseModel course, LessonModel lesson})?> findLessonWithCourse(
      String lessonId);
}

class CourseRepository implements ICourseRepository {
  final String assetPath;
  List<CourseModel>? _cachedCourses;

  CourseRepository({this.assetPath = 'assets/data/courses.json'});

  @override
  Future<List<CourseModel>> getCourses() async {
    if (_cachedCourses != null) {
      return _cachedCourses!;
    }

    try {
      final jsonString = await rootBundle.loadString(assetPath);
      final dynamic decoded = json.decode(jsonString);

      if (decoded is Map<String, dynamic> && decoded['courses'] is List) {
        final rawList = decoded['courses'] as List<dynamic>;
        _cachedCourses = rawList
            .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        _cachedCourses = [];
      }

      return _cachedCourses!;
    } catch (e) {
      throw Exception('Failed to load courses from $assetPath: $e');
    }
  }

  @override
  Future<CourseModel?> getCourseById(String id) async {
    final courses = await getCourses();
    try {
      return courses.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<({CourseModel course, LessonModel lesson})?> findLessonWithCourse(
      String lessonId) async {
    final courses = await getCourses();
    for (final course in courses) {
      for (final section in course.sections) {
        for (final lesson in section.lessons) {
          if (lesson.id == lessonId) {
            return (course: course, lesson: lesson);
          }
        }
      }
    }
    return null;
  }
}
