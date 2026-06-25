class CourseEntity {
  final String id;
  final String title;
  final String instructor;
  final String image;
  final String description;
  final int studentsCount;
  final double rating;

  const CourseEntity({
    required this.id,
    required this.title,
    required this.instructor,
    required this.image,
    required this.description,
    required this.studentsCount,
    required this.rating,
  });
}
