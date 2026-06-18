import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/course_review_model.dart';
import 'app_providers.dart';

class CourseReviewState {
  final List<CourseReviewModel> reviews;
  final bool loading;
  final String? error;

  const CourseReviewState({this.reviews = const [], this.loading = false, this.error});

  CourseReviewState copyWith({List<CourseReviewModel>? reviews, bool? loading, String? error}) =>
      CourseReviewState(
        reviews: reviews ?? this.reviews,
        loading: loading ?? this.loading,
        error: error,
      );
}

class CourseReviewNotifier extends StateNotifier<CourseReviewState> {
  final Ref _ref;
  CourseReviewNotifier(this._ref) : super(const CourseReviewState());

  Future<void> loadAdminAll({String? courseId}) async {
    state = state.copyWith(loading: true);
    try {
      final reviews = await _ref.read(courseReviewRepositoryProvider).getAdminAll(courseId: courseId);
      state = state.copyWith(loading: false, reviews: reviews);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<bool> reply(String id, String adminReply) async {
    try {
      final updated = await _ref.read(courseReviewRepositoryProvider).reply(id, adminReply);
      state = state.copyWith(reviews: state.reviews.map((r) => r.id == id ? updated : r).toList());
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> delete(String id) async {
    try {
      await _ref.read(courseReviewRepositoryProvider).delete(id);
      state = state.copyWith(reviews: state.reviews.where((r) => r.id != id).toList());
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final courseReviewProvider = StateNotifierProvider<CourseReviewNotifier, CourseReviewState>(
  (ref) => CourseReviewNotifier(ref),
);
