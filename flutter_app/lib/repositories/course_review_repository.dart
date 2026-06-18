import '../core/constants/api_constants.dart';
import '../core/network/dio_client.dart';
import '../models/course_review_model.dart';

class CourseReviewRepository {
  final DioClient client;
  CourseReviewRepository(this.client);

  Future<List<CourseReviewModel>> getForCourse(String courseId) async {
    try {
      final res = await client.dio.get('${ApiConstants.courseReviews}/course/$courseId');
      final data = res.data['data'] as List? ?? [];
      return data.map((j) => CourseReviewModel.fromJson(j as Map<String, dynamic>)).toList();
    } catch (e) {
      throw client.toApiException(e);
    }
  }

  /// Submits a rating/review as the logged-in user. Returns the created
  /// review plus the server's confirmation message.
  Future<(CourseReviewModel, String)> create({
    required String courseId,
    required int rating,
    String? message,
  }) async {
    try {
      final res = await client.dio.post(ApiConstants.courseReviews, data: {
        'courseId': courseId,
        'rating': rating,
        if (message != null && message.isNotEmpty) 'message': message,
      });
      final review = CourseReviewModel.fromJson(res.data['data'] as Map<String, dynamic>);
      final confirmation = res.data['message'] as String? ?? 'Thank you for rating this course!';
      return (review, confirmation);
    } catch (e) {
      throw client.toApiException(e);
    }
  }

  Future<List<CourseReviewModel>> getAdminAll({String? courseId}) async {
    try {
      final res = await client.dio.get(
        ApiConstants.courseReviewsAdmin,
        queryParameters: {if (courseId != null) 'courseId': courseId},
      );
      final data = res.data['data'] as List? ?? [];
      return data.map((j) => CourseReviewModel.fromJson(j as Map<String, dynamic>)).toList();
    } catch (e) {
      throw client.toApiException(e);
    }
  }

  Future<CourseReviewModel> reply(String id, String adminReply) async {
    try {
      final res = await client.dio.patch('${ApiConstants.courseReviews}/$id/reply', data: {'adminReply': adminReply});
      return CourseReviewModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw client.toApiException(e);
    }
  }

  Future<void> delete(String id) async {
    try {
      await client.dio.delete('${ApiConstants.courseReviews}/$id');
    } catch (e) {
      throw client.toApiException(e);
    }
  }
}
