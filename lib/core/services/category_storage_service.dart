import 'dart:convert';
import 'package:hotel/core/services/hive_service.dart';
import 'package:hotel/core/utils/app_logger.dart';
import 'package:hotel/features/orders/data/models/category_model.dart';

class CategoryStorageService {
  static const String _categoriesKey = 'cached_categories';
  static const String _lastFetchKey = 'categories_last_fetch';

  // Get all cached categories
  static List<CategoryModel> getCategories() {
    final categoriesJson = StorageService.getString(_categoriesKey);
    if (categoriesJson == null || categoriesJson.isEmpty) {
      AppLogger.cacheMiss(_categoriesKey);
      return [];
    }

    try {
      final List<dynamic> categoriesList = jsonDecode(categoriesJson);
      final categories = categoriesList
          .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
          .toList();
      AppLogger.cacheHit(_categoriesKey, itemCount: categories.length);
      return categories;
    } catch (e) {
      AppLogger.error('Failed to parse cached categories', error: e);
      return [];
    }
  }

  // Save categories to cache
  static Future<bool> saveCategories(List<CategoryModel> categories) async {
    try {
      final categoriesJson = jsonEncode(categories.map((c) => c.toJson()).toList());
      await StorageService.setString(_categoriesKey, categoriesJson);
      await StorageService.setString(_lastFetchKey, DateTime.now().toIso8601String());
      AppLogger.cacheSave(_categoriesKey, itemCount: categories.length);
      return true;
    } catch (e) {
      AppLogger.error('Failed to save categories to cache', error: e);
      return false;
    }
  }

  // Check if categories exist in cache
  static bool hasCategories() {
    final hasData = StorageService.containsKey(_categoriesKey) &&
           (StorageService.getString(_categoriesKey)?.isNotEmpty ?? false);
    if (hasData) {
      AppLogger.debug('Categories cache exists');
    } else {
      AppLogger.debug('Categories cache is empty');
    }
    return hasData;
  }

  // Clear cached categories
  static Future<bool> clearCategories() async {
    await StorageService.remove(_categoriesKey);
    await StorageService.remove(_lastFetchKey);
    AppLogger.cacheClear(_categoriesKey);
    return true;
  }

  // Get last fetch timestamp
  static DateTime? getLastFetchTime() {
    final timestamp = StorageService.getString(_lastFetchKey);
    if (timestamp == null || timestamp.isEmpty) {
      return null;
    }
    try {
      return DateTime.parse(timestamp);
    } catch (e) {
      return null;
    }
  }
}
