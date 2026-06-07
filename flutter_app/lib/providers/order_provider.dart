import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order_model.dart';
import '../models/course_api_model.dart';
import 'app_providers.dart';

class OrderState {
  final List<OrderModel> orders;
  final List<CourseApiModel> myCourses;
  final bool loading;
  final String? error;

  const OrderState({
    this.orders = const [],
    this.myCourses = const [],
    this.loading = false,
    this.error,
  });

  OrderState copyWith({
    List<OrderModel>? orders,
    List<CourseApiModel>? myCourses,
    bool? loading,
    String? error,
  }) =>
      OrderState(
        orders: orders ?? this.orders,
        myCourses: myCourses ?? this.myCourses,
        loading: loading ?? this.loading,
        error: error,
      );
}

class OrderNotifier extends StateNotifier<OrderState> {
  final Ref _ref;
  OrderNotifier(this._ref) : super(const OrderState());

  Future<void> loadMyOrders() async {
    state = state.copyWith(loading: true);
    try {
      final orders = await _ref.read(orderRepositoryProvider).getMyOrders();
      state = state.copyWith(loading: false, orders: orders);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> loadMyCourses() async {
    state = state.copyWith(loading: true);
    try {
      final courses = await _ref.read(orderRepositoryProvider).getMyCourses();
      state = state.copyWith(loading: false, myCourses: courses);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<OrderModel?> createOrder({
    required List<String> courseIds,
    required BillingInfo billingInfo,
  }) async {
    state = state.copyWith(loading: true);
    try {
      final order = await _ref.read(orderRepositoryProvider).createOrder(
            courseIds: courseIds,
            billingInfo: billingInfo,
          );
      state = state.copyWith(loading: false, orders: [order, ...state.orders]);
      return order;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return null;
    }
  }

  Future<String?> createStripeSession(String orderId) async {
    try {
      final data = await _ref.read(orderRepositoryProvider).createStripeSession(orderId);
      return data['url'] as String?;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }
}

final orderProvider = StateNotifierProvider<OrderNotifier, OrderState>(
  (ref) => OrderNotifier(ref),
);
