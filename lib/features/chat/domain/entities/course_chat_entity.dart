abstract class CourseChatEntity {
  final String id;
  final String title;
  final String image;
  final String description;
  final double rating;
  final int studentsCount;
  final String instructor;

  CourseChatEntity({
    required this.id,
    required this.title,
    required this.image,
    required this.description,
    required this.rating,
    required this.studentsCount,
    required this.instructor,
  });
}
