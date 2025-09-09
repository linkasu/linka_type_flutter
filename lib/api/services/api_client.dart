import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/token_manager.dart';
import '../exceptions.dart';
import '../models/auth_models.dart';
import 'dart:developer' as developer;

class ApiClient {
  static const String baseUrl = 'https://type-backend.linka.su/api';

  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  bool _isRefreshing = false;

  Future<Map<String, String>> _getHeaders() async {
    try {
      final token = await TokenManager.getToken();
      final headers = {'Content-Type': 'application/json'};

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
      final uri = Uri.parse(
        '$baseUrl$endpoint',
      ).replace(queryParameters: queryParams);

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
      if (response.statusCode == 401 && !_isRefreshing) {
        try {
          _isRefreshing = true;
          await _attemptAutoRelogin();
          // Повторяем запрос с новым токеном
          final result = await _retryRequest(response.request!);
          _isRefreshing = false;
          return result;
        } catch (e) {
          _isRefreshing = false;
          // Очищаем токен только если это не AuthenticationException (уже очищено в _attemptAutoRelogin)
          if (e is! AuthenticationException) {
            await TokenManager.clearAll();
          }
          rethrow;
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
      final refreshToken = await TokenManager.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        throw AuthenticationException('No refresh token available');
      }

      developer.log('Пытаюсь обновить токен автоматически');

      // Создаем запрос напрямую без использования ApiClient
      final request = {'refreshToken': refreshToken};
      final uri = Uri.parse('$baseUrl/refresh-token');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        final loginResponse = LoginResponse.fromJson(responseData);

        // Проверяем, что токен действительно получен
        if (loginResponse.token.isEmpty) {
          throw AuthenticationException(
              'Failed to refresh token: empty token received');
        }

        await TokenManager.saveToken(loginResponse.token);
        if (loginResponse.refreshToken != null &&
            loginResponse.refreshToken!.isNotEmpty) {
          await TokenManager.saveRefreshToken(loginResponse.refreshToken!);
        }

        // Дополнительная проверка сохранения токена
        final savedToken = await TokenManager.getToken();
        if (savedToken != loginResponse.token) {
          throw AuthenticationException('Failed to save refreshed token');
        }

        developer.log('Токен успешно обновлен автоматически');
      } else {
        final errorBody = response.body.isNotEmpty
            ? jsonDecode(response.body) as Map<String, dynamic>
            : <String, dynamic>{};
        throw AuthenticationException(
            'Failed to refresh token: ${response.statusCode} - ${errorBody['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      developer.log('Ошибка при автоматическом обновлении токена: $e');
      // Очищаем все данные при неудачном refresh только если это не AuthenticationException
      if (e is! AuthenticationException) {
        await TokenManager.clearAll();
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _retryRequest(
    http.BaseRequest originalRequest,
  ) async {
    final headers = await _getHeaders();
    final uri = originalRequest.url;

    http.Response response;
    switch (originalRequest.method.toUpperCase()) {
      case 'GET':
        response = await http.get(uri, headers: headers);
        break;
      case 'POST':
        response = await http.post(
          uri,
          headers: headers,
          body: originalRequest is http.Request ? originalRequest.body : null,
        );
        break;
      case 'PUT':
        response = await http.put(
          uri,
          headers: headers,
          body: originalRequest is http.Request ? originalRequest.body : null,
        );
        break;
      case 'DELETE':
        response = await http.delete(uri, headers: headers);
        break;
      default:
        throw Exception('Unsupported HTTP method: ${originalRequest.method}');
    }

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    final response = await _makeRequest(
      'GET',
      endpoint,
      queryParams: queryParams,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final response = await _makeRequest('POST', endpoint, body: body);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final response = await _makeRequest('PUT', endpoint, body: body);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    final response = await _makeRequest('DELETE', endpoint);
    return _handleResponse(response);
  }
}
