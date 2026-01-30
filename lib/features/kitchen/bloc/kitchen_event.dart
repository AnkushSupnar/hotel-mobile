import 'package:equatable/equatable.dart';
import 'package:hotel/features/kitchen/bloc/kitchen_state.dart';

abstract class KitchenEvent extends Equatable {
  const KitchenEvent();

  @override
  List<Object?> get props => [];
}

class LoadKitchenOrders extends KitchenEvent {
  const LoadKitchenOrders();
}

class RefreshKitchenOrders extends KitchenEvent {
  const RefreshKitchenOrders();
}

class ChangeFilter extends KitchenEvent {
  final KitchenFilter filter;

  const ChangeFilter(this.filter);

  @override
  List<Object?> get props => [filter];
}

class MarkKotReady extends KitchenEvent {
  final int kotId;

  const MarkKotReady(this.kotId);

  @override
  List<Object?> get props => [kotId];
}

class MarkKotServed extends KitchenEvent {
  final int kotId;

  const MarkKotServed(this.kotId);

  @override
  List<Object?> get props => [kotId];
}
