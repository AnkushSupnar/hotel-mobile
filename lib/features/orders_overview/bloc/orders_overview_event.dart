import 'package:equatable/equatable.dart';
import 'package:hotel/features/orders_overview/bloc/orders_overview_state.dart';

abstract class OrdersOverviewEvent extends Equatable {
  const OrdersOverviewEvent();

  @override
  List<Object?> get props => [];
}

class LoadOrdersOverview extends OrdersOverviewEvent {
  const LoadOrdersOverview();
}

class RefreshOrdersOverview extends OrdersOverviewEvent {
  const RefreshOrdersOverview();
}

class ChangeOrdersFilter extends OrdersOverviewEvent {
  final OrdersOverviewFilter filter;

  const ChangeOrdersFilter(this.filter);

  @override
  List<Object?> get props => [filter];
}
