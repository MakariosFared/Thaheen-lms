import 'package:equatable/equatable.dart';

class LessonModel extends Equatable {
  final String id;
  final String title;
  final int durationSec;
  final String video;

  const LessonModel({
    required this.id,
    required this.title,
    required this.durationSec,
    required this.video,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] as String,
      title: json['title'] as String,
      durationSec: (json['durationSec'] as num).toInt(),
      video: json['video'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'durationSec': durationSec,
      'video': video,
    };
  }

  @override
  List<Object?> get props => [id, title, durationSec, video];
}
