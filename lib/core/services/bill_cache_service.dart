import 'dart:convert';
import 'package:hotel/core/services/hive_service.dart';
import 'package:hotel/core/utils/app_logger.dart';

class BillCacheService {
  static const String _billKeyPrefix = 'cached_bill_';
  static const String _cachedTableIdsKey = 'cached_bill_table_ids';

  static String _billKey(int tableId) => '$_billKeyPrefix$tableId';

  /// Cache the close table response for a given tableId
  static Future<void> cacheBill(
    int tableId, {
    required String pdfBase64,
    required int billNo,
    required double netAmount,
    required String tableName,
  }) async {
    final data = jsonEncode({
      'pdfBase64': pdfBase64,
      'billNo': billNo,
      'netAmount': netAmount,
      'tableName': tableName,
    });
    await StorageService.setString(_billKey(tableId), data);
    // Track this tableId in the list
    await _addTableId(tableId);
    AppLogger.info('Cached bill for table $tableId (billNo: $billNo)');
  }

  /// Get cached bill data for a tableId, or null if not cached
  static Map<String, dynamic>? getCachedBill(int tableId) {
    final json = StorageService.getString(_billKey(tableId));
    if (json == null || json.isEmpty) return null;
    try {
      return jsonDecode(json) as Map<String, dynamic>;
    } catch (e) {
      AppLogger.error('Failed to parse cached bill for table $tableId', error: e);
      return null;
    }
  }

  /// Check if a cached bill exists for this table
  static bool hasCachedBill(int tableId) {
    return StorageService.containsKey(_billKey(tableId)) &&
        (StorageService.getString(_billKey(tableId))?.isNotEmpty ?? false);
  }

  /// Clear cached bill (after payment or status change)
  static Future<void> clearCachedBill(int tableId) async {
    await StorageService.remove(_billKey(tableId));
    await _removeTableId(tableId);
    AppLogger.info('Cleared cached bill for table $tableId');
  }

  /// Get all tableIds that have a cached bill
  static List<int> getCachedTableIds() {
    final ids = StorageService.getStringList(_cachedTableIdsKey);
    if (ids == null) return [];
    return ids.map((s) => int.tryParse(s)).whereType<int>().toList();
  }

  /// Clear cached bills for tables that are no longer closed
  static Future<void> clearStaleBills(Set<int> closedTableIds) async {
    final cachedIds = getCachedTableIds();
    for (final tableId in cachedIds) {
      if (!closedTableIds.contains(tableId)) {
        AppLogger.info('Table $tableId is no longer closed, clearing cached bill');
        await clearCachedBill(tableId);
      }
    }
  }

  static Future<void> _addTableId(int tableId) async {
    final ids = StorageService.getStringList(_cachedTableIdsKey) ?? [];
    final idStr = tableId.toString();
    if (!ids.contains(idStr)) {
      ids.add(idStr);
      await StorageService.setStringList(_cachedTableIdsKey, ids);
    }
  }

  static Future<void> _removeTableId(int tableId) async {
    final ids = StorageService.getStringList(_cachedTableIdsKey) ?? [];
    ids.remove(tableId.toString());
    await StorageService.setStringList(_cachedTableIdsKey, ids);
  }
}
