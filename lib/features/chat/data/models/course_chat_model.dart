import 'package:learning_management_system/features/chat/domain/entities/course_chat_entity.dart';

class CourseChatModel extends CourseChatEntity {
  CourseChatModel({
    required super.id,
    required super.title,
    required super.image,
    required super.instructor,
  });

  factory CourseChatModel.fromJson(Map<String, dynamic> json) {
    return CourseChatModel(
      id: json['id'],
      title: json['title'],
      image: json['image'],
      instructor: json['instructor'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'image': image, 'instructor': instructor};
  }
}
