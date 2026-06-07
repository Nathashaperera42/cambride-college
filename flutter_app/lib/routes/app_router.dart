import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/user_model.dart';
import '../models/course_api_model.dart';
import '../providers/auth_provider.dart';
import '../screens/root_shell.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/checkout/checkout_screen.dart';
import '../screens/checkout/order_confirmation_screen.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/user_list_screen.dart';
import '../screens/admin/add_user_screen.dart';
import '../screens/admin/edit_user_screen.dart';
import '../screens/admin/course_list_screen.dart';
import '../screens/admin/add_edit_course_screen.dart';
import '../screens/admin/order_list_screen.dart';
import '../screens/admin/contact_messages_screen.dart';
import '../screens/admin/notifications_screen.dart';
import '../screens/admin/site_images_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/client/my_orders_screen.dart';
import '../screens/client/my_courses_screen.dart';
import 'route_names.dart';

class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(Ref ref) {
    ref.listen(authProvider, (_, __) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh(ref);

  return GoRouter(
    initialLocation: Routes.home,
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final loc = state.matchedLocation;

      final isAuthScreen = loc == Routes.login ||
          loc == Routes.register ||
          loc == Routes.forgotPassword;
      final isPortal = loc.startsWith('/admin') ||
          loc == Routes.profile ||
          loc == Routes.myOrders ||
          loc == Routes.myCourses;

      if (!isPortal && !isAuthScreen) return null;
      if (auth.status == AuthStatus.unknown) return null;

      final authed = auth.status == AuthStatus.authenticated;
      final isAdmin = auth.user?.isAdmin ?? false;

      if (isPortal && !authed) return Routes.home;
      if (loc.startsWith('/admin') && !isAdmin) return Routes.home;
      if (isAuthScreen && authed) {
        return isAdmin ? Routes.adminDashboard : Routes.home;
      }
      return null;
    },
    routes: [
      // Public marketing site
      GoRoute(path: Routes.home, builder: (_, __) => const RootShell()),

      // Auth
      GoRoute(path: Routes.login, builder: (_, __) => const LoginScreen()),
      GoRoute(path: Routes.register, builder: (_, __) => const RegisterScreen()),
      GoRoute(path: Routes.forgotPassword, builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(
        path: Routes.resetPassword,
        builder: (_, state) => ResetPasswordScreen(
          token: state.uri.queryParameters['token'] ?? '',
        ),
      ),

      // Cart & Checkout (public but checkout requires auth check in screen)
      GoRoute(path: Routes.cart, builder: (_, __) => const CartScreen()),
      GoRoute(path: Routes.checkout, builder: (_, __) => const CheckoutScreen()),
      GoRoute(path: Routes.orderConfirmation, builder: (_, __) => const OrderConfirmationScreen()),

      // Admin portal
      GoRoute(path: Routes.adminDashboard, builder: (_, __) => const AdminDashboard()),
      GoRoute(path: Routes.userList, builder: (_, __) => const UserListScreen()),
      GoRoute(path: Routes.addUser, builder: (_, __) => const AddUserScreen()),
      GoRoute(
        path: Routes.editUser,
        builder: (_, state) => EditUserScreen(user: state.extra as UserModel),
      ),
      GoRoute(path: Routes.adminCourses, builder: (_, __) => const CourseListScreen()),
      GoRoute(path: Routes.addCourse, builder: (_, __) => const AddEditCourseScreen()),
      GoRoute(
        path: Routes.editCourse,
        builder: (_, state) => AddEditCourseScreen(course: state.extra as CourseApiModel),
      ),
      GoRoute(path: Routes.adminOrders, builder: (_, __) => const OrderListScreen()),
      GoRoute(path: Routes.adminContacts, builder: (_, __) => const ContactMessagesScreen()),
      GoRoute(path: Routes.adminNotifications, builder: (_, __) => const NotificationsScreen()),
      GoRoute(path: Routes.adminSiteImages, builder: (_, __) => const SiteImagesScreen()),

      // Client portal
      GoRoute(path: Routes.profile, builder: (_, __) => const ProfileScreen()),
      GoRoute(path: Routes.myOrders, builder: (_, __) => const MyOrdersScreen()),
      GoRoute(path: Routes.myCourses, builder: (_, __) => const MyCoursesScreen()),
    ],
  );
});
