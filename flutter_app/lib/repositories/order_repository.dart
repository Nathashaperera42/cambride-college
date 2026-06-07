import '../core/constants/api_constants.dart';
import '../core/network/dio_client.dart';
import '../models/order_model.dart';
import '../models/course_api_model.dart';

class OrderRepository {
  final DioClient client;
  OrderRepository(this.client);

  Future<OrderModel> createOrder({
    required List<String> courseIds,
    required BillingInfo billingInfo,
  }) async {
    try {
      final res = await client.dio.post(ApiConstants.orders, data: {
        'items': courseIds.map((id) => {'courseId': id}).toList(),
        'billingInfo': billingInfo.toJson(),
      });
      return OrderModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } catch (e) { throw client.toApiException(e); }
  }

  Future<List<OrderModel>> getMyOrders() async {
    try {
      final res = await client.dio.get(ApiConstants.myOrders);
      return (res.data['data'] as List? ?? [])
          .map((j) => OrderModel.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (e) { throw client.toApiException(e); }
  }

  Future<OrderModel> getMyOrder(String id) async {
    try {
      final res = await client.dio.get('${ApiConstants.myOrders}/$id');
      return OrderModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } catch (e) { throw client.toApiException(e); }
  }

  Future<List<CourseApiModel>> getMyCourses() async {
    try {
      final res = await client.dio.get(ApiConstants.myCourses);
      return (res.data['data'] as List? ?? [])
          .map((j) => CourseApiModel.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (e) { throw client.toApiException(e); }
  }

  Future<Map<String, dynamic>> createStripeSession(String orderId) async {
    try {
      final res = await client.dio.post(
        ApiConstants.createStripeSession,
        data: {'orderId': orderId},
      );
      return res.data['data'] as Map<String, dynamic>;
    } catch (e) { throw client.toApiException(e); }
  }

  Future<List<OrderModel>> getAdminOrders({int page = 1, String? status, String? search}) async {
    try {
      final res = await client.dio.get(
        ApiConstants.ordersAdmin,
        queryParameters: {
          'page': page,
          if (status != null) 'status': status,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );
      return (res.data['data']['orders'] as List? ?? [])
          .map((j) => OrderModel.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (e) { throw client.toApiException(e); }
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final res = await client.dio.get(ApiConstants.dashboardStats);
      return res.data['data'] as Map<String, dynamic>;
    } catch (e) { throw client.toApiException(e); }
  }

  Future<void> updateOrderStatus(String id, String status) async {
    try {
      await client.dio.patch('/orders/admin/$id/status', data: {'status': status});
    } catch (e) { throw client.toApiException(e); }
  }
}
