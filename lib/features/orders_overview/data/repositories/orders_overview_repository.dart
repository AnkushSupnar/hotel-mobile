import 'package:hotel/core/services/api_client.dart';
import 'package:hotel/core/utils/app_logger.dart';
import 'package:hotel/features/orders/data/models/transaction_item_model.dart';
import 'package:hotel/features/orders_overview/data/models/table_order_summary.dart';
import 'package:hotel/features/tables/data/models/dining_table_model.dart';

class OrdersOverviewRepository {
  final ApiClient _apiClient;

  OrdersOverviewRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<List<TableOrderSummary>> getActiveTableOrders() async {
    // 1. Fetch all tables
    final tablesResponse =
        await _apiClient.get('billing/tables', includeAuth: true);

    if (!tablesResponse.success || tablesResponse.data == null) {
      throw Exception(
          tablesResponse.message ?? 'Failed to fetch tables');
    }

    final data = tablesResponse.data!;
    List<DiningTableModel> allTables = [];

    if (data.containsKey('data') && data['data'] is List) {
      allTables = (data['data'] as List)
          .map((json) =>
              DiningTableModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    // 2. Filter to non-available tables
    final activeTables =
        allTables.where((t) => !t.isAvailable).toList();

    AppLogger.info(
        'Orders overview: ${activeTables.length} active tables out of ${allTables.length}');

    if (activeTables.isEmpty) {
      return [];
    }

    // 3. Fetch transactions for each active table in parallel
    final futures = activeTables.map((table) async {
      try {
        final response = await _apiClient.get(
          'billing/tables/${table.id}/transactions',
          includeAuth: true,
        );

        List<TransactionItemModel> transactions = [];
        if (response.success && response.data != null) {
          final txData = response.data!;
          if (txData.containsKey('data') && txData['data'] is List) {
            transactions = (txData['data'] as List)
                .map((json) => TransactionItemModel.fromJson(
                    json as Map<String, dynamic>))
                .toList();
          }
        }

        return TableOrderSummary(
            table: table, transactions: transactions);
      } catch (e) {
        AppLogger.error(
            'Failed to fetch transactions for table ${table.id}',
            error: e);
        return TableOrderSummary(
            table: table, transactions: const []);
      }
    }).toList();

    return Future.wait(futures);
  }
}
