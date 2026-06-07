import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/course_api_model.dart';
import 'app_providers.dart';

class CourseState {
  final List<CourseApiModel> courses;
  final bool loading;
  final String? error;

  const CourseState({this.courses = const [], this.loading = false, this.error});

  CourseState copyWith({List<CourseApiModel>? courses, bool? loading, String? error}) =>
      CourseState(
        courses: courses ?? this.courses,
        loading: loading ?? this.loading,
        error: error,
      );
}

class CourseNotifier extends StateNotifier<CourseState> {
  final Ref _ref;
  CourseNotifier(this._ref) : super(const CourseState());

  Future<void> loadCourses({String? category}) async {
    state = state.copyWith(loading: true);
    try {
      final courses = await _ref.read(courseRepositoryProvider).getCourses(category: category);
      state = state.copyWith(loading: false, courses: courses);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> loadAdminCourses({String? search}) async {
    state = state.copyWith(loading: true);
    try {
      final courses = await _ref.read(courseRepositoryProvider).getAdminCourses(search: search);
      state = state.copyWith(loading: false, courses: courses);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<bool> createCourse(Map<String, dynamic> data) async {
    try {
      final course = await _ref.read(courseRepositoryProvider).createCourse(data);
      state = state.copyWith(courses: [course, ...state.courses]);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> updateCourse(String id, Map<String, dynamic> data) async {
    try {
      final updated = await _ref.read(courseRepositoryProvider).updateCourse(id, data);
      state = state.copyWith(
        courses: state.courses
            .map((c) => c.id == id ? updated : c)
            .toList()
            .cast<CourseApiModel>(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> deleteCourse(String id) async {
    try {
      await _ref.read(courseRepositoryProvider).deleteCourse(id);
      state = state.copyWith(courses: state.courses.where((c) => c.id != id).toList());
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final courseProvider = StateNotifierProvider<CourseNotifier, CourseState>(
  (ref) => CourseNotifier(ref),
);
