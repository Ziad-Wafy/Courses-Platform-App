class LessonModel {
  final String id;
  final String title;
  final String description;
  final String videoUrl;
  final String pdfUrl;
  final String duration;

  LessonModel({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.pdfUrl,
    required this.duration,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json, String id) {
    return LessonModel(
      id: id,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      pdfUrl: json['pdfUrl'] ?? '',
      duration: json['duration'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'videoUrl': videoUrl,
      'pdfUrl': pdfUrl,
      'duration': duration,
    };
  }
}
