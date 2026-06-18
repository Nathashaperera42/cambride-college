class ApiConstants {
  // Pick the host that matches where you run the app:
  //   Android emulator        -> http://10.0.2.2:5000
  //   iOS simulator / desktop -> http://localhost:5000
  //   Flutter web             -> http://localhost:5000
  //   Real device             -> http://<your-computer-LAN-IP>:5000
  static const String baseUrl = "https://cambridge-backend-b71x.onrender.com/api";

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // Users & Profile
  static const String users = '/users';
  static const String profile = '/profile';

  // Courses
  static const String courses = '/courses';
  static const String coursesAdmin = '/courses/admin/all';

  // Orders
  static const String orders = '/orders';
  static const String myOrders = '/orders/my';
  static const String myCourses = '/orders/my-courses';
  static const String ordersAdmin = '/orders/admin/all';
  static const String dashboardStats = '/orders/admin/stats';

  // Payments
  static const String createStripeSession = '/payments/stripe/create-session';
  static const String paymentsAdmin = '/payments/admin/all';

  // Contact
  static const String contact = '/contact';
  static const String contactAdmin = '/contact';
  static const String contactUnreadCount = '/contact/unread-count';

  // Site images
  static const String siteImages = '/site-images';
  static const String siteImagesAdmin = '/site-images/admin';

  // Voice of Trust
  static const String voiceOfTrust = '/voice-of-trust';
  static const String voiceOfTrustAdmin = '/voice-of-trust/admin/all';

  // Reviews
  static const String reviews = '/reviews';
  static const String reviewsAdmin = '/reviews/admin';

  // Cambridge Qualifications
  static const String qualifications = '/qualifications';
  static const String qualificationsAdmin = '/qualifications/admin/all';

  // Website Assets
  static const String websiteAssets = '/website-assets';
  static const String websiteAssetsAdmin = '/website-assets/admin';
}
