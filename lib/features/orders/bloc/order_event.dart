import 'package:equatable/equatable.dart';
import 'package:hotel/features/orders/data/models/menu_item_model.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class LoadMenu extends OrderEvent {
  const LoadMenu();
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
  const SubmitOrder();
}

class SearchItems extends OrderEvent {
  final String query;

  const SearchItems(this.query);

  @override
  List<Object?> get props => [query];
}
