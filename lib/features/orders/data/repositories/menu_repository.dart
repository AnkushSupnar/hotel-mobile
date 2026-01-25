import 'package:hotel/core/services/api_client.dart';
import 'package:hotel/core/services/category_storage_service.dart';
import 'package:hotel/core/services/menu_item_storage_service.dart';
import 'package:hotel/core/utils/app_logger.dart';
import 'package:hotel/features/orders/data/models/category_model.dart';
import 'package:hotel/features/orders/data/models/menu_item_model.dart';

class MenuRepository {
  final ApiClient _apiClient;

  MenuRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  // Get categories - first check cache, then API if needed
  Future<List<CategoryModel>> getCategories({bool forceRefresh = false}) async {
    // If not forcing refresh, check cache first
    if (!forceRefresh && CategoryStorageService.hasCategories()) {
      AppLogger.info('Loading categories from cache');
      return CategoryStorageService.getCategories();
    }

    // Fetch from API
    AppLogger.info('Fetching categories from API');
    try {
      final response = await _apiClient.get('categories', includeAuth: true);

      if (response.success && response.data != null) {
        final data = response.data!;
        List<CategoryModel> categories = [];

        // Handle response format - API returns data in 'data' key
        if (data.containsKey('data') && data['data'] is List) {
          categories = (data['data'] as List)
              .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }

        AppLogger.info('Fetched ${categories.length} categories from API');

        // Cache the categories
        await CategoryStorageService.saveCategories(categories);
        return categories;
      } else {
        // If API fails, return cached categories if available
        if (CategoryStorageService.hasCategories()) {
          AppLogger.warning('API failed, returning cached categories');
          return CategoryStorageService.getCategories();
        }
        throw Exception(response.message ?? 'Failed to fetch categories');
      }
    } catch (e) {
      AppLogger.error('Error fetching categories', error: e);
      // If error occurs, return cached categories if available
      if (CategoryStorageService.hasCategories()) {
        AppLogger.warning('Error occurred, returning cached categories');
        return CategoryStorageService.getCategories();
      }
      rethrow;
    }
  }

  // Get menu items by category - first check cache, then API if needed
  Future<List<MenuItemModel>> getItemsByCategory(int categoryId, {bool forceRefresh = false}) async {
    // If not forcing refresh and we have cached items, use them
    if (!forceRefresh && MenuItemStorageService.hasMenuItems()) {
      AppLogger.info('Loading items for category $categoryId from cache');
      return MenuItemStorageService.getItemsByCategory(categoryId);
    }

    // Fetch all items from API
    await getAllItems(forceRefresh: forceRefresh);
    return MenuItemStorageService.getItemsByCategory(categoryId);
  }

  // Get all menu items
  Future<List<MenuItemModel>> getAllItems({bool forceRefresh = false}) async {
    // If not forcing refresh, check cache first
    if (!forceRefresh && MenuItemStorageService.hasMenuItems()) {
      AppLogger.info('Loading all menu items from cache');
      return MenuItemStorageService.getMenuItems();
    }

    // Fetch from API
    AppLogger.info('Fetching menu items from API');
    try {
      final response = await _apiClient.get('items', includeAuth: true);

      if (response.success && response.data != null) {
        final data = response.data!;
        List<MenuItemModel> items = [];

        // Handle response format - API returns data in 'data' key
        if (data.containsKey('data') && data['data'] is List) {
          items = (data['data'] as List)
              .map((json) => MenuItemModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }

        AppLogger.info('Fetched ${items.length} menu items from API');

        // Cache the items
        await MenuItemStorageService.saveMenuItems(items);
        return items;
      } else {
        // If API fails, return cached items if available
        if (MenuItemStorageService.hasMenuItems()) {
          AppLogger.warning('API failed, returning cached menu items');
          return MenuItemStorageService.getMenuItems();
        }
        throw Exception(response.message ?? 'Failed to fetch menu items');
      }
    } catch (e) {
      AppLogger.error('Error fetching menu items', error: e);
      // If error occurs, return cached items if available
      if (MenuItemStorageService.hasMenuItems()) {
        AppLogger.warning('Error occurred, returning cached menu items');
        return MenuItemStorageService.getMenuItems();
      }
      rethrow;
    }
  }

  // Search items
  Future<List<MenuItemModel>> searchItems(String query) async {
    // First ensure we have items in cache
    if (!MenuItemStorageService.hasMenuItems()) {
      await getAllItems();
    }
    return MenuItemStorageService.searchItems(query);
  }

  // Refresh categories from API
  Future<List<CategoryModel>> refreshCategories() async {
    await CategoryStorageService.clearCategories();
    return await getCategories(forceRefresh: true);
  }

  // Refresh menu items from API
  Future<List<MenuItemModel>> refreshMenuItems() async {
    await MenuItemStorageService.clearMenuItems();
    return await getAllItems(forceRefresh: true);
  }

  // Get favorite items
  List<MenuItemModel> getFavoriteItems() {
    return MenuItemStorageService.getFavoriteItems();
  }

  // Get favorite item IDs
  List<int> getFavoriteItemIds() {
    return MenuItemStorageService.getFavoriteItemIds();
  }

  // Toggle favorite status
  Future<bool> toggleFavorite(int itemId) async {
    return await MenuItemStorageService.toggleFavorite(itemId);
  }

  // Check if item is favorite
  bool isFavorite(int itemId) {
    return MenuItemStorageService.isFavorite(itemId);
  }
}
