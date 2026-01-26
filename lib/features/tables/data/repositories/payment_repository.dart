import 'package:hotel/core/services/api_client.dart';
import 'package:hotel/core/utils/app_logger.dart';

class PaymentRepository {
  final ApiClient _apiClient;

  PaymentRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<Map<String, dynamic>?> submitPayment(
    int billNo, {
    required double cashReceived,
    required double returnAmount,
    required double discount,
    required String paymode,
    required int bankId,
  }) async {
    AppLogger.info('Submitting payment for bill $billNo');
    try {
      final response = await _apiClient.post(
        'billing/bills/$billNo/pay',
        body: {
          'cashReceived': cashReceived,
          'returnAmount': returnAmount,
          'discount': discount,
          'paymode': paymode,
          'bankId': bankId,
        },
        includeAuth: true,
      );

      if (response.success && response.data != null) {
        AppLogger.info('Payment for bill $billNo submitted successfully');
        return response.data;
      } else {
        throw Exception(response.message ?? 'Failed to submit payment');
      }
    } catch (e) {
      AppLogger.error('Error submitting payment for bill $billNo', error: e);
      rethrow;
    }
  }
}
