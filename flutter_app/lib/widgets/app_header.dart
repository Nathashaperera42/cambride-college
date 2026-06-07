import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_data.dart';
import '../core/constants/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../routes/route_names.dart';
import 'auth_modal.dart';
import 'brand_logo.dart';
import 'common.dart';

class AppHeader extends ConsumerWidget {
  final int currentIndex;
  final ValueChanged<int> onNavigate;
  final VoidCallback onOpenMenu;

  const AppHeader({
    super.key,
    required this.currentIndex,
    required this.onNavigate,
    required this.onOpenMenu,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    final compact = isMobile || isTablet;
    final auth = ref.watch(authProvider);
    final isLoggedIn = auth.status == AuthStatus.authenticated;
    final isAdmin = auth.user?.isAdmin ?? false;
    final cartCount = ref.watch(cartProvider).length;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))
        ],
      ),
      child: ContentWrap(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            const BrandLogo(),
            const Spacer(),

            // ── Desktop nav ──────────────────────────────────────────────────
            if (!compact) ...[
              ...AppData.navItems.map((item) {
                final selected = item.index == currentIndex;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: InkWell(
                    onTap: () => onNavigate(item.index),
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: selected ? AppColors.royalBlue : AppColors.darkText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 2,
                            width: 20,
                            color: selected ? AppColors.gold : Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(width: 8),

              // Cart icon
              _CartIcon(count: cartCount),
              const SizedBox(width: 8),

              // Auth buttons / profile
              if (isLoggedIn)
                _ProfileMenu(
                  userName: auth.user?.name ?? '',
                  isAdmin: isAdmin,
                )
              else ...[
                TextButton(
                  onPressed: () => showLoginModal(context),
                  child: const Text('Login',
                      style: TextStyle(
                          color: AppColors.darkText,
                          fontWeight: FontWeight.w500,
                          fontSize: 14)),
                ),
                const SizedBox(width: 4),
                PillButton(
                  label: 'Register',
                  onPressed: () => showRegisterModal(context),
                ),
              ],

            // ── Mobile/tablet nav ─────────────────────────────────────────────
            ] else ...[
              _CartIcon(count: cartCount),
              const SizedBox(width: 4),
              IconButton(
                onPressed: onOpenMenu,
                icon: const Icon(Icons.menu, color: AppColors.darkNavy),
                iconSize: 28,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Cart icon with badge ──────────────────────────────────────────────────────

class _CartIcon extends StatelessWidget {
  final int count;
  const _CartIcon({required this.count});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(Routes.cart),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.shopping_cart_outlined,
                color: AppColors.darkNavy, size: 24),
            if (count > 0)
              Positioned(
                top: -6,
                right: -6,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      count > 9 ? '9+' : '$count',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Profile dropdown ──────────────────────────────────────────────────────────

class _ProfileMenu extends StatelessWidget {
  final String userName;
  final bool isAdmin;

  const _ProfileMenu({required this.userName, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';
    return PopupMenuButton<String>(
      tooltip: 'Account',
      offset: const Offset(0, 48),
      onSelected: (value) {
        switch (value) {
          case 'dashboard':
            context.push(Routes.adminDashboard);
          case 'my_courses':
            context.push(Routes.myCourses);
          case 'my_orders':
            context.push(Routes.myOrders);
          case 'profile':
            context.push(Routes.profile);
          case 'logout':
            ProviderScope.containerOf(context)
                .read(authProvider.notifier)
                .logout();
        }
      },
      itemBuilder: (_) => [
        // Header
        PopupMenuItem<String>(
          enabled: false,
          height: 40,
          child: Text(
            userName,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: Color(0xFF1A1D3D),
            ),
          ),
        ),
        const PopupMenuDivider(),
        if (isAdmin)
          const PopupMenuItem<String>(
            value: 'dashboard',
            child: Row(children: [
              Icon(Icons.admin_panel_settings_outlined,
                  size: 17, color: AppColors.royalBlue),
              SizedBox(width: 10),
              Text('Admin Dashboard', style: TextStyle(fontSize: 13)),
            ]),
          )
        else ...[
          const PopupMenuItem<String>(
            value: 'my_courses',
            child: Row(children: [
              Icon(Icons.menu_book_outlined, size: 17, color: AppColors.royalBlue),
              SizedBox(width: 10),
              Text('My Courses', style: TextStyle(fontSize: 13)),
            ]),
          ),
          const PopupMenuItem<String>(
            value: 'my_orders',
            child: Row(children: [
              Icon(Icons.receipt_long_outlined, size: 17, color: AppColors.royalBlue),
              SizedBox(width: 10),
              Text('My Orders', style: TextStyle(fontSize: 13)),
            ]),
          ),
        ],
        const PopupMenuItem<String>(
          value: 'profile',
          child: Row(children: [
            Icon(Icons.person_outline, size: 17),
            SizedBox(width: 10),
            Text('Profile', style: TextStyle(fontSize: 13)),
          ]),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'logout',
          child: Row(children: [
            Icon(Icons.logout, size: 17, color: Colors.red),
            SizedBox(width: 10),
            Text('Logout', style: TextStyle(fontSize: 13, color: Colors.red)),
          ]),
        ),
      ],
      child: CircleAvatar(
        radius: 18,
        backgroundColor: AppColors.royalBlue,
        child: Text(
          initial,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }
}

// ── Mobile drawer ─────────────────────────────────────────────────────────────

class AppDrawer extends ConsumerWidget {
  final int currentIndex;
  final ValueChanged<int> onNavigate;

  const AppDrawer({
    super.key,
    required this.currentIndex,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final isLoggedIn = auth.status == AuthStatus.authenticated;
    final isAdmin = auth.user?.isAdmin ?? false;
    final cartCount = ref.watch(cartProvider).length;

    return Drawer(
      backgroundColor: AppColors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: BrandLogo(),
            ),
            const Divider(height: 1),

            // Nav pages
            ...AppData.navItems.map((item) {
              final selected = item.index == currentIndex;
              return ListTile(
                title: Text(
                  item.label,
                  style: TextStyle(
                    color: selected ? AppColors.royalBlue : AppColors.darkText,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                selected: selected,
                onTap: () {
                  Navigator.of(context).pop();
                  onNavigate(item.index);
                },
              );
            }),

            // Cart
            ListTile(
              leading: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.shopping_cart_outlined, color: AppColors.darkNavy),
                  if (cartCount > 0)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                            color: AppColors.gold, shape: BoxShape.circle),
                        child: Center(
                          child: Text('$cartCount',
                              style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                        ),
                      ),
                    ),
                ],
              ),
              title: Text(
                'Cart${cartCount > 0 ? ' ($cartCount)' : ''}',
                style: const TextStyle(color: AppColors.darkText, fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.of(context).pop();
                context.push(Routes.cart);
              },
            ),

            const Divider(height: 1),

            // Auth section
            if (isLoggedIn) ...[
              if (isAdmin)
                ListTile(
                  leading: const Icon(Icons.admin_panel_settings_outlined,
                      color: AppColors.royalBlue),
                  title: const Text('Admin Dashboard',
                      style: TextStyle(
                          color: AppColors.royalBlue,
                          fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push(Routes.adminDashboard);
                  },
                ),
              if (!isAdmin) ...[
                ListTile(
                  leading: const Icon(Icons.menu_book_outlined),
                  title: const Text('My Courses'),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push(Routes.myCourses);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.receipt_long_outlined),
                  title: const Text('My Orders'),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push(Routes.myOrders);
                  },
                ),
              ],
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('My Profile'),
                onTap: () {
                  Navigator.of(context).pop();
                  context.push(Routes.profile);
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.of(context).pop();
                  ref.read(authProvider.notifier).logout();
                },
              ),
            ] else ...[
              ListTile(
                leading: const Icon(Icons.login_outlined, color: AppColors.royalBlue),
                title: const Text('Login'),
                onTap: () {
                  Navigator.of(context).pop();
                  showLoginModal(context);
                },
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                child: PillButton(
                  label: 'Register',
                  onPressed: () {
                    Navigator.of(context).pop();
                    showRegisterModal(context);
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
