import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel/core/utils/app_logger.dart';
import 'package:hotel/features/orders_overview/bloc/orders_overview_event.dart';
import 'package:hotel/features/orders_overview/bloc/orders_overview_state.dart';
import 'package:hotel/features/orders_overview/data/repositories/orders_overview_repository.dart';

class OrdersOverviewBloc
    extends Bloc<OrdersOverviewEvent, OrdersOverviewState> {
  final OrdersOverviewRepository _repository;
  Timer? _refreshTimer;

  OrdersOverviewBloc({OrdersOverviewRepository? repository})
      : _repository = repository ?? OrdersOverviewRepository(),
        super(const OrdersOverviewState()) {
    on<LoadOrdersOverview>(_onLoad);
    on<RefreshOrdersOverview>(_onRefresh);
    on<ChangeOrdersFilter>(_onChangeFilter);
  }

  void startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => add(const RefreshOrdersOverview()),
    );
  }

  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  Future<void> _onLoad(
    LoadOrdersOverview event,
    Emitter<OrdersOverviewState> emit,
  ) async {
    emit(state.copyWith(status: OrdersOverviewStatus.loading));

    try {
      final orders = await _repository.getActiveTableOrders();
      emit(state.copyWith(
        status: OrdersOverviewStatus.success,
        orders: orders,
      ));
    } catch (e) {
      AppLogger.error('Failed to load orders overview', error: e);
      emit(state.copyWith(
        status: OrdersOverviewStatus.failure,
        errorMessage: 'Failed to load orders',
      ));
    }
  }

  Future<void> _onRefresh(
    RefreshOrdersOverview event,
    Emitter<OrdersOverviewState> emit,
  ) async {
    try {
      final orders = await _repository.getActiveTableOrders();
      emit(state.copyWith(
        status: OrdersOverviewStatus.success,
        orders: orders,
      ));
    } catch (e) {
      AppLogger.error('Failed to refresh orders overview', error: e);
      // Keep old data on failure
      emit(state.copyWith(status: OrdersOverviewStatus.success));
    }
  }

  void _onChangeFilter(
    ChangeOrdersFilter event,
    Emitter<OrdersOverviewState> emit,
  ) {
    emit(state.copyWith(filter: event.filter));
  }

  @override
  Future<void> close() {
    stopAutoRefresh();
    return super.close();
  }
}
