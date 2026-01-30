import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel/core/utils/app_logger.dart';
import 'package:hotel/features/kitchen/bloc/kitchen_event.dart';
import 'package:hotel/features/kitchen/bloc/kitchen_state.dart';
import 'package:hotel/features/kitchen/data/models/kitchen_order_model.dart';
import 'package:hotel/features/kitchen/data/repositories/kitchen_repository.dart';

class KitchenBloc extends Bloc<KitchenEvent, KitchenState> {
  final KitchenRepository _repository;
  Timer? _refreshTimer;

  KitchenBloc({KitchenRepository? repository})
      : _repository = repository ?? KitchenRepository(),
        super(const KitchenState()) {
    on<LoadKitchenOrders>(_onLoadKitchenOrders);
    on<RefreshKitchenOrders>(_onRefreshKitchenOrders);
    on<ChangeFilter>(_onChangeFilter);
    on<MarkKotReady>(_onMarkKotReady);
    on<MarkKotServed>(_onMarkKotServed);
  }

  void startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => add(const RefreshKitchenOrders()),
    );
  }

  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  Future<void> _onLoadKitchenOrders(
    LoadKitchenOrders event,
    Emitter<KitchenState> emit,
  ) async {
    emit(state.copyWith(status: KitchenStatus.loading));

    try {
      final tableGroups = await _repository.getAllOrders();
      emit(state.copyWith(
        status: KitchenStatus.success,
        tableGroups: tableGroups,
      ));
    } catch (e) {
      AppLogger.error('Failed to load kitchen orders', error: e);
      emit(state.copyWith(
        status: KitchenStatus.failure,
        errorMessage: 'Failed to load kitchen orders',
      ));
    }
  }

  Future<void> _onRefreshKitchenOrders(
    RefreshKitchenOrders event,
    Emitter<KitchenState> emit,
  ) async {
    try {
      final tableGroups = await _fetchForCurrentFilter();
      emit(state.copyWith(
        status: KitchenStatus.success,
        tableGroups: tableGroups,
      ));
    } catch (e) {
      AppLogger.error('Failed to refresh kitchen orders', error: e);
      // Emit current state to signal refresh completion (keeps old data)
      emit(state.copyWith(status: KitchenStatus.success));
    }
  }

  Future<void> _onChangeFilter(
    ChangeFilter event,
    Emitter<KitchenState> emit,
  ) async {
    emit(state.copyWith(
      filter: event.filter,
      status: KitchenStatus.loading,
    ));

    try {
      final tableGroups = await _fetchForFilter(event.filter);
      emit(state.copyWith(
        status: KitchenStatus.success,
        tableGroups: tableGroups,
      ));
    } catch (e) {
      AppLogger.error('Failed to fetch filtered orders', error: e);
      emit(state.copyWith(
        status: KitchenStatus.failure,
        errorMessage: 'Failed to load orders',
      ));
    }
  }

  Future<void> _onMarkKotReady(
    MarkKotReady event,
    Emitter<KitchenState> emit,
  ) async {
    emit(state.copyWith(processingKotId: event.kotId));

    try {
      await _repository.markKotReady(event.kotId);
      final tableGroups = await _fetchForCurrentFilter();
      emit(state.copyWith(
        status: KitchenStatus.success,
        tableGroups: tableGroups,
        clearProcessing: true,
      ));
    } catch (e) {
      AppLogger.error('Failed to mark KOT as ready', error: e);
      emit(state.copyWith(
        errorMessage: 'Failed to mark order as ready',
        clearProcessing: true,
      ));
    }
  }

  Future<void> _onMarkKotServed(
    MarkKotServed event,
    Emitter<KitchenState> emit,
  ) async {
    emit(state.copyWith(processingKotId: event.kotId));

    try {
      await _repository.markKotServed(event.kotId);
      final tableGroups = await _fetchForCurrentFilter();
      emit(state.copyWith(
        status: KitchenStatus.success,
        tableGroups: tableGroups,
        clearProcessing: true,
      ));
    } catch (e) {
      AppLogger.error('Failed to mark KOT as served', error: e);
      emit(state.copyWith(
        errorMessage: 'Failed to mark order as served',
        clearProcessing: true,
      ));
    }
  }

  Future<List<TableKitchenOrders>> _fetchForCurrentFilter() {
    return _fetchForFilter(state.filter);
  }

  Future<List<TableKitchenOrders>> _fetchForFilter(KitchenFilter filter) {
    switch (filter) {
      case KitchenFilter.all:
        return _repository.getAllOrders();
      case KitchenFilter.pending:
        return _repository.getPendingOrders();
      case KitchenFilter.ready:
        return _repository.getReadyOrders();
    }
  }

  @override
  Future<void> close() {
    stopAutoRefresh();
    return super.close();
  }
}
