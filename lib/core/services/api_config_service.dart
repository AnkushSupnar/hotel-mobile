import 'package:hotel/core/services/hive_service.dart';

class ApiConfigService {
  // Keys for storing configuration
  static const String _serverUrlKey = 'server_url';
  static const String _apiVersionKey = 'api_version';
  static const String _timeoutKey = 'timeout';

  // Default values
  static const String defaultServerUrl = 'http://localhost:8081';
  static const String defaultApiVersion = 'api';
  static const int defaultTimeout = 30; // seconds

  // Get server URL
  static String get serverUrl {
    return StorageService.getString(_serverUrlKey) ?? defaultServerUrl;
  }

  // Set server URL
  static Future<void> setServerUrl(String url) async {
    await StorageService.setString(_serverUrlKey, url);
  }

  // Get API version/prefix
  static String get apiVersion {
    return StorageService.getString(_apiVersionKey) ?? defaultApiVersion;
  }

  // Set API version/prefix
  static Future<void> setApiVersion(String version) async {
    await StorageService.setString(_apiVersionKey, version);
  }

  // Get timeout in seconds
  static int get timeout {
    return StorageService.getInt(_timeoutKey) ?? defaultTimeout;
  }

  // Set timeout in seconds
  static Future<void> setTimeout(int seconds) async {
    await StorageService.setInt(_timeoutKey, seconds);
  }

  // Get base API URL (combines server URL and API version)
  static String get baseApiUrl {
    final url = serverUrl.endsWith('/') ? serverUrl.substring(0, serverUrl.length - 1) : serverUrl;
    return '$url/$apiVersion';
  }

  // Get full endpoint URL
  static String getEndpoint(String endpoint) {
    final ep = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    return '$baseApiUrl/$ep';
  }

  // Auth endpoints
  static String get loginEndpoint => getEndpoint('auth/login');
  static String get logoutEndpoint => getEndpoint('auth/logout');
  static String get refreshTokenEndpoint => getEndpoint('auth/refresh');

  // Check if server URL is configured
  static bool get isConfigured {
    return StorageService.containsKey(_serverUrlKey);
  }

  // Clear all configuration
  static Future<void> clearConfig() async {
    await StorageService.remove(_serverUrlKey);
    await StorageService.remove(_apiVersionKey);
    await StorageService.remove(_timeoutKey);
  }

  // Save all configuration at once
  static Future<void> saveConfig({
    required String serverUrl,
    String? apiVersion,
    int? timeout,
  }) async {
    await setServerUrl(serverUrl);
    if (apiVersion != null) {
      await setApiVersion(apiVersion);
    }
    if (timeout != null) {
      await setTimeout(timeout);
    }
  }
}
