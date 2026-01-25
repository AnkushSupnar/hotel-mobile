import 'package:equatable/equatable.dart';
import 'package:hotel/features/orders/data/models/menu_item_model.dart';
import 'package:hotel/features/orders/data/models/transaction_item_model.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class LoadMenu extends OrderEvent {
  const LoadMenu();
}

class LoadMenuWithExistingOrders extends OrderEvent {
  final int tableId;

  const LoadMenuWithExistingOrders({required this.tableId});

  @override
  List<Object?> get props => [tableId];
}

class SetExistingTransactions extends OrderEvent {
  final List<TransactionItemModel> transactions;

  const SetExistingTransactions(this.transactions);

  @override
  List<Object?> get props => [transactions];
}

class UpdateExistingTransactionQuantity extends OrderEvent {
  final int transactionId;
  final int quantity;

  const UpdateExistingTransactionQuantity(this.transactionId, this.quantity);

  @override
  List<Object?> get props => [transactionId, quantity];
}

class RemoveExistingTransaction extends OrderEvent {
  final int transactionId;

  const RemoveExistingTransaction(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}

class SubmitUpdatedTransactions extends OrderEvent {
  final int tableId;

  const SubmitUpdatedTransactions({required this.tableId});

  @override
  List<Object?> get props => [tableId];
}

class SelectCategory extends OrderEvent {
  final int categoryId;

  const SelectCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class AddItemToOrder extends OrderEvent {
  final MenuItemModel item;

  const AddItemToOrder(this.item);

  @override
  List<Object?> get props => [item];
}

class RemoveItemFromOrder extends OrderEvent {
  final int itemId;

  const RemoveItemFromOrder(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

class UpdateItemQuantity extends OrderEvent {
  final int itemId;
  final int quantity;

  const UpdateItemQuantity(this.itemId, this.quantity);

  @override
  List<Object?> get props => [itemId, quantity];
}

class ClearOrder extends OrderEvent {
  const ClearOrder();
}

class SubmitOrder extends OrderEvent {
  final int tableId;
  final int? waiterId;

  const SubmitOrder({
    required this.tableId,
    this.waiterId,
  });

  @override
  List<Object?> get props => [tableId, waiterId];
}

class SearchItems extends OrderEvent {
  final String query;

  const SearchItems(this.query);

  @override
  List<Object?> get props => [query];
}

class LoadFavoriteItems extends OrderEvent {
  const LoadFavoriteItems();
}

class ToggleFavoriteItem extends OrderEvent {
  final int itemId;

  const ToggleFavoriteItem(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

class SelectFavoritesCategory extends OrderEvent {
  const SelectFavoritesCategory();
}

class RefreshMenu extends OrderEvent {
  const RefreshMenu();
}
