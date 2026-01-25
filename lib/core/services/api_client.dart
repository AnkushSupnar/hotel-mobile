import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:hotel/core/services/api_config_service.dart';
import 'package:hotel/core/services/auth_storage_service.dart';
import 'package:hotel/core/utils/app_logger.dart';

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    required this.statusCode,
  });
}

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  // Get headers with optional auth token
  Map<String, String> _getHeaders({bool includeAuth = true}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth && AuthStorageService.hasToken) {
      headers['Authorization'] = 'Bearer ${AuthStorageService.token}';
    }

    return headers;
  }

  // GET request
  Future<ApiResponse<Map<String, dynamic>>> get(
    String endpoint, {
    bool includeAuth = true,
  }) async {
    AppLogger.apiRequest('GET', endpoint);
    try {
      final url = Uri.parse(ApiConfigService.getEndpoint(endpoint));
      final response = await http
          .get(url, headers: _getHeaders(includeAuth: includeAuth))
          .timeout(Duration(seconds: ApiConfigService.timeout));

      final apiResponse = _handleResponse(response);
      AppLogger.apiResponse(endpoint, apiResponse.statusCode, apiResponse.success, message: apiResponse.message);
      return apiResponse;
    } on SocketException {
      AppLogger.apiError(endpoint, 'No internet connection');
      return ApiResponse(
        success: false,
        message: 'No internet connection',
        statusCode: 0,
      );
    } on HttpException {
      AppLogger.apiError(endpoint, 'Server error');
      return ApiResponse(
        success: false,
        message: 'Server error',
        statusCode: 0,
      );
    } catch (e) {
      AppLogger.apiError(endpoint, e.toString());
      return ApiResponse(
        success: false,
        message: e.toString(),
        statusCode: 0,
      );
    }
  }

  // POST request
  Future<ApiResponse<Map<String, dynamic>>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool includeAuth = true,
  }) async {
    AppLogger.apiRequest('POST', endpoint, body: body);
    try {
      final url = Uri.parse(ApiConfigService.getEndpoint(endpoint));
      final response = await http
          .post(
            url,
            headers: _getHeaders(includeAuth: includeAuth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(Duration(seconds: ApiConfigService.timeout));

      final apiResponse = _handleResponse(response);
      AppLogger.apiResponse(endpoint, apiResponse.statusCode, apiResponse.success, message: apiResponse.message);
      return apiResponse;
    } on SocketException {
      AppLogger.apiError(endpoint, 'No internet connection');
      return ApiResponse(
        success: false,
        message: 'No internet connection',
        statusCode: 0,
      );
    } on HttpException {
      AppLogger.apiError(endpoint, 'Server error');
      return ApiResponse(
        success: false,
        message: 'Server error',
        statusCode: 0,
      );
    } catch (e) {
      AppLogger.apiError(endpoint, e.toString());
      return ApiResponse(
        success: false,
        message: e.toString(),
        statusCode: 0,
      );
    }
  }

  // PUT request
  Future<ApiResponse<Map<String, dynamic>>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool includeAuth = true,
  }) async {
    AppLogger.apiRequest('PUT', endpoint, body: body);
    try {
      final url = Uri.parse(ApiConfigService.getEndpoint(endpoint));
      final response = await http
          .put(
            url,
            headers: _getHeaders(includeAuth: includeAuth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(Duration(seconds: ApiConfigService.timeout));

      final apiResponse = _handleResponse(response);
      AppLogger.apiResponse(endpoint, apiResponse.statusCode, apiResponse.success, message: apiResponse.message);
      return apiResponse;
    } on SocketException {
      AppLogger.apiError(endpoint, 'No internet connection');
      return ApiResponse(
        success: false,
        message: 'No internet connection',
        statusCode: 0,
      );
    } on HttpException {
      AppLogger.apiError(endpoint, 'Server error');
      return ApiResponse(
        success: false,
        message: 'Server error',
        statusCode: 0,
      );
    } catch (e) {
      AppLogger.apiError(endpoint, e.toString());
      return ApiResponse(
        success: false,
        message: e.toString(),
        statusCode: 0,
      );
    }
  }

  // DELETE request
  Future<ApiResponse<Map<String, dynamic>>> delete(
    String endpoint, {
    bool includeAuth = true,
  }) async {
    AppLogger.apiRequest('DELETE', endpoint);
    try {
      final url = Uri.parse(ApiConfigService.getEndpoint(endpoint));
      final response = await http
          .delete(url, headers: _getHeaders(includeAuth: includeAuth))
          .timeout(Duration(seconds: ApiConfigService.timeout));

      final apiResponse = _handleResponse(response);
      AppLogger.apiResponse(endpoint, apiResponse.statusCode, apiResponse.success, message: apiResponse.message);
      return apiResponse;
    } on SocketException {
      AppLogger.apiError(endpoint, 'No internet connection');
      return ApiResponse(
        success: false,
        message: 'No internet connection',
        statusCode: 0,
      );
    } on HttpException {
      AppLogger.apiError(endpoint, 'Server error');
      return ApiResponse(
        success: false,
        message: 'Server error',
        statusCode: 0,
      );
    } catch (e) {
      AppLogger.apiError(endpoint, e.toString());
      return ApiResponse(
        success: false,
        message: e.toString(),
        statusCode: 0,
      );
    }
  }

  // Handle HTTP response
  ApiResponse<Map<String, dynamic>> _handleResponse(http.Response response) {
    Map<String, dynamic>? data;

    try {
      if (response.body.isNotEmpty) {
        data = jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {
      // Body is not JSON
    }

    final isSuccess = response.statusCode >= 200 && response.statusCode < 300;
    String? message;

    if (data != null && data.containsKey('message')) {
      message = data['message'] as String?;
    } else if (!isSuccess) {
      message = _getErrorMessage(response.statusCode);
    }

    return ApiResponse(
      success: isSuccess,
      data: data,
      message: message,
      statusCode: response.statusCode,
    );
  }

  String _getErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Not found';
      case 500:
        return 'Internal server error';
      case 502:
        return 'Bad gateway';
      case 503:
        return 'Service unavailable';
      default:
        return 'Error: $statusCode';
    }
  }
}
