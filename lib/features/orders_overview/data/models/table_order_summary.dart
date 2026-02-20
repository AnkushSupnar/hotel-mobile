import 'package:equatable/equatable.dart';
import 'package:hotel/features/orders/data/models/transaction_item_model.dart';
import 'package:hotel/features/tables/data/models/dining_table_model.dart';

class TableOrderSummary extends Equatable {
  final DiningTableModel table;
  final List<TransactionItemModel> transactions;

  const TableOrderSummary({
    required this.table,
    required this.transactions,
  });

  double get totalAmount =>
      transactions.fold(0.0, (sum, item) => sum + item.amount);

  int get totalItems =>
      transactions.fold(0, (sum, item) => sum + item.quantity);

  int get uniqueItemCount => transactions.length;

  @override
  List<Object?> get props => [table.id, transactions];
}
