import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel/core/services/bank_storage_service.dart';
import 'package:hotel/core/services/waiter_storage_service.dart';
import 'package:hotel/core/utils/app_logger.dart';
import 'package:hotel/features/orders/data/repositories/menu_repository.dart';
import 'package:hotel/features/sync/bloc/sync_data_event.dart';
import 'package:hotel/features/sync/bloc/sync_data_state.dart';
import 'package:hotel/features/tables/data/repositories/table_repository.dart';

class SyncDataBloc extends Bloc<SyncDataEvent, SyncDataState> {
  final MenuRepository _menuRepository = MenuRepository();
  final TableRepository _tableRepository = TableRepository();

  SyncDataBloc()
      : super(SyncDataState(items: _buildInitialItems())) {
    on<StartFullSync>(_onStartFullSync);
    on<RetrySync>(_onRetrySync);
  }

  static List<SyncItemState> _buildInitialItems() {
    return const [
      SyncItemState(
        name: 'Categories',
        icon: Icons.category_rounded,
        color: Color(0xFF667eea),
      ),
      SyncItemState(
        name: 'Menu Items',
        icon: Icons.restaurant_menu_rounded,
        color: Color(0xFFD69E2E),
      ),
      SyncItemState(
        name: 'Tables',
        icon: Icons.table_bar_rounded,
        color: Color(0xFF38A169),
      ),
      SyncItemState(
        name: 'Waiters',
        icon: Icons.person_rounded,
        color: Color(0xFF3182CE),
      ),
      SyncItemState(
        name: 'Banks',
        icon: Icons.account_balance_rounded,
        color: Color(0xFF805AD5),
      ),
    ];
  }

  Future<void> _onStartFullSync(
    StartFullSync event,
    Emitter<SyncDataState> emit,
  ) async {
    // Reset all items to pending
    final resetItems = state.items
        .map((item) => item.copyWith(
              status: SyncItemStatus.pending,
              itemCount: 0,
              errorMessage: null,
            ))
        .toList();
    emit(state.copyWith(items: resetItems, isSyncing: true));

    for (int i = 0; i < state.items.length; i++) {
      await _syncItem(i, emit);
    }

    emit(state.copyWith(isSyncing: false));
  }

  Future<void> _onRetrySync(
    RetrySync event,
    Emitter<SyncDataState> emit,
  ) async {
    if (event.index < 0 || event.index >= state.items.length) return;

    emit(state.copyWith(isSyncing: true));
    await _syncItem(event.index, emit);
    emit(state.copyWith(isSyncing: false));
  }

  Future<void> _syncItem(int index, Emitter<SyncDataState> emit) async {
    // Mark as syncing
    final syncingItems = List<SyncItemState>.from(state.items);
    syncingItems[index] = syncingItems[index].copyWith(
      status: SyncItemStatus.syncing,
      errorMessage: null,
    );
    emit(state.copyWith(items: syncingItems));

    try {
      final count = await _performSync(index);
      final completedItems = List<SyncItemState>.from(state.items);
      completedItems[index] = completedItems[index].copyWith(
        status: SyncItemStatus.completed,
        itemCount: count,
      );
      emit(state.copyWith(items: completedItems));
    } catch (e) {
      AppLogger.error('Sync failed for ${state.items[index].name}: $e');
      final failedItems = List<SyncItemState>.from(state.items);
      failedItems[index] = failedItems[index].copyWith(
        status: SyncItemStatus.failed,
        errorMessage: e.toString(),
      );
      emit(state.copyWith(items: failedItems));
    }
  }

  Future<int> _performSync(int index) async {
    switch (index) {
      case 0:
        final categories = await _menuRepository.refreshCategories();
        return categories.length;
      case 1:
        final items = await _menuRepository.refreshMenuItems();
        return items.length;
      case 2:
        final tables = await _tableRepository.refreshTables();
        return tables.length;
      case 3:
        final waiters = await WaiterStorageService.refreshWaiters();
        return waiters.length;
      case 4:
        final banks = await BankStorageService.refreshBanks();
        return banks.length;
      default:
        return 0;
    }
  }
}
