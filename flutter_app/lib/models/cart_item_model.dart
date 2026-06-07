import 'course_api_model.dart';

class CartItem {
  final CourseApiModel course;
  int quantity;

  CartItem({required this.course, this.quantity = 1});

  double get subtotal => course.price * quantity;
}
