import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../routes/route_names.dart';

const _kSidebarBg = Color(0xFF5558CF);
const _kMainBg = Color(0xFFF4F5FA);
const _kTitleColor = Color(0xFF1A1D3D);
const _kMutedColor = Color(0xFF9496B8);
const _kBorderColor = Color(0xFFE8E8F0);
const double _kSidebarWidth = 220;

/// Shared admin layout: persistent sidebar + top breadcrumb bar.
/// Wrap each admin screen body inside this widget.
class AdminShell extends ConsumerWidget {
  final String activeRoute;
  final List<String> breadcrumbs;
  final Widget body;

  const AdminShell({
    super.key,
    required this.activeRoute,
    required this.breadcrumbs,
    required this.body,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final isDesktop = Responsive.isDesktop(context);

    void handleLogout() {
      final router = GoRouter.of(context);
      ref.read(authProvider.notifier).logout();
      ref.read(pendingLoginModalProvider.notifier).state = true;
      router.go(Routes.home);
    }

    final sidebar = _AdminSidebar(
      activeRoute: activeRoute,
      onLogout: handleLogout,
    );

    final mainColumn = Column(
      children: [
        _AdminTopBar(
          breadcrumbs: breadcrumbs,
          userName: user?.name ?? 'Admin',
          showMenu: !isDesktop,
          onLogout: handleLogout,
        ),
        Container(height: 1, color: _kBorderColor),
        Expanded(
          child: Container(
            color: _kMainBg,
            child: body,
          ),
        ),
      ],
    );

    if (isDesktop) {
      return Scaffold(
        backgroundColor: _kMainBg,
        body: Row(
          children: [
            sidebar,
            Expanded(child: mainColumn),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: _kMainBg,
      drawer: Drawer(
        width: _kSidebarWidth,
        child: sidebar,
      ),
      body: mainColumn,
    );
  }
}

// ── Sidebar ──────────────────────────────────────────────────────────────────

class _AdminSidebar extends StatelessWidget {
  final String activeRoute;
  final VoidCallback onLogout;

  const _AdminSidebar({required this.activeRoute, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _kSidebarWidth,
      color: _kSidebarBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 28),
          // Brand logo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.grid_view_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Governess',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),
          // Nav items
          _NavItem(icon: Icons.space_dashboard_outlined, label: 'Dashboard', route: Routes.adminDashboard, activeRoute: activeRoute, exactMatch: true),
          _NavItem(icon: Icons.menu_book_outlined, label: 'Courses', route: Routes.adminCourses, activeRoute: activeRoute),
          _NavItem(icon: Icons.receipt_long_outlined, label: 'Orders', route: Routes.adminOrders, activeRoute: activeRoute),
          _NavItem(icon: Icons.people_alt_outlined, label: 'Clients', route: Routes.userList, activeRoute: activeRoute),
          _NavItem(icon: Icons.chat_bubble_outline_rounded, label: 'Messages', route: Routes.adminContacts, activeRoute: activeRoute),
          _NavItem(icon: Icons.favorite_outline, label: 'Voice of Trust', route: Routes.adminVoiceOfTrust, activeRoute: activeRoute),
          _NavItem(icon: Icons.rate_review_outlined, label: 'Review Management', route: Routes.adminReviews, activeRoute: activeRoute),
          _NavItem(icon: Icons.workspace_premium_outlined, label: 'Cam. Qualifications', route: Routes.adminQualifications, activeRoute: activeRoute),
          _NavItem(icon: Icons.perm_media_outlined, label: 'Website Assets', route: Routes.adminWebsiteAssets, activeRoute: activeRoute),
          _NavItem(icon: Icons.person_outline, label: 'My Profile', route: Routes.profile, activeRoute: activeRoute),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: _NavItem(
              icon: Icons.logout,
              label: 'Log Out',
              route: '',
              activeRoute: '',
              onTap: onLogout,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final String activeRoute;
  final bool exactMatch;
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.activeRoute,
    this.exactMatch = false,
    this.onTap,
  });

  bool get _isActive {
    if (route.isEmpty) return false;
    return exactMatch ? activeRoute == route : activeRoute.startsWith(route);
  }

  @override
  Widget build(BuildContext context) {
    final active = _isActive;
    return InkWell(
      onTap: onTap ?? (route.isNotEmpty ? () => context.go(route) : null),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: active ? Colors.white.withValues(alpha: 0.16) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: active ? Colors.white : Colors.white70,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: active ? Colors.white : Colors.white70,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Top bar ──────────────────────────────────────────────────────────────────

class _AdminTopBar extends ConsumerWidget {
  final List<String> breadcrumbs;
  final String userName;
  final bool showMenu;
  final VoidCallback onLogout;

  const _AdminTopBar({
    required this.breadcrumbs,
    required this.userName,
    required this.showMenu,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadMessagesProvider);
    return Container(
      height: 60,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          if (showMenu) ...[
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu, color: _kTitleColor),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 8),
          ],
          // Breadcrumbs
          Expanded(
            child: Row(
              children: [
                for (int i = 0; i < breadcrumbs.length; i++) ...[
                  if (i > 0)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        Icons.chevron_right,
                        size: 15,
                        color: _kMutedColor,
                      ),
                    ),
                  Text(
                    breadcrumbs[i],
                    style: TextStyle(
                      fontSize: 13,
                      color: i == breadcrumbs.length - 1
                          ? _kTitleColor
                          : _kMutedColor,
                      fontWeight: i == breadcrumbs.length - 1
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Right: notifications + administrator dropdown
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => context.push(Routes.adminNotifications),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(
                    Icons.notifications_none_outlined,
                    size: 22,
                    color: _kMutedColor,
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          unreadCount > 9 ? '9+' : '$unreadCount',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          PopupMenuButton<String>(
            offset: const Offset(0, 48),
            tooltip: 'Account',
            onSelected: (val) {
              if (val == 'logout') onLogout();
            },
            itemBuilder: (_) => [
              PopupMenuItem<String>(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: _kTitleColor,
                      ),
                    ),
                    const Text(
                      'Administrator',
                      style: TextStyle(fontSize: 11, color: _kMutedColor),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 16, color: Colors.red),
                    SizedBox(width: 10),
                    Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor: _kSidebarBg,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'A',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (!showMenu) ...[
                  const SizedBox(width: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 120),
                    child: Text(
                      userName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _kTitleColor,
                      ),
                    ),
                  ),
                ],
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 18,
                  color: _kMutedColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
