import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel/core/services/api_client.dart';
import 'package:hotel/core/services/auth_storage_service.dart';
import 'package:hotel/core/utils/app_logger.dart';
import 'package:hotel/features/orders/bloc/order_event.dart';
import 'package:hotel/features/orders/bloc/order_state.dart';
import 'package:hotel/features/orders/data/models/menu_item_model.dart';
import 'package:hotel/features/orders/data/models/transaction_item_model.dart';
import 'package:hotel/features/orders/data/repositories/menu_repository.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final MenuRepository _repository;

  OrderBloc({MenuRepository? repository})
      : _repository = repository ?? MenuRepository(),
        super(const OrderState()) {
    on<LoadMenu>(_onLoadMenu);
    on<LoadMenuWithExistingOrders>(_onLoadMenuWithExistingOrders);
    on<SetExistingTransactions>(_onSetExistingTransactions);
    on<UpdateExistingTransactionQuantity>(_onUpdateExistingTransactionQuantity);
    on<RemoveExistingTransaction>(_onRemoveExistingTransaction);
    on<SubmitUpdatedTransactions>(_onSubmitUpdatedTransactions);
    on<SelectCategory>(_onSelectCategory);
    on<AddItemToOrder>(_onAddItemToOrder);
    on<RemoveItemFromOrder>(_onRemoveItemFromOrder);
    on<UpdateItemQuantity>(_onUpdateItemQuantity);
    on<ClearOrder>(_onClearOrder);
    on<SubmitOrder>(_onSubmitOrder);
    on<SearchItems>(_onSearchItems);
    on<LoadFavoriteItems>(_onLoadFavoriteItems);
    on<ToggleFavoriteItem>(_onToggleFavoriteItem);
    on<SelectFavoritesCategory>(_onSelectFavoritesCategory);
    on<RefreshMenu>(_onRefreshMenu);
  }

  Future<void> _onLoadMenu(
    LoadMenu event,
    Emitter<OrderState> emit,
  ) async {
    emit(state.copyWith(status: OrderStatus.loading));

    try {
      final categories = await _repository.getCategories();
      // Pre-fetch items to have them in cache
      await _repository.getAllItems();
      final favoriteIds = _repository.getFavoriteItemIds();
      final favoriteItems = _repository.getFavoriteItems();

      // Default to favorites tab selected with favorite items shown
      emit(state.copyWith(
        status: OrderStatus.success,
        categories: categories,
        favoriteItemIds: favoriteIds,
        favoriteItems: favoriteItems,
        isFavoritesSelected: true,
        currentItems: favoriteItems,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: OrderStatus.failure,
        errorMessage: 'Failed to load menu',
      ));
    }
  }

  Future<void> _onLoadMenuWithExistingOrders(
    LoadMenuWithExistingOrders event,
    Emitter<OrderState> emit,
  ) async {
    emit(state.copyWith(status: OrderStatus.loading));

    try {
      // Load menu data
      AppLogger.info('Loading categories for existing order...');
      var categories = await _repository.getCategories();
      AppLogger.info('Loaded ${categories.length} categories');

      // If categories are empty, try force refresh
      if (categories.isEmpty) {
        AppLogger.warning('Categories empty, trying force refresh...');
        categories = await _repository.refreshCategories();
        AppLogger.info('After refresh: ${categories.length} categories');
      }

      AppLogger.info('Loading menu items...');
      final items = await _repository.getAllItems();
      AppLogger.info('Loaded ${items.length} menu items');

      // If items are empty, try force refresh
      if (items.isEmpty) {
        AppLogger.warning('Items empty, trying force refresh...');
        await _repository.refreshMenuItems();
      }

      final favoriteIds = _repository.getFavoriteItemIds();
      final favoriteItems = _repository.getFavoriteItems();
      AppLogger.info('Loaded ${favoriteItems.length} favorite items');

      // Fetch existing transactions for the table
      AppLogger.info('Fetching existing transactions for table ${event.tableId}...');
      final apiClient = ApiClient();
      final response = await apiClient.get('/billing/tables/${event.tableId}/transactions');

      List<TransactionItemModel> existingTransactions = [];
      if (response.success && response.data != null) {
        final data = response.data!['data'] as List<dynamic>?;
        if (data != null) {
          existingTransactions = data
              .map((json) => TransactionItemModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        AppLogger.info('Loaded ${existingTransactions.length} existing transactions');
      }

      AppLogger.info('Emitting success state with ${categories.length} categories, ${favoriteItems.length} favorites, ${existingTransactions.length} transactions');
      emit(state.copyWith(
        status: OrderStatus.success,
        categories: categories,
        favoriteItemIds: favoriteIds,
        favoriteItems: favoriteItems,
        isFavoritesSelected: true,
        currentItems: favoriteItems,
        existingTransactions: existingTransactions,
        originalTransactions: List.from(existingTransactions),
        modifiedTransactionIds: {},
      ));
    } catch (e, stackTrace) {
      AppLogger.error('Failed to load menu with existing orders', error: e);
      AppLogger.error('Stack trace: $stackTrace');
      emit(state.copyWith(
        status: OrderStatus.failure,
        errorMessage: 'Failed to load menu: ${e.toString()}',
      ));
    }
  }

  void _onSetExistingTransactions(
    SetExistingTransactions event,
    Emitter<OrderState> emit,
  ) {
    emit(state.copyWith(existingTransactions: event.transactions));
  }

  void _onUpdateExistingTransactionQuantity(
    UpdateExistingTransactionQuantity event,
    Emitter<OrderState> emit,
  ) {
    // Allow quantity to go to 0 but not below
    final newQuantity = event.quantity < 0 ? 0 : event.quantity;

    final updatedTransactions = state.existingTransactions.map((t) {
      if (t.id == event.transactionId) {
        return t.copyWith(quantity: newQuantity);
      }
      return t;
    }).toList();

    // Track this transaction as modified
    final modifiedIds = Set<int>.from(state.modifiedTransactionIds);
    modifiedIds.add(event.transactionId);

    emit(state.copyWith(
      existingTransactions: updatedTransactions,
      modifiedTransactionIds: modifiedIds,
    ));
  }

  void _onRemoveExistingTransaction(
    RemoveExistingTransaction event,
    Emitter<OrderState> emit,
  ) {
    // Set quantity to 0 instead of removing
    final updatedTransactions = state.existingTransactions.map((t) {
      if (t.id == event.transactionId) {
        return t.copyWith(quantity: 0);
      }
      return t;
    }).toList();

    // Track this transaction as modified
    final modifiedIds = Set<int>.from(state.modifiedTransactionIds);
    modifiedIds.add(event.transactionId);

    emit(state.copyWith(
      existingTransactions: updatedTransactions,
      modifiedTransactionIds: modifiedIds,
    ));
  }

  Future<void> _onSubmitUpdatedTransactions(
    SubmitUpdatedTransactions event,
    Emitter<OrderState> emit,
  ) async {
    if (!state.hasModifiedTransactions && state.modifiedTransactionIds.isEmpty) {
      emit(state.copyWith(
        status: OrderStatus.failure,
        errorMessage: 'No items modified',
      ));
      return;
    }

    emit(state.copyWith(status: OrderStatus.submitting));

    try {
      // Get modified transactions - calculate the quantity difference from original
      final modifiedItems = <Map<String, dynamic>>[];

      for (final modifiedId in state.modifiedTransactionIds) {
        // Find original item
        final originalItem = state.originalTransactions
            .where((t) => t.id == modifiedId)
            .firstOrNull;

        // Find current item (may be deleted)
        final currentItem = state.existingTransactions
            .where((t) => t.id == modifiedId)
            .firstOrNull;

        if (originalItem != null) {
          final originalQty = originalItem.quantity;
          final currentQty = currentItem?.quantity ?? 0;
          final diffQty = currentQty - originalQty;

          // Only include if there's a difference
          if (diffQty != 0) {
            modifiedItems.add({
              'itemName': originalItem.itemName,
              'quantity': diffQty,
              'rate': originalItem.rate,
            });
          }
        }
      }

      if (modifiedItems.isEmpty) {
        emit(state.copyWith(
          status: OrderStatus.failure,
          errorMessage: 'No quantity changes to submit',
        ));
        return;
      }

      AppLogger.info('Submitting ${modifiedItems.length} updated items with quantity differences');

      // Use same format as placing new order
      final userId = int.tryParse(AuthStorageService.userId ?? '0') ?? 0;
      final userName = AuthStorageService.username ?? '';

      // Get waitorId from one of the existing transactions
      final waitorId = state.existingTransactions.isNotEmpty
          ? state.existingTransactions.first.waitorId
          : 0;

      final requestBody = {
        'waitorId': waitorId,
        'userId': userId,
        'userName': userName,
        'items': modifiedItems,
      };

      // Make API call using POST (same as placing order)
      final apiClient = ApiClient();
      final response = await apiClient.post(
        '/billing/tables/${event.tableId}/transactions',
        body: requestBody,
      );

      if (response.success) {
        // Update original transactions to current state and clear modified IDs
        emit(state.copyWith(
          status: OrderStatus.submitted,
          originalTransactions: List.from(state.existingTransactions),
          modifiedTransactionIds: {},
        ));
      } else {
        emit(state.copyWith(
          status: OrderStatus.failure,
          errorMessage: response.message ?? 'Failed to update order',
        ));
      }
    } catch (e) {
      AppLogger.error('Failed to submit updated transactions', error: e);
      emit(state.copyWith(
        status: OrderStatus.failure,
        errorMessage: 'Failed to update order: ${e.toString()}',
      ));
    }
  }

  Future<void> _onSelectCategory(
    SelectCategory event,
    Emitter<OrderState> emit,
  ) async {
    emit(state.copyWith(
      selectedCategoryId: event.categoryId,
      isFavoritesSelected: false,
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

    try {
      // Prepare request body
      final userId = int.tryParse(AuthStorageService.userId ?? '0') ?? 0;
      final userName = AuthStorageService.username ?? '';

      final items = state.orderItems.map((orderItem) => {
        'itemName': orderItem.item.itemName,
        'quantity': orderItem.quantity,
        'rate': orderItem.item.rate,
      }).toList();

      final requestBody = {
        'waitorId': event.waiterId ?? 0,
        'userId': userId,
        'userName': userName,
        'items': items,
      };

      // Make API call
      final apiClient = ApiClient();
      final response = await apiClient.post(
        '/billing/tables/${event.tableId}/transactions',
        body: requestBody,
      );

      if (response.success) {
        emit(state.copyWith(
          status: OrderStatus.submitted,
          orderItems: [],
        ));
      } else {
        emit(state.copyWith(
          status: OrderStatus.failure,
          errorMessage: response.message ?? 'Failed to submit order',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: OrderStatus.failure,
        errorMessage: 'Failed to submit order: ${e.toString()}',
      ));
    }
  }

  Future<void> _onSearchItems(
    SearchItems event,
    Emitter<OrderState> emit,
  ) async {
    emit(state.copyWith(
      searchQuery: event.query,
      clearCategory: true,
      isFavoritesSelected: false,
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

  void _onLoadFavoriteItems(
    LoadFavoriteItems event,
    Emitter<OrderState> emit,
  ) {
    final favoriteIds = _repository.getFavoriteItemIds();
    final favoriteItems = _repository.getFavoriteItems();

    emit(state.copyWith(
      favoriteItemIds: favoriteIds,
      favoriteItems: favoriteItems,
    ));
  }

  Future<void> _onToggleFavoriteItem(
    ToggleFavoriteItem event,
    Emitter<OrderState> emit,
  ) async {
    await _repository.toggleFavorite(event.itemId);
    final favoriteIds = _repository.getFavoriteItemIds();
    final favoriteItems = _repository.getFavoriteItems();

    emit(state.copyWith(
      favoriteItemIds: favoriteIds,
      favoriteItems: favoriteItems,
      // Update currentItems if favorites tab is selected
      currentItems: state.isFavoritesSelected ? favoriteItems : state.currentItems,
    ));
  }

  void _onSelectFavoritesCategory(
    SelectFavoritesCategory event,
    Emitter<OrderState> emit,
  ) {
    final favoriteItems = _repository.getFavoriteItems();

    emit(state.copyWith(
      isFavoritesSelected: true,
      clearCategory: true,
      currentItems: favoriteItems,
      searchQuery: '',
    ));
  }

  Future<void> _onRefreshMenu(
    RefreshMenu event,
    Emitter<OrderState> emit,
  ) async {
    emit(state.copyWith(status: OrderStatus.loading));

    try {
      final categories = await _repository.refreshCategories();
      await _repository.refreshMenuItems();
      final favoriteIds = _repository.getFavoriteItemIds();
      final favoriteItems = _repository.getFavoriteItems();

      emit(state.copyWith(
        status: OrderStatus.success,
        categories: categories,
        favoriteItemIds: favoriteIds,
        favoriteItems: favoriteItems,
        currentItems: [],
        clearCategory: true,
        isFavoritesSelected: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: OrderStatus.failure,
        errorMessage: 'Failed to refresh menu',
      ));
    }
  }
}
