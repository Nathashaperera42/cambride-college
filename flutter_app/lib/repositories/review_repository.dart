import '../core/constants/api_constants.dart';
import '../core/network/dio_client.dart';
import '../models/review_model.dart';

class ReviewRepository {
  final DioClient client;
  ReviewRepository(this.client);

  Future<List<ReviewModel>> getForVoiceOfTrust(String voiceOfTrustId) async {
    try {
      final res = await client.dio.get('${ApiConstants.reviews}/voice-of-trust/$voiceOfTrustId');
      final data = res.data['data'] as List? ?? [];
      return data.map((j) => ReviewModel.fromJson(j as Map<String, dynamic>)).toList();
    } catch (e) {
      throw client.toApiException(e);
    }
  }

  /// Submits a review as the logged-in user (the server derives the
  /// reviewer's name from the auth token). Returns the created review plus
  /// the server's thank-you message.
  Future<(ReviewModel, String)> create({
    required String voiceOfTrustId,
    required String message,
    int? rating,
  }) async {
    try {
      final res = await client.dio.post(ApiConstants.reviews, data: {
        'voiceOfTrustId': voiceOfTrustId,
        'message': message,
        if (rating != null) 'rating': rating,
      });
      final review = ReviewModel.fromJson(res.data['data'] as Map<String, dynamic>);
      final thankYou = res.data['message'] as String? ??
          'Thank you for your review. We appreciate your feedback and support.';
      return (review, thankYou);
    } catch (e) {
      throw client.toApiException(e);
    }
  }

  Future<List<ReviewModel>> getAdminAll({String? voiceOfTrustId}) async {
    try {
      final res = await client.dio.get(
        ApiConstants.reviewsAdmin,
        queryParameters: {if (voiceOfTrustId != null) 'voiceOfTrustId': voiceOfTrustId},
      );
      final data = res.data['data'] as List? ?? [];
      return data.map((j) => ReviewModel.fromJson(j as Map<String, dynamic>)).toList();
    } catch (e) {
      throw client.toApiException(e);
    }
  }

  Future<ReviewModel> reply(String id, String adminReply) async {
    try {
      final res = await client.dio.patch('${ApiConstants.reviews}/$id/reply', data: {'adminReply': adminReply});
      return ReviewModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw client.toApiException(e);
    }
  }

  Future<void> delete(String id) async {
    try {
      await client.dio.delete('${ApiConstants.reviews}/$id');
    } catch (e) {
      throw client.toApiException(e);
    }
  }
}
