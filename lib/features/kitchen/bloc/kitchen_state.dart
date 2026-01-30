import 'package:equatable/equatable.dart';
import 'package:hotel/features/kitchen/data/models/kitchen_order_model.dart';

enum KitchenStatus { initial, loading, success, failure }

enum KitchenFilter { all, pending, ready }

class KitchenState extends Equatable {
  final KitchenStatus status;
  final List<TableKitchenOrders> tableGroups;
  final KitchenFilter filter;
  final String? errorMessage;
  final int? processingKotId;

  const KitchenState({
    this.status = KitchenStatus.initial,
    this.tableGroups = const [],
    this.filter = KitchenFilter.all,
    this.errorMessage,
    this.processingKotId,
  });

  List<TableKitchenOrders> get filteredGroups {
    if (filter == KitchenFilter.all) return tableGroups;

    final targetStatus =
        filter == KitchenFilter.pending ? KotStatus.sent : KotStatus.ready;

    return tableGroups
        .map((group) {
          final filtered =
              group.orders.where((o) => o.status == targetStatus).toList();
          if (filtered.isEmpty) return null;
          return TableKitchenOrders(
            tableNo: group.tableNo,
            tableName: group.tableName,
            orderCount: filtered.length,
            orders: filtered,
          );
        })
        .whereType<TableKitchenOrders>()
        .toList();
  }

  int get totalPendingCount {
    int count = 0;
    for (final group in tableGroups) {
      count += group.orders.where((o) => o.status == KotStatus.sent).length;
    }
    return count;
  }

  int get totalReadyCount {
    int count = 0;
    for (final group in tableGroups) {
      count += group.orders.where((o) => o.status == KotStatus.ready).length;
    }
    return count;
  }

  KitchenState copyWith({
    KitchenStatus? status,
    List<TableKitchenOrders>? tableGroups,
    KitchenFilter? filter,
    String? errorMessage,
    int? processingKotId,
    bool clearProcessing = false,
  }) {
    return KitchenState(
      status: status ?? this.status,
      tableGroups: tableGroups ?? this.tableGroups,
      filter: filter ?? this.filter,
      errorMessage: errorMessage,
      processingKotId:
          clearProcessing ? null : (processingKotId ?? this.processingKotId),
    );
  }

  @override
  List<Object?> get props => [
        status,
        tableGroups,
        filter,
        errorMessage,
        processingKotId,
      ];
}
