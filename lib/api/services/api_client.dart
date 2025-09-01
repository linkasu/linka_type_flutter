import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/token_manager.dart';
import '../exceptions.dart';
import 'auth_service.dart';
import 'dart:developer' as developer;

class ApiClient {
  static const String baseUrl = 'https://type-backend.linka.su/api';
  
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  Future<Map<String, String>> _getHeaders() async {
    try {
      final token = await TokenManager.getToken();
      final headers = {
        'Content-Type': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
        developer.log('Добавлен токен авторизации в заголовки');
      } else {
        developer.log('Токен авторизации отсутствует');
      }
      
      return headers;
    } catch (e) {
      developer.log('Ошибка при формировании заголовков: $e');
      return {'Content-Type': 'application/json'};
    }
  }

  Future<http.Response> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
  }) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl$endpoint').replace(queryParameters: queryParams);
      
      developer.log('Отправляю $method запрос на: $uri');
      if (body != null) {
        developer.log('Тело запроса: ${jsonEncode(body)}');
      }
      
      http.Response response;
      
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }
      
      developer.log('Получен ответ: ${response.statusCode} - ${response.body}');
      return response;
    } catch (e) {
      developer.log('Ошибка при выполнении запроса: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {};
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      final errorBody = response.body.isNotEmpty 
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
      
      // Если получили 401, попробуем автоматически перелогиниться
      if (response.statusCode == 401) {
        try {
          await _attemptAutoRelogin();
          // Повторяем запрос с новым токеном
          return await _retryRequest(response.request!);
        } catch (e) {
          // Очищаем токен и выбрасываем ошибку
          await TokenManager.clearAll();
        }
      }
      
      throw ApiException(
        statusCode: response.statusCode,
        message: errorBody['message'] ?? 'HTTP ${response.statusCode}',
        details: errorBody,
      );
    }
  }

  Future<void> _attemptAutoRelogin() async {
    try {
      // Создаем новый экземпляр AuthService для refresh token
      final authService = AuthService();
      await authService.refreshToken();
    } catch (e) {
      // Очищаем все данные при неудачном refresh
      await TokenManager.clearAll();
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _retryRequest(http.BaseRequest originalRequest) async {
    final headers = await _getHeaders();
    final uri = originalRequest.url;
    
    http.Response response;
    switch (originalRequest.method.toUpperCase()) {
      case 'GET':
        response = await http.get(uri, headers: headers);
        break;
      case 'POST':
        response = await http.post(uri, headers: headers, body: originalRequest is http.Request ? originalRequest.body : null);
        break;
      case 'PUT':
        response = await http.put(uri, headers: headers, body: originalRequest is http.Request ? originalRequest.body : null);
        break;
      case 'DELETE':
        response = await http.delete(uri, headers: headers);
        break;
      default:
        throw Exception('Unsupported HTTP method: ${originalRequest.method}');
    }
    
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> get(String endpoint, {Map<String, String>? queryParams}) async {
    final response = await _makeRequest('GET', endpoint, queryParams: queryParams);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(String endpoint, {Map<String, dynamic>? body}) async {
    final response = await _makeRequest('POST', endpoint, body: body);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(String endpoint, {Map<String, dynamic>? body}) async {
    final response = await _makeRequest('PUT', endpoint, body: body);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    final response = await _makeRequest('DELETE', endpoint);
    return _handleResponse(response);
  }
}


