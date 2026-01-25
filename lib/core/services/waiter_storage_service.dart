import 'dart:convert';
import 'package:hotel/core/services/api_client.dart';
import 'package:hotel/core/services/hive_service.dart';
import 'package:hotel/core/utils/app_logger.dart';
import 'package:hotel/features/tables/data/models/waiter_model.dart';

class WaiterStorageService {
  static const String _waitersKey = 'cached_waiters';
  static const String _lastFetchKey = 'waiters_last_fetch';
  static const String _waitersEndpoint = '/employees/waiters';

  static final ApiClient _apiClient = ApiClient();

  // Get all cached waiters
  static List<WaiterModel> getWaiters() {
    final waitersJson = StorageService.getString(_waitersKey);
    if (waitersJson == null || waitersJson.isEmpty) {
      AppLogger.cacheMiss(_waitersKey);
      return [];
    }

    try {
      final List<dynamic> waitersList = jsonDecode(waitersJson);
      final waiters = waitersList
          .map((json) => WaiterModel.fromJson(json as Map<String, dynamic>))
          .toList();
      AppLogger.cacheHit(_waitersKey, itemCount: waiters.length);
      return waiters;
    } catch (e) {
      AppLogger.error('Failed to parse cached waiters', error: e);
      return [];
    }
  }

  // Save waiters to cache
  static Future<bool> saveWaiters(List<WaiterModel> waiters) async {
    try {
      final waitersJson = jsonEncode(waiters.map((w) => w.toJson()).toList());
      await StorageService.setString(_waitersKey, waitersJson);
      await StorageService.setString(_lastFetchKey, DateTime.now().toIso8601String());
      AppLogger.cacheSave(_waitersKey, itemCount: waiters.length);
      return true;
    } catch (e) {
      AppLogger.error('Failed to save waiters to cache', error: e);
      return false;
    }
  }

  // Check if waiters exist in cache
  static bool hasWaiters() {
    final hasData = StorageService.containsKey(_waitersKey) &&
        (StorageService.getString(_waitersKey)?.isNotEmpty ?? false);
    if (hasData) {
      AppLogger.debug('Waiters cache exists');
    } else {
      AppLogger.debug('Waiters cache is empty');
    }
    return hasData;
  }

  // Clear cached waiters
  static Future<bool> clearWaiters() async {
    await StorageService.remove(_waitersKey);
    await StorageService.remove(_lastFetchKey);
    AppLogger.cacheClear(_waitersKey);
    return true;
  }

  // Fetch waiters from API
  static Future<List<WaiterModel>> fetchWaitersFromApi() async {
    AppLogger.info('Fetching waiters from API');
    final response = await _apiClient.get(_waitersEndpoint);

    if (response.success && response.data != null) {
      final data = response.data!['data'] as List<dynamic>?;
      if (data != null) {
        final waiters = data
            .map((json) => WaiterModel.fromJson(json as Map<String, dynamic>))
            .toList();
        AppLogger.info('Fetched ${waiters.length} waiters from API');
        await saveWaiters(waiters);
        return waiters;
      }
    }

    AppLogger.error('Failed to fetch waiters from API', error: response.message);
    return [];
  }

  // Get waiters - from cache first, then API if not available
  static Future<List<WaiterModel>> getWaitersWithFallback() async {
    // Try cache first
    if (hasWaiters()) {
      return getWaiters();
    }

    // Fetch from API if cache is empty
    return await fetchWaitersFromApi();
  }

  // Force refresh waiters from API
  static Future<List<WaiterModel>> refreshWaiters() async {
    await clearWaiters();
    return await fetchWaitersFromApi();
  }
}
