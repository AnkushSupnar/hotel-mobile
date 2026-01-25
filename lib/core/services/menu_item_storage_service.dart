import 'dart:convert';
import 'package:hotel/core/services/hive_service.dart';
import 'package:hotel/core/utils/app_logger.dart';
import 'package:hotel/features/orders/data/models/menu_item_model.dart';

class MenuItemStorageService {
  static const String _menuItemsKey = 'cached_menu_items';
  static const String _lastFetchKey = 'menu_items_last_fetch';
  static const String _favoritesKey = 'favorite_menu_items';

  // Get all cached menu items
  static List<MenuItemModel> getMenuItems() {
    final itemsJson = StorageService.getString(_menuItemsKey);
    if (itemsJson == null || itemsJson.isEmpty) {
      AppLogger.cacheMiss(_menuItemsKey);
      return [];
    }

    try {
      final List<dynamic> itemsList = jsonDecode(itemsJson);
      final items = itemsList
          .map((json) => MenuItemModel.fromJson(json as Map<String, dynamic>))
          .toList();
      AppLogger.cacheHit(_menuItemsKey, itemCount: items.length);
      return items;
    } catch (e) {
      AppLogger.error('Failed to parse cached menu items', error: e);
      return [];
    }
  }

  // Get menu items by category
  static List<MenuItemModel> getItemsByCategory(int categoryId) {
    final items = getMenuItems();
    final filteredItems = items.where((item) => item.categoryId == categoryId).toList();
    AppLogger.debug('Filtered ${filteredItems.length} items for category $categoryId');
    return filteredItems;
  }

  // Save menu items to cache
  static Future<bool> saveMenuItems(List<MenuItemModel> items) async {
    try {
      final itemsJson = jsonEncode(items.map((i) => i.toJson()).toList());
      await StorageService.setString(_menuItemsKey, itemsJson);
      await StorageService.setString(_lastFetchKey, DateTime.now().toIso8601String());
      AppLogger.cacheSave(_menuItemsKey, itemCount: items.length);
      return true;
    } catch (e) {
      AppLogger.error('Failed to save menu items to cache', error: e);
      return false;
    }
  }

  // Check if menu items exist in cache
  static bool hasMenuItems() {
    final hasData = StorageService.containsKey(_menuItemsKey) &&
           (StorageService.getString(_menuItemsKey)?.isNotEmpty ?? false);
    if (hasData) {
      AppLogger.debug('Menu items cache exists');
    } else {
      AppLogger.debug('Menu items cache is empty');
    }
    return hasData;
  }

  // Clear cached menu items
  static Future<bool> clearMenuItems() async {
    await StorageService.remove(_menuItemsKey);
    await StorageService.remove(_lastFetchKey);
    AppLogger.cacheClear(_menuItemsKey);
    return true;
  }

  // Search items by name
  static List<MenuItemModel> searchItems(String query) {
    final items = getMenuItems();
    final lowerQuery = query.toLowerCase();
    final results = items.where((item) =>
      item.itemName.toLowerCase().contains(lowerQuery)
    ).toList();
    AppLogger.debug('Search "$query" found ${results.length} items');
    return results;
  }

  // Get favorite item IDs
  static List<int> getFavoriteItemIds() {
    final favorites = StorageService.getStringList(_favoritesKey);
    if (favorites == null || favorites.isEmpty) {
      AppLogger.debug('No favorite items found');
      return [];
    }
    final ids = favorites.map((id) => int.tryParse(id) ?? 0).where((id) => id > 0).toList();
    AppLogger.cacheLoad(_favoritesKey, itemCount: ids.length);
    return ids;
  }

  // Save favorite item IDs
  static Future<bool> saveFavoriteItemIds(List<int> itemIds) async {
    try {
      final stringIds = itemIds.map((id) => id.toString()).toList();
      final result = await StorageService.setStringList(_favoritesKey, stringIds);
      AppLogger.cacheSave(_favoritesKey, itemCount: itemIds.length);
      return result;
    } catch (e) {
      AppLogger.error('Failed to save favorite items', error: e);
      return false;
    }
  }

  // Add item to favorites
  static Future<bool> addFavorite(int itemId) async {
    final favorites = getFavoriteItemIds();
    if (!favorites.contains(itemId)) {
      favorites.add(itemId);
      AppLogger.info('Added item $itemId to favorites');
      return await saveFavoriteItemIds(favorites);
    }
    return true;
  }

  // Remove item from favorites
  static Future<bool> removeFavorite(int itemId) async {
    final favorites = getFavoriteItemIds();
    favorites.remove(itemId);
    AppLogger.info('Removed item $itemId from favorites');
    return await saveFavoriteItemIds(favorites);
  }

  // Check if item is favorite
  static bool isFavorite(int itemId) {
    return getFavoriteItemIds().contains(itemId);
  }

  // Toggle favorite status
  static Future<bool> toggleFavorite(int itemId) async {
    if (isFavorite(itemId)) {
      return await removeFavorite(itemId);
    } else {
      return await addFavorite(itemId);
    }
  }

  // Get favorite items from cached items
  static List<MenuItemModel> getFavoriteItems() {
    final items = getMenuItems();
    final favoriteIds = getFavoriteItemIds();
    final favoriteItems = items.where((item) => favoriteIds.contains(item.id)).toList();
    AppLogger.info('Found ${favoriteItems.length} favorite items');
    return favoriteItems;
  }
}
