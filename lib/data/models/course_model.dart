import 'package:equatable/equatable.dart';
import 'lesson_model.dart';
import 'section_model.dart';

class CourseModel extends Equatable {
  final String id;
  final String title;
  final String instructor;
  final String description;
  final String thumbnail;
  final List<SectionModel> sections;

  const CourseModel({
    required this.id,
    required this.title,
    required this.instructor,
    required this.description,
    required this.thumbnail,
    required this.sections,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] as String,
      title: json['title'] as String,
      instructor: json['instructor'] as String,
      description: json['description'] as String? ?? '',
      thumbnail: json['thumbnail'] as String,
      sections: (json['sections'] as List<dynamic>?)
              ?.map((e) => SectionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'instructor': instructor,
      'description': description,
      'thumbnail': thumbnail,
      'sections': sections.map((e) => e.toJson()).toList(),
    };
  }

  /// Flat list of all lessons in the course across all sections
  List<LessonModel> get allLessons => [
        for (final section in sections) ...section.lessons,
      ];

  int get totalLessonsCount => allLessons.length;

  int get totalDurationSec =>
      allLessons.fold<int>(0, (sum, lesson) => sum + lesson.durationSec);

  @override
  List<Object?> get props => [
        id,
        title,
        instructor,
        description,
        thumbnail,
        sections,
      ];
}
