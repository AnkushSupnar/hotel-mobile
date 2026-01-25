import 'dart:convert';
import 'package:hotel/core/services/hive_service.dart';

class AuthStorageService {
  // Keys for storing auth data
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _employeeIdKey = 'employee_id';
  static const String _usernameKey = 'username';
  static const String _employeeNameKey = 'employee_name';
  static const String _roleKey = 'role';
  static const String _featuresKey = 'features';
  static const String _tokenExpiresAtKey = 'token_expires_at';
  static const String _isLoggedInKey = 'is_logged_in';

  // Token management
  static String? get token {
    return StorageService.getString(_tokenKey);
  }

  static Future<void> setToken(String token) async {
    await StorageService.setString(_tokenKey, token);
  }

  static String? get refreshToken {
    return StorageService.getString(_refreshTokenKey);
  }

  static Future<void> setRefreshToken(String token) async {
    await StorageService.setString(_refreshTokenKey, token);
  }

  // User info
  static String? get userId {
    return StorageService.getString(_userIdKey);
  }

  static Future<void> setUserId(String id) async {
    await StorageService.setString(_userIdKey, id);
  }

  static String? get username {
    return StorageService.getString(_usernameKey);
  }

  static Future<void> setUsername(String username) async {
    await StorageService.setString(_usernameKey, username);
  }

  static String? get role {
    return StorageService.getString(_roleKey);
  }

  static Future<void> setRole(String role) async {
    await StorageService.setString(_roleKey, role);
  }

  // Employee ID
  static int? get employeeId {
    return StorageService.getInt(_employeeIdKey);
  }

  static Future<void> setEmployeeId(int id) async {
    await StorageService.setInt(_employeeIdKey, id);
  }

  // Employee Name
  static String? get employeeName {
    return StorageService.getString(_employeeNameKey);
  }

  static Future<void> setEmployeeName(String name) async {
    await StorageService.setString(_employeeNameKey, name);
  }

  // Features/Permissions
  static List<String> get features {
    final featuresJson = StorageService.getString(_featuresKey);
    if (featuresJson != null) {
      return List<String>.from(jsonDecode(featuresJson) as List);
    }
    return [];
  }

  static Future<void> setFeatures(List<String> features) async {
    await StorageService.setString(_featuresKey, jsonEncode(features));
  }

  static bool hasFeature(String feature) {
    return features.contains(feature);
  }

  // Token Expiration
  static int? get tokenExpiresAt {
    return StorageService.getInt(_tokenExpiresAtKey);
  }

  static Future<void> setTokenExpiresAt(int timestamp) async {
    await StorageService.setInt(_tokenExpiresAtKey, timestamp);
  }

  static bool get isTokenExpired {
    final expiresAt = tokenExpiresAt;
    if (expiresAt == null) return false;
    return DateTime.now().millisecondsSinceEpoch > expiresAt;
  }

  // Login state
  static bool get isLoggedIn {
    return StorageService.getBool(_isLoggedInKey) ?? false;
  }

  static Future<void> setLoggedIn(bool value) async {
    await StorageService.setBool(_isLoggedInKey, value);
  }

  // Save all auth data at once
  static Future<void> saveAuthData({
    required String token,
    String? refreshToken,
    int? userId,
    int? employeeId,
    String? username,
    String? employeeName,
    String? role,
    List<String>? features,
    int? tokenExpiresAt,
  }) async {
    await setToken(token);
    if (refreshToken != null) {
      await setRefreshToken(refreshToken);
    }
    if (userId != null) {
      await setUserId(userId.toString());
    }
    if (employeeId != null) {
      await setEmployeeId(employeeId);
    }
    if (username != null) {
      await setUsername(username);
    }
    if (employeeName != null) {
      await setEmployeeName(employeeName);
    }
    if (role != null) {
      await setRole(role);
    }
    if (features != null) {
      await setFeatures(features);
    }
    if (tokenExpiresAt != null) {
      await setTokenExpiresAt(tokenExpiresAt);
    }
    await setLoggedIn(true);
  }

  // Clear all auth data (logout)
  static Future<void> clearAuthData() async {
    await StorageService.remove(_tokenKey);
    await StorageService.remove(_refreshTokenKey);
    await StorageService.remove(_userIdKey);
    await StorageService.remove(_employeeIdKey);
    await StorageService.remove(_usernameKey);
    await StorageService.remove(_employeeNameKey);
    await StorageService.remove(_roleKey);
    await StorageService.remove(_featuresKey);
    await StorageService.remove(_tokenExpiresAtKey);
    await StorageService.remove(_isLoggedInKey);
  }

  // Check if token exists
  static bool get hasToken {
    final t = token;
    return t != null && t.isNotEmpty;
  }
}
