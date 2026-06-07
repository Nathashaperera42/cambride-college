import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_providers.dart';
import '../../providers/notification_provider.dart';
import '../../routes/route_names.dart';
import 'admin_shell.dart';

const _kPrimary = Color(0xFF5558CF);
const _kGreen = Color(0xFF22C55E);
const _kGold = Color(0xFFE8B21D);
const _kRed = Color(0xFFEF4444);
const _kTitleColor = Color(0xFF1A1D3D);
const _kMutedColor = Color(0xFF9496B8);
const _kBorderColor = Color(0xFFE8E8F0);

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  Map<String, dynamic>? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final data = await ref.read(orderRepositoryProvider).getDashboardStats();
      setState(() { _stats = data; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final unreadMessages = ref.watch(unreadMessagesProvider);
    return AdminShell(
      activeRoute: Routes.adminDashboard,
      breadcrumbs: const ['Admin', 'Dashboard'],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome back, ${user?.name ?? 'Admin'}!',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _kTitleColor)),
            const SizedBox(height: 4),
            const Text('Here\'s what\'s happening with your courses today.',
                style: TextStyle(fontSize: 14, color: _kMutedColor)),
            const SizedBox(height: 24),

            // Stats row
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_stats != null) ...[
              _StatsGrid(stats: _stats!),
              const SizedBox(height: 28),
            ],

            // Action cards
            const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _kTitleColor)),
            const SizedBox(height: 14),
            LayoutBuilder(builder: (context, constraints) {
              final twoCol = constraints.maxWidth >= 500;
              final cards = [
                _ActionCard(icon: Icons.menu_book_outlined, title: 'Manage Courses', subtitle: 'Add, edit or remove courses', onTap: () => context.push(Routes.adminCourses), accentColor: _kPrimary),
                _ActionCard(icon: Icons.receipt_long_outlined, title: 'View Orders', subtitle: 'See all customer orders', onTap: () => context.push(Routes.adminOrders), accentColor: _kGreen),
                _ActionCard(icon: Icons.people_alt_outlined, title: 'Manage Clients', subtitle: 'View and edit client accounts', onTap: () => context.push(Routes.userList), accentColor: _kGold),
                _ActionCard(icon: Icons.chat_bubble_outline_rounded, title: 'Contact Messages', subtitle: 'View customer inquiries', onTap: () => context.push(Routes.adminContacts), accentColor: _kRed, badgeCount: unreadMessages),
                _ActionCard(icon: Icons.photo_library_outlined, title: 'Site Images', subtitle: 'Upload & manage website images', onTap: () => context.push(Routes.adminSiteImages), accentColor: const Color(0xFF7C3AED)),
                _ActionCard(icon: Icons.person_outline, title: 'My Profile', subtitle: 'Update your admin account', onTap: () => context.push(Routes.profile), accentColor: _kMutedColor),
              ];
              if (twoCol) {
                return Wrap(spacing: 16, runSpacing: 16,
                    children: cards.map((c) => SizedBox(width: (constraints.maxWidth - 16) / 2, child: c)).toList());
              }
              return Column(children: cards.map((c) => Padding(padding: const EdgeInsets.only(bottom: 16), child: c)).toList());
            }),

            // Recent orders
            if (_stats?['recentOrders'] != null && (_stats!['recentOrders'] as List).isNotEmpty) ...[
              const SizedBox(height: 28),
              const Text('Recent Orders', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _kTitleColor)),
              const SizedBox(height: 14),
              ..._buildRecentOrders(_stats!['recentOrders'] as List),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRecentOrders(List orders) => orders.take(5).map((o) {
    final map = o as Map<String, dynamic>;
    final user = map['user'] as Map<String, dynamic>?;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: _kBorderColor)),
      child: ListTile(
        dense: true,
        title: Text(map['orderNumber'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: _kTitleColor)),
        subtitle: Text(user?['name'] ?? '', style: const TextStyle(fontSize: 12, color: _kMutedColor)),
        trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('Rs. ${(map['total'] as num?)?.toStringAsFixed(2) ?? '0.00'}', style: const TextStyle(fontWeight: FontWeight.w700, color: _kPrimary, fontSize: 13)),
          const SizedBox(height: 2),
          Text((map['status'] as String? ?? '').toUpperCase(), style: const TextStyle(fontSize: 10, color: _kMutedColor)),
        ]),
      ),
    );
  }).toList();
}

class _StatsGrid extends StatelessWidget {
  final Map<String, dynamic> stats;
  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatItem('Total Revenue', 'Rs. ${(stats['totalRevenue'] as num?)?.toStringAsFixed(2) ?? '0.00'}', Icons.attach_money_rounded, _kGreen),
      _StatItem('Total Orders', '${stats['totalOrders'] ?? 0}', Icons.receipt_long_outlined, _kPrimary),
      _StatItem('Customers', '${stats['totalCustomers'] ?? 0}', Icons.people_alt_outlined, _kGold),
      _StatItem('Courses', '${stats['totalCourses'] ?? 0}', Icons.menu_book_outlined, _kRed),
    ];
    return LayoutBuilder(builder: (_, constraints) {
      final cols = constraints.maxWidth >= 560 ? 4 : 2;
      final w = (constraints.maxWidth - (cols - 1) * 12) / cols;
      return Wrap(spacing: 12, runSpacing: 12,
          children: items.map((i) => SizedBox(width: w, child: _StatCard(item: i))).toList());
    });
  }
}

class _StatItem {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatItem(this.label, this.value, this.icon, this.color);
}

class _StatCard extends StatelessWidget {
  final _StatItem item;
  const _StatCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: _kBorderColor)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: item.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(item.icon, color: item.color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(item.value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _kTitleColor)),
          const SizedBox(height: 2),
          Text(item.label, style: const TextStyle(fontSize: 12, color: _kMutedColor)),
        ]),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  final Color accentColor;
  final int badgeCount;
  const _ActionCard({required this.icon, required this.title, required this.subtitle, required this.onTap, required this.accentColor, this.badgeCount = 0});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: _kBorderColor)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(color: accentColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: accentColor, size: 24),
                ),
                if (badgeCount > 0)
                  Positioned(
                    right: -4, top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: Text(badgeCount > 9 ? '9+' : '$badgeCount',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _kTitleColor)),
              const SizedBox(height: 3),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: _kMutedColor)),
            ])),
            Icon(Icons.arrow_forward_ios, size: 14, color: accentColor),
          ]),
        ),
      ),
    );
  }
}
