import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel/core/services/menu_item_storage_service.dart';
import 'package:hotel/core/utils/app_logger.dart';
import 'package:hotel/features/menu_items/bloc/menu_items_catalog_event.dart';
import 'package:hotel/features/menu_items/bloc/menu_items_catalog_state.dart';
import 'package:hotel/features/orders/data/repositories/menu_repository.dart';

class MenuItemsCatalogBloc
    extends Bloc<MenuItemsCatalogEvent, MenuItemsCatalogState> {
  final MenuRepository _repository;

  MenuItemsCatalogBloc({MenuRepository? repository})
      : _repository = repository ?? MenuRepository(),
        super(const MenuItemsCatalogState()) {
    on<LoadMenuItemsCatalog>(_onLoad);
    on<RefreshMenuItemsCatalog>(_onRefresh);
    on<SelectCatalogCategory>(_onSelectCategory);
    on<SearchMenuItems>(_onSearch);
    on<ToggleCatalogFavorite>(_onToggleFavorite);
  }

  Future<void> _onLoad(
    LoadMenuItemsCatalog event,
    Emitter<MenuItemsCatalogState> emit,
  ) async {
    emit(state.copyWith(status: MenuItemsCatalogStatus.loading));

    try {
      final categories = await _repository.getCategories();
      final items = await _repository.getAllItems();
      final favoriteIds =
          MenuItemStorageService.getFavoriteItemIds().toSet();

      emit(state.copyWith(
        status: MenuItemsCatalogStatus.success,
        categories: categories,
        allItems: items,
        favoriteIds: favoriteIds,
      ));
    } catch (e) {
      AppLogger.error('Failed to load menu items catalog', error: e);
      emit(state.copyWith(
        status: MenuItemsCatalogStatus.failure,
        errorMessage: 'Failed to load menu items',
      ));
    }
  }

  Future<void> _onRefresh(
    RefreshMenuItemsCatalog event,
    Emitter<MenuItemsCatalogState> emit,
  ) async {
    try {
      final categories =
          await _repository.getCategories(forceRefresh: true);
      final items = await _repository.getAllItems(forceRefresh: true);
      final favoriteIds =
          MenuItemStorageService.getFavoriteItemIds().toSet();

      emit(state.copyWith(
        status: MenuItemsCatalogStatus.success,
        categories: categories,
        allItems: items,
        favoriteIds: favoriteIds,
      ));
    } catch (e) {
      AppLogger.error('Failed to refresh menu items catalog', error: e);
      // Keep old data on failure
      emit(state.copyWith(status: MenuItemsCatalogStatus.success));
    }
  }

  void _onSelectCategory(
    SelectCatalogCategory event,
    Emitter<MenuItemsCatalogState> emit,
  ) {
    if (event.categoryId == null) {
      emit(state.copyWith(clearCategory: true));
    } else {
      emit(state.copyWith(selectedCategoryId: event.categoryId));
    }
  }

  void _onSearch(
    SearchMenuItems event,
    Emitter<MenuItemsCatalogState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
  }

  Future<void> _onToggleFavorite(
    ToggleCatalogFavorite event,
    Emitter<MenuItemsCatalogState> emit,
  ) async {
    final newFavorites = Set<int>.from(state.favoriteIds);
    if (newFavorites.contains(event.itemId)) {
      newFavorites.remove(event.itemId);
    } else {
      newFavorites.add(event.itemId);
    }

    emit(state.copyWith(favoriteIds: newFavorites));

    await MenuItemStorageService.toggleFavorite(event.itemId);
  }
}
