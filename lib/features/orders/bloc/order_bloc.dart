import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel/features/orders/bloc/order_event.dart';
import 'package:hotel/features/orders/bloc/order_state.dart';
import 'package:hotel/features/orders/data/models/menu_item_model.dart';
import 'package:hotel/features/orders/data/repositories/menu_repository.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final MenuRepository _repository;

  OrderBloc({MenuRepository? repository})
      : _repository = repository ?? MenuRepository(),
        super(const OrderState()) {
    on<LoadMenu>(_onLoadMenu);
    on<SelectCategory>(_onSelectCategory);
    on<AddItemToOrder>(_onAddItemToOrder);
    on<RemoveItemFromOrder>(_onRemoveItemFromOrder);
    on<UpdateItemQuantity>(_onUpdateItemQuantity);
    on<ClearOrder>(_onClearOrder);
    on<SubmitOrder>(_onSubmitOrder);
    on<SearchItems>(_onSearchItems);
  }

  Future<void> _onLoadMenu(
    LoadMenu event,
    Emitter<OrderState> emit,
  ) async {
    emit(state.copyWith(status: OrderStatus.loading));

    try {
      final categories = await _repository.getCategories();
      emit(state.copyWith(
        status: OrderStatus.success,
        categories: categories,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: OrderStatus.failure,
        errorMessage: 'Failed to load menu',
      ));
    }
  }

  Future<void> _onSelectCategory(
    SelectCategory event,
    Emitter<OrderState> emit,
  ) async {
    emit(state.copyWith(
      selectedCategoryId: event.categoryId,
      status: OrderStatus.loading,
    ));

    try {
      final items = await _repository.getItemsByCategory(event.categoryId);
      emit(state.copyWith(
        status: OrderStatus.success,
        currentItems: items,
        searchQuery: '',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: OrderStatus.failure,
        errorMessage: 'Failed to load items',
      ));
    }
  }

  void _onAddItemToOrder(
    AddItemToOrder event,
    Emitter<OrderState> emit,
  ) {
    final existingIndex = state.orderItems.indexWhere(
      (o) => o.item.id == event.item.id,
    );

    if (existingIndex >= 0) {
      // Item already exists, increment quantity
      final updatedItems = List<OrderItemModel>.from(state.orderItems);
      updatedItems[existingIndex] = updatedItems[existingIndex].copyWith(
        quantity: updatedItems[existingIndex].quantity + 1,
      );
      emit(state.copyWith(orderItems: updatedItems));
    } else {
      // Add new item
      emit(state.copyWith(
        orderItems: [...state.orderItems, OrderItemModel(item: event.item)],
      ));
    }
  }

  void _onRemoveItemFromOrder(
    RemoveItemFromOrder event,
    Emitter<OrderState> emit,
  ) {
    final updatedItems = state.orderItems
        .where((o) => o.item.id != event.itemId)
        .toList();
    emit(state.copyWith(orderItems: updatedItems));
  }

  void _onUpdateItemQuantity(
    UpdateItemQuantity event,
    Emitter<OrderState> emit,
  ) {
    if (event.quantity <= 0) {
      // Remove item if quantity is 0 or less
      add(RemoveItemFromOrder(event.itemId));
      return;
    }

    final updatedItems = state.orderItems.map((o) {
      if (o.item.id == event.itemId) {
        return o.copyWith(quantity: event.quantity);
      }
      return o;
    }).toList();

    emit(state.copyWith(orderItems: updatedItems));
  }

  void _onClearOrder(
    ClearOrder event,
    Emitter<OrderState> emit,
  ) {
    emit(state.copyWith(orderItems: []));
  }

  Future<void> _onSubmitOrder(
    SubmitOrder event,
    Emitter<OrderState> emit,
  ) async {
    if (state.orderItems.isEmpty) {
      emit(state.copyWith(
        status: OrderStatus.failure,
        errorMessage: 'No items in order',
      ));
      return;
    }

    emit(state.copyWith(status: OrderStatus.submitting));

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    emit(state.copyWith(
      status: OrderStatus.submitted,
      orderItems: [],
    ));
  }

  Future<void> _onSearchItems(
    SearchItems event,
    Emitter<OrderState> emit,
  ) async {
    emit(state.copyWith(
      searchQuery: event.query,
      clearCategory: true,
    ));

    if (event.query.isEmpty) {
      emit(state.copyWith(currentItems: []));
      return;
    }

    try {
      final items = await _repository.searchItems(event.query);
      emit(state.copyWith(currentItems: items));
    } catch (e) {
      emit(state.copyWith(
        status: OrderStatus.failure,
        errorMessage: 'Search failed',
      ));
    }
  }
}
