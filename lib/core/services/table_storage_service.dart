import 'dart:convert';
import 'package:hotel/core/services/hive_service.dart';
import 'package:hotel/core/utils/app_logger.dart';
import 'package:hotel/features/tables/data/models/dining_table_model.dart';

class TableStorageService {
  static const String _tablesKey = 'cached_tables';
  static const String _favoritesKey = 'favorite_tables';
  static const String _lastFetchKey = 'tables_last_fetch';

  // Get all cached tables
  static List<DiningTableModel> getTables() {
    final tablesJson = StorageService.getString(_tablesKey);
    if (tablesJson == null || tablesJson.isEmpty) {
      AppLogger.cacheMiss(_tablesKey);
      return [];
    }

    try {
      final List<dynamic> tablesList = jsonDecode(tablesJson);
      final tables = tablesList
          .map((json) => DiningTableModel.fromJson(json as Map<String, dynamic>))
          .toList();
      AppLogger.cacheHit(_tablesKey, itemCount: tables.length);
      return tables;
    } catch (e) {
      AppLogger.error('Failed to parse cached tables', error: e);
      return [];
    }
  }

  // Save tables to cache
  static Future<bool> saveTables(List<DiningTableModel> tables) async {
    try {
      final tablesJson = jsonEncode(tables.map((t) => t.toJson()).toList());
      await StorageService.setString(_tablesKey, tablesJson);
      await StorageService.setString(_lastFetchKey, DateTime.now().toIso8601String());
      AppLogger.cacheSave(_tablesKey, itemCount: tables.length);
      return true;
    } catch (e) {
      AppLogger.error('Failed to save tables to cache', error: e);
      return false;
    }
  }

  // Check if tables exist in cache
  static bool hasTables() {
    final hasData = StorageService.containsKey(_tablesKey) &&
           (StorageService.getString(_tablesKey)?.isNotEmpty ?? false);
    if (hasData) {
      AppLogger.debug('Tables cache exists');
    } else {
      AppLogger.debug('Tables cache is empty');
    }
    return hasData;
  }

  // Clear cached tables
  static Future<bool> clearTables() async {
    await StorageService.remove(_tablesKey);
    await StorageService.remove(_lastFetchKey);
    AppLogger.cacheClear(_tablesKey);
    return true;
  }

  // Get favorite table IDs
  static List<int> getFavoriteTableIds() {
    final favorites = StorageService.getStringList(_favoritesKey);
    if (favorites == null || favorites.isEmpty) {
      return [];
    }
    return favorites.map((id) => int.tryParse(id) ?? 0).where((id) => id > 0).toList();
  }

  // Save favorite table IDs
  static Future<bool> saveFavoriteTableIds(List<int> tableIds) async {
    try {
      final stringIds = tableIds.map((id) => id.toString()).toList();
      return await StorageService.setStringList(_favoritesKey, stringIds);
    } catch (e) {
      return false;
    }
  }

  // Add table to favorites
  static Future<bool> addFavorite(int tableId) async {
    final favorites = getFavoriteTableIds();
    if (!favorites.contains(tableId)) {
      favorites.add(tableId);
      return await saveFavoriteTableIds(favorites);
    }
    return true;
  }

  // Remove table from favorites
  static Future<bool> removeFavorite(int tableId) async {
    final favorites = getFavoriteTableIds();
    favorites.remove(tableId);
    return await saveFavoriteTableIds(favorites);
  }

  // Check if table is favorite
  static bool isFavorite(int tableId) {
    return getFavoriteTableIds().contains(tableId);
  }

  // Toggle favorite status
  static Future<bool> toggleFavorite(int tableId) async {
    if (isFavorite(tableId)) {
      return await removeFavorite(tableId);
    } else {
      return await addFavorite(tableId);
    }
  }

  // Get favorite tables from cached tables
  static List<DiningTableModel> getFavoriteTables() {
    final tables = getTables();
    final favoriteIds = getFavoriteTableIds();
    return tables.where((table) => favoriteIds.contains(table.id)).toList();
  }
}
