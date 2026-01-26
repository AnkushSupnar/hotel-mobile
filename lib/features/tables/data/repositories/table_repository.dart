import 'package:hotel/core/services/api_client.dart';
import 'package:hotel/core/services/table_storage_service.dart';
import 'package:hotel/core/utils/app_logger.dart';
import 'package:hotel/features/tables/data/models/dining_table_model.dart';

class TableRepository {
  final ApiClient _apiClient;

  TableRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  // Get tables - first check cache, then API if needed
  Future<List<DiningTableModel>> getTables({bool forceRefresh = false}) async {
    // If not forcing refresh, check cache first
    if (!forceRefresh && TableStorageService.hasTables()) {
      AppLogger.info('Loading tables from cache');
      return TableStorageService.getTables();
    }

    // Fetch from API
    AppLogger.info('Fetching tables from API');
    try {
      final response = await _apiClient.get('billing/tables', includeAuth: true);

      if (response.success && response.data != null) {
        final data = response.data!;
        List<DiningTableModel> tables = [];

        // Handle response format
        if (data.containsKey('data') && data['data'] is List) {
          tables = (data['data'] as List)
              .map((json) => DiningTableModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }

        AppLogger.info('Fetched ${tables.length} tables from API');

        // Cache the tables
        await TableStorageService.saveTables(tables);
        return tables;
      } else {
        // If API fails, return cached tables if available
        if (TableStorageService.hasTables()) {
          AppLogger.warning('API failed, returning cached tables');
          return TableStorageService.getTables();
        }
        throw Exception(response.message ?? 'Failed to fetch tables');
      }
    } catch (e) {
      AppLogger.error('Error fetching tables', error: e);
      // If error occurs, return cached tables if available
      if (TableStorageService.hasTables()) {
        AppLogger.warning('Error occurred, returning cached tables');
        return TableStorageService.getTables();
      }
      rethrow;
    }
  }

  // Get tables grouped by section
  Future<List<TableSection>> getTablesBySection({bool forceRefresh = false}) async {
    final tables = await getTables(forceRefresh: forceRefresh);
    final Map<String, List<DiningTableModel>> sectionMap = {};

    for (final table in tables) {
      if (!sectionMap.containsKey(table.section)) {
        sectionMap[table.section] = [];
      }
      sectionMap[table.section]!.add(table);
    }

    // Sort sections and tables within sections
    final sortedSections = sectionMap.keys.toList()..sort();

    return sortedSections.map((section) {
      final sectionTables = sectionMap[section]!;
      // Sort tables by extracting number from table name
      sectionTables.sort((a, b) {
        final aNum = int.tryParse(a.tableName.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        final bNum = int.tryParse(b.tableName.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        return aNum.compareTo(bNum);
      });
      return TableSection(name: section, tables: sectionTables);
    }).toList();
  }

  // Get favorite tables
  List<DiningTableModel> getFavoriteTables() {
    return TableStorageService.getFavoriteTables();
  }

  // Get favorite table IDs
  List<int> getFavoriteTableIds() {
    return TableStorageService.getFavoriteTableIds();
  }

  // Toggle favorite status
  Future<bool> toggleFavorite(int tableId) async {
    return await TableStorageService.toggleFavorite(tableId);
  }

  // Check if table is favorite
  bool isFavorite(int tableId) {
    return TableStorageService.isFavorite(tableId);
  }

  // Close a table
  Future<Map<String, dynamic>?> closeTable(int tableId) async {
    AppLogger.info('Closing table $tableId');
    try {
      final response = await _apiClient.post(
        'billing/tables/$tableId/close',
        body: {
          'tableId': tableId,
          'customerId': 0,
          'waitorId': 0,
          'userId': 0,
        },
        includeAuth: true,
      );

      if (response.success && response.data != null) {
        AppLogger.info('Table $tableId closed successfully');
        return response.data;
      } else {
        throw Exception(response.message ?? 'Failed to close table');
      }
    } catch (e) {
      AppLogger.error('Error closing table $tableId', error: e);
      rethrow;
    }
  }

  // Clear cache and force refresh
  Future<List<DiningTableModel>> refreshTables() async {
    await TableStorageService.clearTables();
    return await getTables(forceRefresh: true);
  }
}
