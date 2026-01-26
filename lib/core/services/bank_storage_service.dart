import 'dart:convert';
import 'package:hotel/core/services/api_client.dart';
import 'package:hotel/core/services/hive_service.dart';
import 'package:hotel/core/utils/app_logger.dart';
import 'package:hotel/features/tables/data/models/bank_model.dart';

class BankStorageService {
  static const String _banksKey = 'cached_banks';
  static const String _lastFetchKey = 'banks_last_fetch';
  static const String _banksEndpoint = 'banks';

  static final ApiClient _apiClient = ApiClient();

  // Get all cached banks
  static List<BankModel> getBanks() {
    final banksJson = StorageService.getString(_banksKey);
    if (banksJson == null || banksJson.isEmpty) {
      AppLogger.cacheMiss(_banksKey);
      return [];
    }

    try {
      final List<dynamic> banksList = jsonDecode(banksJson);
      final banks = banksList
          .map((json) => BankModel.fromJson(json as Map<String, dynamic>))
          .toList();
      AppLogger.cacheHit(_banksKey, itemCount: banks.length);
      return banks;
    } catch (e) {
      AppLogger.error('Failed to parse cached banks', error: e);
      return [];
    }
  }

  // Save banks to cache
  static Future<bool> saveBanks(List<BankModel> banks) async {
    try {
      final banksJson = jsonEncode(banks.map((b) => b.toJson()).toList());
      await StorageService.setString(_banksKey, banksJson);
      await StorageService.setString(_lastFetchKey, DateTime.now().toIso8601String());
      AppLogger.cacheSave(_banksKey, itemCount: banks.length);
      return true;
    } catch (e) {
      AppLogger.error('Failed to save banks to cache', error: e);
      return false;
    }
  }

  // Check if banks exist in cache
  static bool hasBanks() {
    final hasData = StorageService.containsKey(_banksKey) &&
        (StorageService.getString(_banksKey)?.isNotEmpty ?? false);
    if (hasData) {
      AppLogger.debug('Banks cache exists');
    } else {
      AppLogger.debug('Banks cache is empty');
    }
    return hasData;
  }

  // Clear cached banks
  static Future<bool> clearBanks() async {
    await StorageService.remove(_banksKey);
    await StorageService.remove(_lastFetchKey);
    AppLogger.cacheClear(_banksKey);
    return true;
  }

  // Fetch banks from API
  static Future<List<BankModel>> fetchBanksFromApi() async {
    AppLogger.info('Fetching banks from API');
    final response = await _apiClient.get(_banksEndpoint);

    if (response.success && response.data != null) {
      final data = response.data!['data'] as List<dynamic>?;
      if (data != null) {
        final banks = data
            .map((json) => BankModel.fromJson(json as Map<String, dynamic>))
            .toList();
        AppLogger.info('Fetched ${banks.length} banks from API');
        await saveBanks(banks);
        return banks;
      }
    }

    AppLogger.error('Failed to fetch banks from API', error: response.message);
    return [];
  }

  // Get banks - from cache first, then API if not available
  static Future<List<BankModel>> getBanksWithFallback() async {
    // Try cache first
    if (hasBanks()) {
      return getBanks();
    }

    // Fetch from API if cache is empty
    return await fetchBanksFromApi();
  }

  // Force refresh banks from API
  static Future<List<BankModel>> refreshBanks() async {
    await clearBanks();
    return await fetchBanksFromApi();
  }
}
