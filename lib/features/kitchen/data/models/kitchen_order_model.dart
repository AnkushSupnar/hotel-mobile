import 'package:equatable/equatable.dart';

enum KotStatus { sent, ready, serve, unknown }

KotStatus kotStatusFromString(String status) {
  switch (status.toUpperCase()) {
    case 'SENT':
      return KotStatus.sent;
    case 'READY':
      return KotStatus.ready;
    case 'SERVE':
    case 'SERVED':
      return KotStatus.serve;
    default:
      return KotStatus.unknown;
  }
}

String kotStatusToString(KotStatus status) {
  switch (status) {
    case KotStatus.sent:
      return 'SENT';
    case KotStatus.ready:
      return 'READY';
    case KotStatus.serve:
      return 'SERVE';
    case KotStatus.unknown:
      return 'UNKNOWN';
  }
}

class KotItemModel extends Equatable {
  final int id;
  final String itemName;
  final int quantity;
  final double rate;
  final double amount;

  const KotItemModel({
    required this.id,
    required this.itemName,
    required this.quantity,
    required this.rate,
    required this.amount,
  });

  factory KotItemModel.fromJson(Map<String, dynamic> json) {
    final qty = (json['qty'] as num?)?.toInt() ?? 0;
    final rate = (json['rate'] as num?)?.toDouble() ?? 0.0;
    return KotItemModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      itemName: json['itemName'] as String? ?? '',
      quantity: qty,
      rate: rate,
      amount: (json['amount'] as num?)?.toDouble() ?? qty * rate,
    );
  }

  @override
  List<Object?> get props => [id, itemName, quantity, rate, amount];
}

class KitchenOrderModel extends Equatable {
  final int id;
  final KotStatus status;
  final List<KotItemModel> items;
  final String? createdAt;

  const KitchenOrderModel({
    required this.id,
    required this.status,
    required this.items,
    this.createdAt,
  });

  factory KitchenOrderModel.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List<dynamic>? ?? [];
    return KitchenOrderModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      status: kotStatusFromString(json['status'] as String? ?? ''),
      items: itemsList
          .map((item) => KotItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, status, items, createdAt];
}

class TableKitchenOrders extends Equatable {
  final int tableNo;
  final String tableName;
  final int orderCount;
  final List<KitchenOrderModel> orders;

  const TableKitchenOrders({
    required this.tableNo,
    required this.tableName,
    required this.orderCount,
    required this.orders,
  });

  factory TableKitchenOrders.fromJson(Map<String, dynamic> json) {
    final ordersList = json['orders'] as List<dynamic>? ?? [];
    return TableKitchenOrders(
      tableNo: (json['tableNo'] as num?)?.toInt() ?? 0,
      tableName: json['tableName'] as String? ?? '',
      orderCount: (json['orderCount'] as num?)?.toInt() ?? 0,
      orders: ordersList
          .map((order) =>
              KitchenOrderModel.fromJson(order as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [tableNo, tableName, orderCount, orders];
}
