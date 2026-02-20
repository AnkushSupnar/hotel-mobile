import 'package:equatable/equatable.dart';

abstract class MenuItemsCatalogEvent extends Equatable {
  const MenuItemsCatalogEvent();

  @override
  List<Object?> get props => [];
}

class LoadMenuItemsCatalog extends MenuItemsCatalogEvent {
  const LoadMenuItemsCatalog();
}

class RefreshMenuItemsCatalog extends MenuItemsCatalogEvent {
  const RefreshMenuItemsCatalog();
}

class SelectCatalogCategory extends MenuItemsCatalogEvent {
  final int? categoryId;

  const SelectCatalogCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class SearchMenuItems extends MenuItemsCatalogEvent {
  final String query;

  const SearchMenuItems(this.query);

  @override
  List<Object?> get props => [query];
}

class ToggleCatalogFavorite extends MenuItemsCatalogEvent {
  final int itemId;

  const ToggleCatalogFavorite(this.itemId);

  @override
  List<Object?> get props => [itemId];
}
