import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_theme.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import '../../routes/route_names.dart';

class MyOrdersScreen extends ConsumerStatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  ConsumerState<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends ConsumerState<MyOrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(orderProvider.notifier).loadMyOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderProvider);

    return Scaffold(
      backgroundColor: AppColors.lightBlueBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: AppColors.darkNavy, onPressed: () => context.go(Routes.home)),
        title: const Text('My Orders', style: TextStyle(color: AppColors.darkNavy, fontWeight: FontWeight.w700, fontSize: 18)),
      ),
      body: state.loading
          ? const Center(child: CircularProgressIndicator())
          : state.orders.isEmpty
              ? _empty()
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: state.orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _OrderCard(order: state.orders[i]),
                ),
    );
  }

  Widget _empty() => const Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.receipt_long_outlined, size: 72, color: AppColors.mutedText),
      SizedBox(height: 16),
      Text('No orders yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.darkNavy)),
      SizedBox(height: 8),
      Text('Your order history will appear here.', style: TextStyle(color: AppColors.mutedText)),
    ]),
  );
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Order #${order.orderNumber}',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.darkNavy)),
              if (order.createdAt != null)
                Text('${order.createdAt!.day}/${order.createdAt!.month}/${order.createdAt!.year}',
                    style: const TextStyle(fontSize: 12, color: AppColors.mutedText)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: order.statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(order.status.toUpperCase(),
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: order.statusColor)),
          ),
        ]),
        const SizedBox(height: 12),
        ...order.items.map((item) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(children: [
            const Icon(Icons.school_outlined, size: 16, color: AppColors.royalBlue),
            const SizedBox(width: 8),
            Expanded(child: Text(item.title, style: const TextStyle(fontSize: 13, color: AppColors.darkText))),
            Text('Rs. ${item.price.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.darkNavy)),
          ]),
        )),
        const Divider(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Total', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.darkNavy)),
          Text('Rs. ${order.total.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.royalBlue)),
        ]),
      ]),
    );
  }
}
