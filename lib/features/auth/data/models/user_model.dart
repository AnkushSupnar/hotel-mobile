class UserModel {
  final int? userId;
  final int? employeeId;
  final String username;
  final String employeeName;
  final String role;
  final String avatarColor;
  final List<String> features;
  final int? tokenExpiresInHours;
  final int? tokenExpiresAt;

  const UserModel({
    this.userId,
    this.employeeId,
    required this.username,
    required this.employeeName,
    required this.role,
    required this.avatarColor,
    this.features = const [],
    this.tokenExpiresInHours,
    this.tokenExpiresAt,
  });

  bool hasFeature(String feature) {
    return features.contains(feature);
  }

  bool get isAdmin => role.toUpperCase() == 'ADMIN';
  bool get isManager => role.toUpperCase() == 'MANAGER';

  String get displayName {
    return employeeName.isNotEmpty ? employeeName : username;
  }

  String get initials {
    final name = displayName;
    if (name.isEmpty) return '';
    if (name.length == 1) return name;
    return name.substring(0, 2);
  }

  static String _getAvatarColor(String role) {
    final colorMap = {
      'ADMIN': '#E53E3E',
      'MANAGER': '#3182CE',
      'CAPTAIN': '#D69E2E',
      'CASHIER': '#805AD5',
      'WAITER': '#38A169',
    };
    return colorMap[role.toUpperCase()] ?? '#667eea';
  }

  factory UserModel.fromLoginResponse(Map<String, dynamic> data) {
    final username = data['username'] as String? ?? '';
    final role = data['role'] as String? ?? 'Staff';
    final employeeName = data['employeeName'] as String? ?? username;

    List<String> features = [];
    if (data['features'] != null) {
      features = List<String>.from(data['features'] as List);
    }

    return UserModel(
      userId: data['userId'] as int?,
      employeeId: data['employeeId'] as int?,
      username: username,
      employeeName: employeeName,
      role: role,
      avatarColor: _getAvatarColor(role),
      features: features,
      tokenExpiresInHours: data['tokenExpiresInHours'] as int?,
      tokenExpiresAt: data['tokenExpiresAt'] as int?,
    );
  }

  // Keep for backward compatibility
  static UserModel fromUsername(String username) {
    return UserModel(
      username: username,
      employeeName: username,
      role: 'Staff',
      avatarColor: _getAvatarColor('Staff'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'employeeId': employeeId,
      'username': username,
      'employeeName': employeeName,
      'role': role,
      'features': features,
      'tokenExpiresInHours': tokenExpiresInHours,
      'tokenExpiresAt': tokenExpiresAt,
    };
  }
}
