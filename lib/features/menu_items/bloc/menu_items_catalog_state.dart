import 'package:equatable/equatable.dart';
import 'package:hotel/features/orders/data/models/category_model.dart';
import 'package:hotel/features/orders/data/models/menu_item_model.dart';

enum MenuItemsCatalogStatus { initial, loading, success, failure }

class MenuItemsCatalogState extends Equatable {
  final MenuItemsCatalogStatus status;
  final List<CategoryModel> categories;
  final List<MenuItemModel> allItems;
  final int? selectedCategoryId;
  final String searchQuery;
  final Set<int> favoriteIds;
  final String? errorMessage;

  const MenuItemsCatalogState({
    this.status = MenuItemsCatalogStatus.initial,
    this.categories = const [],
    this.allItems = const [],
    this.selectedCategoryId,
    this.searchQuery = '',
    this.favoriteIds = const {},
    this.errorMessage,
  });

  List<MenuItemModel> get filteredItems {
    var items = allItems;

    // Filter by category
    if (selectedCategoryId != null) {
      items =
          items.where((i) => i.categoryId == selectedCategoryId).toList();
    }

    // Filter by search
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      items = items
          .where((i) =>
              i.itemName.toLowerCase().contains(query) ||
              i.itemCode.toLowerCase().contains(query))
          .toList();
    }

    return items;
  }

  int itemCountForCategory(int categoryId) {
    return allItems.where((i) => i.categoryId == categoryId).length;
  }

  int get totalItemCount => allItems.length;

  int get favoriteCount => favoriteIds.length;

  MenuItemsCatalogState copyWith({
    MenuItemsCatalogStatus? status,
    List<CategoryModel>? categories,
    List<MenuItemModel>? allItems,
    int? selectedCategoryId,
    bool clearCategory = false,
    String? searchQuery,
    Set<int>? favoriteIds,
    String? errorMessage,
  }) {
    return MenuItemsCatalogState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      allItems: allItems ?? this.allItems,
      selectedCategoryId: clearCategory
          ? null
          : (selectedCategoryId ?? this.selectedCategoryId),
      searchQuery: searchQuery ?? this.searchQuery,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        categories,
        allItems,
        selectedCategoryId,
        searchQuery,
        favoriteIds,
        errorMessage,
      ];
}
