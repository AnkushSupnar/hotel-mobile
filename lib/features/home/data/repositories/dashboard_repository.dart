import 'package:hotel/core/services/api_client.dart';
import 'package:hotel/core/utils/app_logger.dart';
import 'package:hotel/features/home/data/models/dashboard_stats.dart';
import 'package:hotel/features/tables/data/models/dining_table_model.dart';

class DashboardRepository {
  final ApiClient _apiClient;

  DashboardRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<DashboardStats> getDashboardStats() async {
    // Fetch tables and today's bills in parallel
    final results = await Future.wait([
      _fetchTables(),
      _fetchTodaysBills(),
    ]);

    final tablesResult = results[0] as _TablesData;
    final billsResult = results[1] as _BillsData;

    // Fetch kitchen queue items from ongoing tables
    int kitchenQueueItems = 0;
    if (tablesResult.ongoingTableIds.isNotEmpty) {
      kitchenQueueItems =
          await _fetchKitchenQueueCount(tablesResult.ongoingTableIds);
    }

    // Build recent activities from bills data
    final recentActivities = _buildRecentActivities(
      billsResult.recentBills,
      tablesResult.tables,
    );

    return DashboardStats(
      totalTables: tablesResult.totalTables,
      freeTables: tablesResult.freeTables,
      activeOrders: tablesResult.activeOrders,
      kitchenQueueItems: kitchenQueueItems,
      todaysSales: billsResult.totalSales,
      todaysBillCount: billsResult.billCount,
      recentActivities: recentActivities,
    );
  }

