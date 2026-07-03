class SectionModel {
  final String id;
  final String title;
  final String duration;
  final int order;

  SectionModel({
    required this.id,
    required this.title,
    required this.duration,
    required this.order,
  });

  factory SectionModel.fromJson(
    Map<String, dynamic> json,
    String id,
  ) {
    return SectionModel(
      id: id,
      title: json['title'] ?? '',
      duration: json['duration'] ?? '',
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'duration': duration,
      'order': order,
    };
  }
}
