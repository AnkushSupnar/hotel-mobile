import 'package:equatable/equatable.dart';

class TransactionItemModel extends Equatable {
  final int id;
  final String itemName;
  final int quantity;
  final double rate;
  final double amount;
  final int tableNo;
  final int waitorId;
  final int printQty;

  const TransactionItemModel({
    required this.id,
    required this.itemName,
    required this.quantity,
    required this.rate,
    required this.amount,
    required this.tableNo,
    required this.waitorId,
    required this.printQty,
  });

  factory TransactionItemModel.fromJson(Map<String, dynamic> json) {
    return TransactionItemModel(
      id: (json['id'] as num).toInt(),
      itemName: json['itemName'] as String,
      quantity: (json['quantity'] as num).toInt(),
      rate: (json['rate'] as num).toDouble(),
      amount: (json['amount'] as num).toDouble(),
      tableNo: (json['tableNo'] as num).toInt(),
      waitorId: (json['waitorId'] as num).toInt(),
      printQty: (json['printQty'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemName': itemName,
      'quantity': quantity,
      'rate': rate,
      'amount': amount,
      'tableNo': tableNo,
      'waitorId': waitorId,
      'printQty': printQty,
    };
  }

  TransactionItemModel copyWith({
    int? id,
    String? itemName,
    int? quantity,
    double? rate,
    double? amount,
    int? tableNo,
    int? waitorId,
    int? printQty,
  }) {
    final newQuantity = quantity ?? this.quantity;
    final newRate = rate ?? this.rate;
    return TransactionItemModel(
      id: id ?? this.id,
      itemName: itemName ?? this.itemName,
      quantity: newQuantity,
      rate: newRate,
      amount: amount ?? (newQuantity * newRate),
      tableNo: tableNo ?? this.tableNo,
      waitorId: waitorId ?? this.waitorId,
      printQty: printQty ?? this.printQty,
    );
  }

  @override
  List<Object?> get props => [id, itemName, quantity, rate, amount, tableNo, waitorId, printQty];
}
