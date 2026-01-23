class UserModel {
  final String username;
  final String role;
  final String avatarColor;

  const UserModel({
    required this.username,
    required this.role,
    required this.avatarColor,
  });

  String get displayName {
    return username.substring(0, 1).toUpperCase() + username.substring(1);
  }

  String get initials {
    return username.substring(0, 2).toUpperCase();
  }

  static UserModel fromUsername(String username) {
    final roleMap = {
      'admin': 'Administrator',
      'manager': 'Restaurant Manager',
      'captain': 'Floor Captain',
      'cashier': 'Cashier',
      'waiter': 'Waiter',
    };

    final colorMap = {
      'admin': '#E53E3E',
      'manager': '#3182CE',
      'captain': '#D69E2E',
      'cashier': '#805AD5',
      'waiter': '#38A169',
    };

    return UserModel(
      username: username,
      role: roleMap[username] ?? 'Staff',
      avatarColor: colorMap[username] ?? '#667eea',
    );
  }
}
