import 'dart:developer' as developer;

class AppLogger {
  static const String _tag = 'HotelApp';

  // Log levels
  static const String _levelInfo = 'INFO';
  static const String _levelDebug = 'DEBUG';
  static const String _levelWarning = 'WARNING';
  static const String _levelError = 'ERROR';
  static const String _levelApi = 'API';
  static const String _levelCache = 'CACHE';

  static void _log(String level, String message, {String? tag, Object? error}) {
    final timestamp = DateTime.now().toIso8601String();
    final logTag = tag ?? _tag;
    final logMessage = '[$timestamp] [$level] [$logTag] $message';

    developer.log(
      logMessage,
      name: logTag,
      error: error,
    );

    // Also print to console for easier debugging
    print(logMessage);
    if (error != null) {
      print('Error details: $error');
    }
  }

  // General logging methods
  static void info(String message, {String? tag}) {
    _log(_levelInfo, message, tag: tag);
  }

  static void debug(String message, {String? tag}) {
    _log(_levelDebug, message, tag: tag);
  }

  static void warning(String message, {String? tag}) {
    _log(_levelWarning, message, tag: tag);
  }

  static void error(String message, {String? tag, Object? error}) {
    _log(_levelError, message, tag: tag, error: error);
  }

  // API specific logging
  static void apiRequest(String method, String endpoint, {Map<String, dynamic>? body}) {
    final bodyInfo = body != null ? ' | Body: ${body.keys.join(', ')}' : '';
    _log(_levelApi, '>>> $method $endpoint$bodyInfo', tag: 'API');
  }

  static void apiResponse(String endpoint, int statusCode, bool success, {String? message}) {
    final statusEmoji = success ? '✓' : '✗';
    final msgInfo = message != null ? ' | $message' : '';
    _log(_levelApi, '<<< $statusEmoji [$statusCode] $endpoint$msgInfo', tag: 'API');
  }

  static void apiError(String endpoint, String error) {
    _log(_levelError, '<<< ERROR $endpoint | $error', tag: 'API');
  }

  // Cache/Storage specific logging
  static void cacheHit(String key, {int? itemCount}) {
    final countInfo = itemCount != null ? ' ($itemCount items)' : '';
    _log(_levelCache, '✓ CACHE HIT: $key$countInfo', tag: 'CACHE');
  }

  static void cacheMiss(String key) {
    _log(_levelCache, '✗ CACHE MISS: $key', tag: 'CACHE');
  }

  static void cacheSave(String key, {int? itemCount}) {
    final countInfo = itemCount != null ? ' ($itemCount items)' : '';
    _log(_levelCache, '→ CACHE SAVE: $key$countInfo', tag: 'CACHE');
  }

  static void cacheLoad(String key, {int? itemCount}) {
    final countInfo = itemCount != null ? ' ($itemCount items)' : '';
    _log(_levelCache, '← CACHE LOAD: $key$countInfo', tag: 'CACHE');
  }

  static void cacheClear(String key) {
    _log(_levelCache, '✗ CACHE CLEAR: $key', tag: 'CACHE');
  }
}
