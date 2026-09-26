import 'package:equatable/equatable.dart';
import 'lesson_model.dart';

class SectionModel extends Equatable {
  final String id;
  final String title;
  final List<LessonModel> lessons;

  const SectionModel({
    required this.id,
    required this.title,
    required this.lessons,
  });

  factory SectionModel.fromJson(Map<String, dynamic> json) {
    return SectionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      lessons: (json['lessons'] as List<dynamic>?)
              ?.map((e) => LessonModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'lessons': lessons.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [id, title, lessons];
}
