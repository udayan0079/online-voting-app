import 'dart:convert';
import 'package:http/http.dart' as http;
import '../storage/storage_service.dart';

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    required this.statusCode,
  });
}

class ApiClient {
  static String get baseUrl => StorageService.getBaseUrl();

  static Map<String, String> _buildHeaders() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final token = StorageService.getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // GET
  static Future<ApiResponse<dynamic>> get(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http.get(uri, headers: _buildHeaders()).timeout(
        const Duration(seconds: 15),
      );
      return _parseResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network Error: Unable to connect to server ($e)',
        statusCode: 500,
      );
    }
  }

  // POST
  static Future<ApiResponse<dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .post(uri, headers: _buildHeaders(), body: jsonEncode(body))
          .timeout(const Duration(seconds: 15));
      return _parseResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network Error: Unable to connect to server ($e)',
        statusCode: 500,
      );
    }
  }

  // PUT
  static Future<ApiResponse<dynamic>> put(String endpoint, Map<String, dynamic> body) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .put(uri, headers: _buildHeaders(), body: jsonEncode(body))
          .timeout(const Duration(seconds: 15));
      return _parseResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network Error: Unable to connect to server ($e)',
        statusCode: 500,
      );
    }
  }

  // PATCH
  static Future<ApiResponse<dynamic>> patch(String endpoint, [Map<String, dynamic>? body]) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .patch(uri, headers: _buildHeaders(), body: body != null ? jsonEncode(body) : null)
          .timeout(const Duration(seconds: 15));
      return _parseResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network Error: Unable to connect to server ($e)',
        statusCode: 500,
      );
    }
  }

  // DELETE
  static Future<ApiResponse<dynamic>> delete(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http.delete(uri, headers: _buildHeaders()).timeout(
        const Duration(seconds: 15),
      );
      return _parseResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network Error: Unable to connect to server ($e)',
        statusCode: 500,
      );
    }
  }

  static ApiResponse<dynamic> _parseResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      final isSuccess = response.statusCode >= 200 && response.statusCode < 300;
      final message = data['message'] ?? (isSuccess ? 'Success' : 'Request failed');
      return ApiResponse(
        success: isSuccess,
        message: message,
        data: data,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Invalid server response: ${response.body}',
        statusCode: response.statusCode,
      );
    }
  }
}
