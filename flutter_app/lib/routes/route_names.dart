class Routes {
  // Public marketing site
  static const home = '/';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';

  // Cart & checkout
  static const cart = '/cart';
  static const checkout = '/checkout';
  static const orderConfirmation = '/order-confirmation';

  // Admin portal
  static const adminDashboard = '/admin';
  static const userList = '/admin/users';
  static const addUser = '/admin/users/add';
  static const editUser = '/admin/users/edit';
  static const adminCourses = '/admin/courses';
  static const addCourse = '/admin/courses/add';
  static const editCourse = '/admin/courses/edit';
  static const adminOrders = '/admin/orders';
  static const adminContacts = '/admin/contacts';
  static const adminNotifications = '/admin/notifications';
  static const adminSiteImages = '/admin/site-images';

  // Client portal
  static const profile = '/profile';
  static const myOrders = '/client/orders';
  static const myCourses = '/client/courses';
}
