import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/order_model.dart';
import '../../providers/app_providers.dart';
import '../../routes/route_names.dart';
import 'admin_shell.dart';

const _kPrimary = Color(0xFF5558CF);
const _kTitleColor = Color(0xFF1A1D3D);
const _kMutedColor = Color(0xFF9496B8);
const _kBorderColor = Color(0xFFE8E8F0);

class OrderListScreen extends ConsumerStatefulWidget {
  const OrderListScreen({super.key});

  @override
  ConsumerState<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends ConsumerState<OrderListScreen> {
  List<OrderModel> _orders = [];
  bool _loading = true;
  String? _error;
  String? _statusFilter;

  static const _statuses = ['pending', 'processing', 'completed', 'cancelled', 'refunded'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final orders = await ref.read(orderRepositoryProvider).getAdminOrders(status: _statusFilter);
      setState(() { _orders = orders; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _updateStatus(OrderModel order, String status) async {
    try {
      await ref.read(orderRepositoryProvider).updateOrderStatus(order.id, status);
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      activeRoute: Routes.adminOrders,
      breadcrumbs: const ['Admin', 'Orders'],
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _chip('All', null),
                  ...const ['pending', 'processing', 'completed', 'cancelled', 'refunded']
                      .map((s) => _chip(s[0].toUpperCase() + s.substring(1), s)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_loading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_error != null)
              Expanded(child: Center(child: Text(_error!, style: const TextStyle(color: Colors.red))))
            else if (_orders.isEmpty)
              const Expanded(child: Center(child: Text('No orders found.', style: TextStyle(color: _kMutedColor))))
            else
              Expanded(
                child: ListView.separated(
                  itemCount: _orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _OrderRow(
                    order: _orders[i],
                    onStatusChange: (s) => _updateStatus(_orders[i], s),
                    statuses: _statuses,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, String? value) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: FilterChip(
      label: Text(label),
      selected: _statusFilter == value,
      onSelected: (_) { setState(() => _statusFilter = value); _load(); },
      selectedColor: _kPrimary.withValues(alpha: 0.15),
      checkmarkColor: _kPrimary,
      labelStyle: TextStyle(
        color: _statusFilter == value ? _kPrimary : _kMutedColor,
        fontWeight: _statusFilter == value ? FontWeight.w600 : FontWeight.normal,
        fontSize: 13,
      ),
    ),
  );
}

class _OrderRow extends StatelessWidget {
  final OrderModel order;
  final ValueChanged<String> onStatusChange;
  final List<String> statuses;
  const _OrderRow({required this.order, required this.onStatusChange, required this.statuses});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: _kBorderColor)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (_, constraints) {
            final narrow = constraints.maxWidth < 380;
            final orderInfo = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.orderNumber,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: _kTitleColor)),
                const SizedBox(height: 2),
                Text(
                  order.createdAt != null
                      ? '${order.createdAt!.day}/${order.createdAt!.month}/${order.createdAt!.year}'
                      : '',
                  style:
                      const TextStyle(fontSize: 12, color: _kMutedColor),
                ),
              ],
            );

            final priceAndStatus = Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Rs. ${order.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: _kPrimary)),
                const SizedBox(width: 12),
                _StatusDropdown(
                    current: order.status,
                    statuses: statuses,
                    onChanged: onStatusChange),
              ],
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (narrow) ...[
                  orderInfo,
                  const SizedBox(height: 8),
                  priceAndStatus,
                ] else
                  Row(children: [
                    Expanded(child: orderInfo),
                    priceAndStatus,
                  ]),
                const SizedBox(height: 10),
                if (order.billingInfo != null)
                  Text(
                      '${order.billingInfo!.fullName} · ${order.billingInfo!.email}',
                      style: const TextStyle(
                          fontSize: 13, color: _kMutedColor)),
                const SizedBox(height: 6),
                Text(
                    '${order.items.length} course(s): ${order.items.map((i) => i.title).join(', ')}',
                    style: const TextStyle(
                        fontSize: 12, color: _kMutedColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatusDropdown extends StatelessWidget {
  final String current;
  final List<String> statuses;
  final ValueChanged<String> onChanged;
  const _StatusDropdown({required this.current, required this.statuses, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _statusColor(current).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _statusColor(current).withValues(alpha: 0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: current,
          isDense: true,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _statusColor(current)),
          dropdownColor: Colors.white,
          items: statuses.map((s) => DropdownMenuItem(
            value: s,
            child: Text(s[0].toUpperCase() + s.substring(1), style: TextStyle(color: _statusColor(s), fontWeight: FontWeight.w600, fontSize: 12)),
          )).toList(),
          onChanged: (v) { if (v != null && v != current) onChanged(v); },
        ),
      ),
    );
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'completed': return const Color(0xFF22C55E);
      case 'processing': return const Color(0xFF3B82F6);
      case 'cancelled': return const Color(0xFFEF4444);
      case 'refunded': return const Color(0xFFF59E0B);
      default: return _kMutedColor;
    }
  }
}
