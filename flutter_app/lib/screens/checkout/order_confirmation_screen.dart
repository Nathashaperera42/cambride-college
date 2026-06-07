import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_theme.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import '../../routes/route_names.dart';

class OrderConfirmationScreen extends ConsumerStatefulWidget {
  const OrderConfirmationScreen({super.key});

  @override
  ConsumerState<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends ConsumerState<OrderConfirmationScreen> {
  OrderModel? _order;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    // Try to load the last order from state
    await ref.read(orderProvider.notifier).loadMyOrders();
    final orders = ref.read(orderProvider).orders;
    if (orders.isNotEmpty) {
      setState(() { _order = orders.first; });
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBlueBg,
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    children: [
                      Container(
                        width: 90, height: 90,
                        decoration: BoxDecoration(color: const Color(0xFF22C55E).withValues(alpha: 0.12), shape: BoxShape.circle),
                        child: const Icon(Icons.check_circle_outline, color: Color(0xFF22C55E), size: 52),
                      ),
                      const SizedBox(height: 24),
                      const Text('Order Confirmed!',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.darkNavy)),
                      const SizedBox(height: 8),
                      const Text('Thank you for your purchase. You will receive a confirmation email shortly.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.mutedText, height: 1.5, fontSize: 15)),
                      if (_order != null) ...[
                        const SizedBox(height: 28),
                        _OrderCard(order: _order!),
                      ],
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton(
                            onPressed: () => context.go(Routes.myOrders),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.royalBlue,
                              side: const BorderSide(color: AppColors.royalBlue),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('View Orders'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () => context.go(Routes.home),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.royalBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Browse More Courses'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Order Details', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.darkNavy)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: order.statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(order.status.toUpperCase(),
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: order.statusColor)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('Order #${order.orderNumber}', style: const TextStyle(color: AppColors.mutedText, fontSize: 13)),
          const Divider(height: 24),
          ...order.items.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: Text(item.title, style: const TextStyle(fontSize: 14, color: AppColors.darkText))),
              Text('Rs. ${item.price.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.darkNavy)),
            ]),
          )),
          const Divider(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Total', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.darkNavy)),
            Text('Rs. ${order.total.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.royalBlue)),
          ]),
        ],
      ),
    );
  }
}
