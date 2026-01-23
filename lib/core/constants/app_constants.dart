class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Restaurant POS';
  static const String appTagline = 'Billing & Management System';

  // Hardcoded users for demonstration
  static const List<String> availableUsers = [
    'admin',
    'manager',
    'captain',
    'cashier',
    'waiter',
  ];

  // Hardcoded credentials for demonstration
  static const Map<String, String> userCredentials = {
    'admin': '123',
    'manager': '123',
    'captain': '123',
    'cashier': '123',
    'waiter': '123',
  };
}
