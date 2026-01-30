import 'package:hotel/core/services/api_client.dart';
import 'package:hotel/core/utils/app_logger.dart';
import 'package:hotel/features/kitchen/data/models/kitchen_order_model.dart';

class KitchenRepository {
  final ApiClient _apiClient;

  KitchenRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<List<TableKitchenOrders>> getAllOrders() async {
    return _fetchOrders('billing/kitchen-orders');
  }

  Future<List<TableKitchenOrders>> getPendingOrders() async {
    return _fetchOrders('billing/kitchen-orders/pending');
  }

  Future<List<TableKitchenOrders>> getReadyOrders() async {
    return _fetchOrders('billing/kitchen-orders/ready');
  }

  Future<void> markKotReady(int kotId) async {
    final response = await _apiClient.put(
      'billing/kitchen-orders/$kotId/ready',
    );

    if (!response.success) {
      throw Exception(response.message ?? 'Failed to mark KOT as ready');
    }
  }

  Future<void> markKotServed(int kotId) async {
    final response = await _apiClient.put(
      'billing/kitchen-orders/$kotId/serve',
    );

    if (!response.success) {
      throw Exception(response.message ?? 'Failed to mark KOT as served');
    }
  }

  Future<List<TableKitchenOrders>> _fetchOrders(String endpoint) async {
    final response = await _apiClient.get(endpoint);

    if (response.success && response.data != null) {
      final data = response.data!;
      if (data.containsKey('data') && data['data'] is List) {
        return (data['data'] as List)
            .map((json) =>
                TableKitchenOrders.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } else {
      AppLogger.error('Failed to fetch kitchen orders from $endpoint');
      throw Exception(response.message ?? 'Failed to fetch kitchen orders');
    }
  }
}
