import 'package:equatable/equatable.dart';
import 'package:hotel/features/orders/data/models/category_model.dart';
import 'package:hotel/features/orders/data/models/menu_item_model.dart';

enum OrderStatus { initial, loading, success, failure, submitting, submitted }

class OrderState extends Equatable {
  final OrderStatus status;
  final List<CategoryModel> categories;
  final List<MenuItemModel> currentItems;
  final int? selectedCategoryId;
  final List<OrderItemModel> orderItems;
  final String? errorMessage;
  final String searchQuery;

  const OrderState({
    this.status = OrderStatus.initial,
    this.categories = const [],
    this.currentItems = const [],
    this.selectedCategoryId,
    this.orderItems = const [],
    this.errorMessage,
    this.searchQuery = '',
  });

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
    List<OrderItemModel>? orderItems,
    String? errorMessage,
    String? searchQuery,
    bool clearCategory = false,
  }) {
    return OrderState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      currentItems: currentItems ?? this.currentItems,
      selectedCategoryId: clearCategory ? null : (selectedCategoryId ?? this.selectedCategoryId),
      orderItems: orderItems ?? this.orderItems,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
        status,
        categories,
        currentItems,
        selectedCategoryId,
        orderItems,
        errorMessage,
        searchQuery,
      ];
}
