import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_theme.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/cart_item_model.dart';
import '../../routes/route_names.dart';
import '../../widgets/common.dart';
import '../../widgets/auth_modal.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.lightBlueBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: AppColors.darkNavy, onPressed: () => context.go(Routes.home)),
        title: const Text('Shopping Cart', style: TextStyle(color: AppColors.darkNavy, fontWeight: FontWeight.w700, fontSize: 18)),
        actions: [
          if (cart.isNotEmpty)
            TextButton(
              onPressed: () { cartNotifier.clear(); },
              child: const Text('Clear All', style: TextStyle(color: Colors.red)),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: cart.isEmpty ? _emptyCart(context) : _cartBody(context, ref, cart, cartNotifier),
    );
  }

  Widget _emptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_cart_outlined, size: 80, color: AppColors.mutedText),
          const SizedBox(height: 16),
          const Text('Your cart is empty', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.darkNavy)),
          const SizedBox(height: 8),
          const Text('Browse our courses and add them to your cart.', style: TextStyle(color: AppColors.mutedText)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go(Routes.home),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.royalBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Browse Courses', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _cartBody(BuildContext context, WidgetRef ref, List<CartItem> cart, CartNotifier cartNotifier) {
    final total = cartNotifier.total;

    return ContentWrap(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: LayoutBuilder(builder: (context, constraints) {
        final wide = constraints.maxWidth >= 860;
        final listSection = Column(
          children: cart.map((item) => _CartItemCard(item: item, onRemove: () => cartNotifier.removeCourse(item.course.id))).toList(),
        );
        final summarySection = _OrderSummary(total: total, itemCount: cart.length, onCheckout: () {
          final auth = ref.read(authProvider);
          if (auth.status != AuthStatus.authenticated) {
            showLoginModal(context);
          } else {
            context.go(Routes.checkout);
          }
        });

        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: listSection),
              const SizedBox(width: 24),
              Expanded(flex: 2, child: summarySection),
            ],
          );
        }
        return Column(children: [listSection, const SizedBox(height: 24), summarySection]);
      }),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onRemove;
  const _CartItemCard({required this.item, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final course = item.course;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: course.thumbnail != null
                ? CachedNetworkImage(imageUrl: course.thumbnail!, width: 80, height: 70, fit: BoxFit.cover,
                    placeholder: (_, __) => _thumbPlaceholder(course.gold),
                    errorWidget: (_, __, ___) => _thumbPlaceholder(course.gold))
                : _thumbPlaceholder(course.gold),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.darkNavy), maxLines: 2, overflow: TextOverflow.ellipsis),
                if (course.category.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(course.category, style: const TextStyle(fontSize: 12, color: AppColors.mutedText)),
                ],
                const SizedBox(height: 8),
                Text('Rs. ${course.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.royalBlue)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
            onPressed: onRemove,
            tooltip: 'Remove',
          ),
        ],
      ),
    );
  }

  Widget _thumbPlaceholder(bool gold) => Container(
    width: 80, height: 70,
    decoration: BoxDecoration(gradient: gold ? AppColors.goldCardGradient : AppColors.blueCardGradient),
    child: Icon(gold ? Icons.emoji_events_outlined : Icons.school_outlined, color: Colors.white54, size: 32),
  );
}

class _OrderSummary extends StatelessWidget {
  final double total;
  final int itemCount;
  final VoidCallback onCheckout;
  const _OrderSummary({required this.total, required this.itemCount, required this.onCheckout});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Order Summary', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.darkNavy)),
          const SizedBox(height: 16),
          _row('Courses ($itemCount)', 'Rs. ${total.toStringAsFixed(2)}'),
          _row('Tax', 'Rs. 0.00'),
          const Divider(height: 24),
          _row('Total', 'Rs. ${total.toStringAsFixed(2)}', bold: true),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onCheckout,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.royalBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Proceed to Checkout', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: bold ? AppColors.darkNavy : AppColors.mutedText, fontWeight: bold ? FontWeight.w700 : FontWeight.normal, fontSize: bold ? 16 : 14)),
        Text(value, style: TextStyle(color: AppColors.darkNavy, fontWeight: bold ? FontWeight.w700 : FontWeight.w500, fontSize: bold ? 16 : 14)),
      ],
    ),
  );
}
