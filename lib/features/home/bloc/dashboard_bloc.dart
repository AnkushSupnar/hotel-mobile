import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel/core/utils/app_logger.dart';
import 'package:hotel/features/home/bloc/dashboard_event.dart';
import 'package:hotel/features/home/bloc/dashboard_state.dart';
import 'package:hotel/features/home/data/repositories/dashboard_repository.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository _repository;
  Timer? _refreshTimer;

  DashboardBloc({DashboardRepository? repository})
      : _repository = repository ?? DashboardRepository(),
        super(const DashboardState()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<RefreshDashboard>(_onRefreshDashboard);
  }

  void startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => add(const RefreshDashboard()),
    );
  }

  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  Future<void> _onLoadDashboard(
    LoadDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(status: DashboardStatus.loading));

    try {
      final stats = await _repository.getDashboardStats();
      emit(state.copyWith(
        status: DashboardStatus.success,
        stats: stats,
      ));
    } catch (e) {
      AppLogger.error('Failed to load dashboard', error: e);
      emit(state.copyWith(
        status: DashboardStatus.failure,
        errorMessage: 'Failed to load dashboard data',
      ));
    }
  }

  Future<void> _onRefreshDashboard(
    RefreshDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    // Don't show loading indicator on refresh - keep showing old data
    try {
      final stats = await _repository.getDashboardStats();
      emit(state.copyWith(
        status: DashboardStatus.success,
        stats: stats,
      ));
    } catch (e) {
      AppLogger.error('Failed to refresh dashboard', error: e);
      // Don't emit failure on refresh - keep showing old data
    }
  }

  @override
  Future<void> close() {
    stopAutoRefresh();
    return super.close();
  }
}
