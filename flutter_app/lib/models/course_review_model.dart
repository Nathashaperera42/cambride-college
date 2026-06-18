class CourseReviewModel {
  final String id;
  final String courseId;
  final String? courseTitle;
  final String customerName;
  final int rating;
  final String? message;
  final String? adminReply;
  final DateTime? repliedAt;
  final DateTime? createdAt;

  const CourseReviewModel({
    required this.id,
    required this.courseId,
    this.courseTitle,
    required this.customerName,
    required this.rating,
    this.message,
    this.adminReply,
    this.repliedAt,
    this.createdAt,
  });

  factory CourseReviewModel.fromJson(Map<String, dynamic> j) {
    final course = j['course'];
    return CourseReviewModel(
      id: (j['_id'] ?? j['id'] ?? '').toString(),
      courseId: course is Map ? (course['_id'] ?? '').toString() : (course ?? '').toString(),
      courseTitle: course is Map ? course['title'] as String? : null,
      customerName: j['customerName'] ?? '',
      rating: (j['rating'] as num?)?.toInt() ?? 0,
      message: j['message'],
      adminReply: j['adminReply'],
      repliedAt: j['repliedAt'] != null ? DateTime.tryParse(j['repliedAt'].toString()) : null,
      createdAt: j['createdAt'] != null ? DateTime.tryParse(j['createdAt'].toString()) : null,
    );
  }
}