  Future<_TablesData> _fetchTables() async {
    try {
      final response =
          await _apiClient.get('billing/tables', includeAuth: true);

      if (response.success && response.data != null) {
        final data = response.data!;
        List<DiningTableModel> tables = [];

        if (data.containsKey('data') && data['data'] is List) {
          tables = (data['data'] as List)
              .map((json) =>
                  DiningTableModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }

        final totalTables = tables.length;
        final freeTables =
            tables.where((t) => t.status.toLowerCase() == 'available').length;
        final ongoingTables =
            tables.where((t) => t.status.toLowerCase() == 'ongoing').toList();
        final closedTables =
            tables.where((t) => t.status.toLowerCase() == 'closed').length;

        return _TablesData(
          tables: tables,
          totalTables: totalTables,
          freeTables: freeTables,
          activeOrders: ongoingTables.length + closedTables,
          ongoingTableIds: ongoingTables.map((t) => t.id).toList(),
        );
      }
    } catch (e) {
      AppLogger.error('Failed to fetch tables for dashboard', error: e);
    }

    return _TablesData(
      tables: [],
      totalTables: 0,
      freeTables: 0,
      activeOrders: 0,
      ongoingTableIds: [],
    );
  }

  Future<_BillsData> _fetchTodaysBills() async {
    try {
      final response =
          await _apiClient.get('billing/bills/today', includeAuth: true);

      if (response.success && response.data != null) {
        final data = response.data!;
        double totalSales = 0.0;
        int billCount = 0;
        List<Map<String, dynamic>> recentBills = [];

        // The response may contain a summary and bills list
        if (data.containsKey('data')) {
          final billData = data['data'];

          if (billData is Map<String, dynamic>) {
            // If data has summary fields
            if (billData.containsKey('totalAmount')) {
              totalSales = (billData['totalAmount'] as num?)?.toDouble() ?? 0.0;
            }
            if (billData.containsKey('totalBills')) {
              billCount = (billData['totalBills'] as num?)?.toInt() ?? 0;
            }
            if (billData.containsKey('bills') && billData['bills'] is List) {
              recentBills = (billData['bills'] as List)
                  .map((b) => b as Map<String, dynamic>)
                  .toList();
            }
          } else if (billData is List) {
            // If data is directly a list of bills
            recentBills =
                billData.map((b) => b as Map<String, dynamic>).toList();
            billCount = recentBills.length;
            for (final bill in recentBills) {
              totalSales +=
                  (bill['totalAmount'] as num?)?.toDouble() ??
                  (bill['amount'] as num?)?.toDouble() ??
                  0.0;
            }
          }
        }

        return _BillsData(
          totalSales: totalSales,
          billCount: billCount,
          recentBills: recentBills,
        );
      }
    } catch (e) {
      AppLogger.error("Failed to fetch today's bills for dashboard", error: e);
    }

    return _BillsData(
      totalSales: 0.0,
      billCount: 0,
      recentBills: [],
    );
  }

  Future<int> _fetchKitchenQueueCount(List<int> ongoingTableIds) async {
    int totalItems = 0;

    try {
      // Fetch transactions for all ongoing tables in parallel
      final futures = ongoingTableIds.map((tableId) =>
          _apiClient.get('billing/tables/$tableId/transactions',
              includeAuth: true));

      final responses = await Future.wait(futures);

      for (final response in responses) {
        if (response.success && response.data != null) {
          final data = response.data!['data'];
          if (data is List) {
            for (final item in data) {
              final qty = (item['quantity'] as num?)?.toInt() ?? 0;
              totalItems += qty;
            }
          }
        }
      }
    } catch (e) {
      AppLogger.error('Failed to fetch kitchen queue count', error: e);
    }

    return totalItems;
  }

  List<RecentActivity> _buildRecentActivities(
    List<Map<String, dynamic>> recentBills,
    List<DiningTableModel> tables,
  ) {
    final activities = <RecentActivity>[];

    // Add activities from recent bills
    for (final bill in recentBills.take(5)) {
      final billNo = bill['billNo'] ?? bill['id'] ?? '';
      final amount = (bill['totalAmount'] as num?)?.toDouble() ??
          (bill['amount'] as num?)?.toDouble() ??
          0.0;
      final status = (bill['status'] as String?) ?? '';
      final tableName = bill['tableName'] as String? ?? 'Table';

      if (status.toLowerCase() == 'paid') {
        activities.add(RecentActivity(
          title: 'Bill Paid',
          subtitle: '$tableName - \$${amount.toStringAsFixed(2)}',
          time: _formatBillTime(bill),
          type: ActivityType.billPaid,
        ));
      } else if (status.toLowerCase() == 'close') {
        activities.add(RecentActivity(
          title: 'Bill Generated',
          subtitle: '$tableName - Bill #$billNo',
          time: _formatBillTime(bill),
          type: ActivityType.billGenerated,
        ));
      } else if (status.toLowerCase() == 'credit') {
        activities.add(RecentActivity(
          title: 'Credit Bill',
          subtitle: '$tableName - \$${amount.toStringAsFixed(2)}',
          time: _formatBillTime(bill),
          type: ActivityType.billPaid,
        ));
      }
    }

    // Add activities from occupied tables
    final occupiedTables = tables
        .where((t) => t.status.toLowerCase() != 'available')
        .take(3);
    for (final table in occupiedTables) {
      activities.add(RecentActivity(
        title: table.status.toLowerCase() == 'ongoing'
            ? 'Active Order'
            : 'Table ${table.status}',
        subtitle: table.tableName,
        time: 'Now',
        type: ActivityType.tableOccupied,
      ));
    }

    // Limit to 6 activities
    if (activities.length > 6) {
      return activities.sublist(0, 6);
    }

    return activities;
  }

  String _formatBillTime(Map<String, dynamic> bill) {
    // Try to parse time from bill data
    final createdAt = bill['createdAt'] ?? bill['billDate'] ?? bill['date'];
    if (createdAt != null) {
      try {
        final dateTime = DateTime.parse(createdAt.toString());
        final now = DateTime.now();
        final diff = now.difference(dateTime);

        if (diff.inMinutes < 1) return 'Just now';
        if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
        if (diff.inHours < 24) return '${diff.inHours}h ago';
        return 'Today';
      } catch (_) {}
    }
    return 'Today';
  }
}

class _TablesData {
  final List<DiningTableModel> tables;
  final int totalTables;
  final int freeTables;
  final int activeOrders;
  final List<int> ongoingTableIds;

  _TablesData({
    required this.tables,
    required this.totalTables,
    required this.freeTables,
    required this.activeOrders,
    required this.ongoingTableIds,
  });
}

class _BillsData {
  final double totalSales;
  final int billCount;
  final List<Map<String, dynamic>> recentBills;

  _BillsData({
    required this.totalSales,
    required this.billCount,
    required this.recentBills,
  });
}
