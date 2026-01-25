import 'package:equatable/equatable.dart';
import 'package:hotel/features/orders/data/models/category_model.dart';
import 'package:hotel/features/orders/data/models/menu_item_model.dart';
import 'package:hotel/features/orders/data/models/transaction_item_model.dart';

enum OrderStatus { initial, loading, success, failure, submitting, submitted }

class OrderState extends Equatable {
  static const String favoritesCategory = 'Favorites';

  final OrderStatus status;
  final List<CategoryModel> categories;
  final List<MenuItemModel> currentItems;
  final int? selectedCategoryId;
  final bool isFavoritesSelected;
  final List<OrderItemModel> orderItems;
  final String? errorMessage;
  final String searchQuery;
  final List<int> favoriteItemIds;
  final List<MenuItemModel> favoriteItems;
  final List<TransactionItemModel> existingTransactions;
  final List<TransactionItemModel> originalTransactions;
  final Set<int> modifiedTransactionIds;

  const OrderState({
    this.status = OrderStatus.initial,
    this.categories = const [],
    this.currentItems = const [],
    this.selectedCategoryId,
    this.isFavoritesSelected = false,
    this.orderItems = const [],
    this.errorMessage,
    this.searchQuery = '',
    this.favoriteItemIds = const [],
    this.favoriteItems = const [],
    this.existingTransactions = const [],
    this.originalTransactions = const [],
    this.modifiedTransactionIds = const {},
  });

  bool get hasExistingOrders => existingTransactions.isNotEmpty;

  bool get hasModifiedTransactions => modifiedTransactionIds.isNotEmpty;

  List<TransactionItemModel> get modifiedTransactions {
    return existingTransactions
        .where((t) => modifiedTransactionIds.contains(t.id))
        .toList();
  }

  double get existingOrdersTotal {
    return existingTransactions.fold(0, (sum, item) => sum + item.amount);
  }

  int get existingOrdersItemCount {
    return existingTransactions.fold(0, (sum, item) => sum + item.quantity);
  }

  bool isItemFavorite(int itemId) => favoriteItemIds.contains(itemId);

  double get totalAmount {
    return orderItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  int get totalItems {
    return orderItems.fold(0, (sum, item) => sum + item.quantity);
  }

  bool isItemInOrder(int itemId) {
    return orderItems.any((o) => o.item.id == itemId);
  }

  int getItemQuantity(int itemId) {
    final orderItem = orderItems.where((o) => o.item.id == itemId).firstOrNull;
    return orderItem?.quantity ?? 0;
  }

  OrderState copyWith({
    OrderStatus? status,
    List<CategoryModel>? categories,
    List<MenuItemModel>? currentItems,
    int? selectedCategoryId,
    bool? isFavoritesSelected,
    List<OrderItemModel>? orderItems,
    String? errorMessage,
    String? searchQuery,
    List<int>? favoriteItemIds,
    List<MenuItemModel>? favoriteItems,
    List<TransactionItemModel>? existingTransactions,
    List<TransactionItemModel>? originalTransactions,
    Set<int>? modifiedTransactionIds,
    bool clearCategory = false,
  }) {
    return OrderState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      currentItems: currentItems ?? this.currentItems,
      selectedCategoryId: clearCategory ? null : (selectedCategoryId ?? this.selectedCategoryId),
      isFavoritesSelected: isFavoritesSelected ?? this.isFavoritesSelected,
      orderItems: orderItems ?? this.orderItems,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      favoriteItemIds: favoriteItemIds ?? this.favoriteItemIds,
      favoriteItems: favoriteItems ?? this.favoriteItems,
      existingTransactions: existingTransactions ?? this.existingTransactions,
      originalTransactions: originalTransactions ?? this.originalTransactions,
      modifiedTransactionIds: modifiedTransactionIds ?? this.modifiedTransactionIds,
    );
  }

  @override
  List<Object?> get props => [
        status,
        categories,
        currentItems,
        selectedCategoryId,
        isFavoritesSelected,
        orderItems,
        errorMessage,
        searchQuery,
        favoriteItemIds,
        favoriteItems,
        existingTransactions,
        originalTransactions,
        modifiedTransactionIds,
      ];
}
