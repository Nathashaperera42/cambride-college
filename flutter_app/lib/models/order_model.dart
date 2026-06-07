import 'package:flutter/material.dart' show Color;

class OrderItem {
  final String courseId;
  final String title;
  final double price;
  final String? thumbnail;

  const OrderItem({
    required this.courseId,
    required this.title,
    required this.price,
    this.thumbnail,
  });

  factory OrderItem.fromJson(Map<String, dynamic> j) {
    final course = j['course'];
    final courseId = course is Map
        ? (course['_id'] ?? course['id'] ?? '').toString()
        : (course ?? '').toString();
    final title = course is Map ? (course['title'] ?? j['title'] ?? '') : (j['title'] ?? '');
    return OrderItem(
      courseId: courseId,
      title: title,
      price: (j['price'] ?? 0).toDouble(),
      thumbnail: course is Map ? course['thumbnail'] : null,
    );
  }
}

class BillingInfo {
  final String fullName;
  final String email;
  final String? phone;
  final String? address;
  final String? city;
  final String? country;

  const BillingInfo({
    required this.fullName,
    required this.email,
    this.phone,
    this.address,
    this.city,
    this.country,
  });

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'address': address,
        'city': city,
        'country': country ?? 'Sri Lanka',
      };

  factory BillingInfo.fromJson(Map<String, dynamic> j) => BillingInfo(
        fullName: j['fullName'] ?? '',
        email: j['email'] ?? '',
        phone: j['phone'],
        address: j['address'],
        city: j['city'],
        country: j['country'],
      );
}

class OrderModel {
  final String id;
  final String orderNumber;
  final List<OrderItem> items;
  final BillingInfo? billingInfo;
  final double subtotal;
  final double tax;
  final double total;
  final String status;
  final DateTime? createdAt;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.items,
    this.billingInfo,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.status,
    this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> j) => OrderModel(
        id: (j['_id'] ?? j['id'] ?? '').toString(),
        orderNumber: j['orderNumber'] ?? '',
        items: (j['items'] as List? ?? [])
            .map((i) => OrderItem.fromJson(i as Map<String, dynamic>))
            .toList(),
        billingInfo: j['billingInfo'] != null
            ? BillingInfo.fromJson(j['billingInfo'] as Map<String, dynamic>)
            : null,
        subtotal: (j['subtotal'] ?? 0).toDouble(),
        tax: (j['tax'] ?? 0).toDouble(),
        total: (j['total'] ?? 0).toDouble(),
        status: j['status'] ?? 'pending',
        createdAt: j['createdAt'] != null
            ? DateTime.tryParse(j['createdAt'].toString())
            : null,
      );

  Color get statusColor {
    switch (status) {
      case 'completed':
        return const Color(0xFF22C55E);
      case 'processing':
        return const Color(0xFF3B82F6);
      case 'cancelled':
        return const Color(0xFFEF4444);
      case 'refunded':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6B7280);
    }
  }
}
