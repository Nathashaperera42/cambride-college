import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item_model.dart';
import '../models/course_api_model.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addCourse(CourseApiModel course) {
    final exists = state.any((item) => item.course.id == course.id);
    if (!exists) {
      state = [...state, CartItem(course: course)];
    }
  }

  void removeCourse(String courseId) {
    state = state.where((item) => item.course.id != courseId).toList();
  }

  void clear() => state = [];

  bool contains(String courseId) => state.any((item) => item.course.id == courseId);

  double get total => state.fold(0, (sum, item) => sum + item.subtotal);

  int get count => state.length;
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>(
  (ref) => CartNotifier(),
);
