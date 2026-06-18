import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/review_model.dart';
import 'app_providers.dart';

class ReviewState {
  final List<ReviewModel> reviews;
  final bool loading;
  final String? error;

  const ReviewState({this.reviews = const [], this.loading = false, this.error});

  ReviewState copyWith({List<ReviewModel>? reviews, bool? loading, String? error}) => ReviewState(
        reviews: reviews ?? this.reviews,
        loading: loading ?? this.loading,
        error: error,
      );
}

class ReviewNotifier extends StateNotifier<ReviewState> {
  final Ref _ref;
  ReviewNotifier(this._ref) : super(const ReviewState());

  Future<void> loadForVoiceOfTrust(String voiceOfTrustId) async {
    state = state.copyWith(loading: true);
    try {
      final reviews = await _ref.read(reviewRepositoryProvider).getForVoiceOfTrust(voiceOfTrustId);
      state = state.copyWith(loading: false, reviews: reviews);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> loadAdminAll({String? voiceOfTrustId}) async {
    state = state.copyWith(loading: true);
    try {
      final reviews = await _ref.read(reviewRepositoryProvider).getAdminAll(voiceOfTrustId: voiceOfTrustId);
      state = state.copyWith(loading: false, reviews: reviews);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  /// Returns the thank-you message on success, or null on failure.
  Future<String?> submit({
    required String voiceOfTrustId,
    required String customerName,
    required String message,
    int? rating,
  }) async {
    try {
      final (review, thankYou) = await _ref.read(reviewRepositoryProvider).create(
            voiceOfTrustId: voiceOfTrustId,
            customerName: customerName,
            message: message,
            rating: rating,
          );
      state = state.copyWith(reviews: [review, ...state.reviews]);
      return thankYou;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<bool> reply(String id, String adminReply) async {
    try {
      final updated = await _ref.read(reviewRepositoryProvider).reply(id, adminReply);
      state = state.copyWith(reviews: state.reviews.map((r) => r.id == id ? updated : r).toList());
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> delete(String id) async {
    try {
      await _ref.read(reviewRepositoryProvider).delete(id);
      state = state.copyWith(reviews: state.reviews.where((r) => r.id != id).toList());
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final reviewProvider = StateNotifierProvider<ReviewNotifier, ReviewState>(
  (ref) => ReviewNotifier(ref),
);
