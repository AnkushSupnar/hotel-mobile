class UserModel {
  final int? userId;
  final int? employeeId;
  final String username;
  final String employeeName;
  final String role;
  final String avatarColor;
  final List<String> features;
  final List<String> enabledScreens;
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
    this.enabledScreens = const [],
    this.tokenExpiresInHours,
    this.tokenExpiresAt,
  });

  bool hasFeature(String feature) {
    return features.contains(feature);
  }

  bool hasScreenAccess(String screenKey) {
    return enabledScreens.contains(screenKey);
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

    List<String> enabledScreens = [];
    if (data['enabledScreens'] != null) {
      enabledScreens = List<String>.from(data['enabledScreens'] as List);
    }

    return UserModel(
      userId: data['userId'] as int?,
      employeeId: data['employeeId'] as int?,
      username: username,
      employeeName: employeeName,
      role: role,
      avatarColor: _getAvatarColor(role),
      features: features,
      enabledScreens: enabledScreens,
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

  UserModel copyWith({
    int? userId,
    int? employeeId,
    String? username,
    String? employeeName,
    String? role,
    String? avatarColor,
    List<String>? features,
    List<String>? enabledScreens,
    int? tokenExpiresInHours,
    int? tokenExpiresAt,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      employeeId: employeeId ?? this.employeeId,
      username: username ?? this.username,
      employeeName: employeeName ?? this.employeeName,
      role: role ?? this.role,
      avatarColor: avatarColor ?? this.avatarColor,
      features: features ?? this.features,
      enabledScreens: enabledScreens ?? this.enabledScreens,
      tokenExpiresInHours: tokenExpiresInHours ?? this.tokenExpiresInHours,
      tokenExpiresAt: tokenExpiresAt ?? this.tokenExpiresAt,
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
      'enabledScreens': enabledScreens,
      'tokenExpiresInHours': tokenExpiresInHours,
      'tokenExpiresAt': tokenExpiresAt,
    };
  }
}
