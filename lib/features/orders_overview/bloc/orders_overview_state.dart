import 'package:equatable/equatable.dart';
import 'package:hotel/features/orders_overview/data/models/table_order_summary.dart';

enum OrdersOverviewStatus { initial, loading, success, failure }

enum OrdersOverviewFilter { all, ongoing, closed }

class OrdersOverviewState extends Equatable {
  final OrdersOverviewStatus status;
  final List<TableOrderSummary> orders;
  final OrdersOverviewFilter filter;
  final String? errorMessage;

  const OrdersOverviewState({
    this.status = OrdersOverviewStatus.initial,
    this.orders = const [],
    this.filter = OrdersOverviewFilter.all,
    this.errorMessage,
  });

  List<TableOrderSummary> get filteredOrders {
    switch (filter) {
      case OrdersOverviewFilter.all:
        return orders;
      case OrdersOverviewFilter.ongoing:
        return orders.where((o) => o.table.isOngoing).toList();
      case OrdersOverviewFilter.closed:
        return orders.where((o) => o.table.isClosed).toList();
    }
  }

  int get ongoingCount =>
      orders.where((o) => o.table.isOngoing).length;

  int get closedCount =>
      orders.where((o) => o.table.isClosed).length;

  OrdersOverviewState copyWith({
    OrdersOverviewStatus? status,
    List<TableOrderSummary>? orders,
    OrdersOverviewFilter? filter,
    String? errorMessage,
  }) {
    return OrdersOverviewState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      filter: filter ?? this.filter,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, orders, filter, errorMessage];
}
