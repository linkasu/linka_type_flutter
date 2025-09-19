import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/token_manager.dart';
import '../exceptions.dart';
import '../models/auth_models.dart';
import '../../services/auth_error_handler.dart';
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

      // Специальное логирование для auth endpoints
      final isAuthEndpoint = _isAuthEndpoint(endpoint);
      if (isAuthEndpoint) {
        developer.log('=== API AUTH REQUEST ===');
        developer.log('Method: $method');
        developer.log('Endpoint: $endpoint');
        developer.log('Full URL: $uri');
        developer.log('Headers: $headers');
        if (body != null) {
          // Маскируем чувствительные данные
          final maskedBody = _maskSensitiveData(body);
          developer.log('Request body: ${jsonEncode(maskedBody)}');
        }
      } else {
        developer.log('Отправляю $method запрос на: $uri');
        if (body != null) {
          developer.log('Тело запроса: ${jsonEncode(body)}');
        }
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

      // Специальное логирование для auth endpoints
      if (isAuthEndpoint) {
        developer.log('=== API AUTH RESPONSE ===');
        developer.log('Status Code: ${response.statusCode}');
        developer.log('Response Body: ${response.body}');
        developer.log('Response Headers: ${response.headers}');

        if (response.statusCode >= 400) {
          developer.log('=== API AUTH ERROR ===');
          developer.log('Error Status: ${response.statusCode}');
          developer.log('Error Body: ${response.body}');
          developer.log('Request URL: $uri');
          developer.log('Request Headers: $headers');
          if (body != null) {
            final maskedBody = _maskSensitiveData(body);
            developer.log('Request Body: ${jsonEncode(maskedBody)}');
          }
        } else {
          developer.log('=== API AUTH SUCCESS ===');
        }
      } else {
        developer
            .log('Получен ответ: ${response.statusCode} - ${response.body}');

        // Детальное логирование ошибок
        if (response.statusCode >= 400) {
          developer.log('HTTP ERROR ${response.statusCode}: ${response.body}');
          developer.log('Request URL: $uri');
          developer.log('Request Headers: $headers');
          if (body != null) {
            developer.log('Request Body: ${jsonEncode(body)}');
          }
        }
      }

      return response;
    } catch (e) {
      developer.log('Ошибка при выполнении запроса: $e');
      final uri =
          Uri.parse('$baseUrl$endpoint').replace(queryParameters: queryParams);
      final headers = await _getHeaders();
      developer.log('Request URL: $uri');
      developer.log('Request Headers: $headers');
      if (body != null) {
        developer.log('Request Body: ${jsonEncode(body)}');
      }
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

          print('Failed to refresh token: $e');

          // Обрабатываем ошибку аутентификации
          AuthErrorHandler.handleAuthError(e);

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
    developer.log('=== AUTO RELOGIN START ===');

    try {
      final refreshToken = await TokenManager.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        developer.log('ERROR: No refresh token available for auto relogin');
        throw AuthenticationException('No refresh token available');
      }

      developer.log('Refresh token found, length: ${refreshToken.length}');
      developer.log('Пытаюсь обновить токен автоматически');

      // Создаем запрос напрямую без использования ApiClient
      final request = {'refreshToken': refreshToken};
      final uri = Uri.parse('$baseUrl/refresh-token');

      developer.log('Auto relogin URL: $uri');
      developer.log('Request body: ${jsonEncode(_maskSensitiveData(request))}');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request),
      );

      developer.log('Auto relogin response status: ${response.statusCode}');
      developer.log('Auto relogin response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        developer.log('Auto relogin response successful, parsing data');
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        final loginResponse = LoginResponse.fromJson(responseData);

        developer.log('New token length: ${loginResponse.token.length}');
        developer.log(
            'New refresh token present: ${loginResponse.refreshToken != null}');

        // Проверяем, что токен действительно получен
        if (loginResponse.token.isEmpty) {
          developer.log('ERROR: Empty token received from auto relogin');
          throw AuthenticationException(
              'Failed to refresh token: empty token received');
        }

        developer.log('Saving new tokens');
        await TokenManager.saveToken(loginResponse.token);
        if (loginResponse.refreshToken != null &&
            loginResponse.refreshToken!.isNotEmpty) {
          await TokenManager.saveRefreshToken(loginResponse.refreshToken!);
        }

        // Дополнительная проверка сохранения токена
        final savedToken = await TokenManager.getToken();
        if (savedToken != loginResponse.token) {
          developer
              .log('ERROR: Token was not saved correctly after auto relogin');
          throw AuthenticationException('Failed to save refreshed token');
        }

        developer.log('=== AUTO RELOGIN SUCCESS ===');
      } else {
        developer.log('=== AUTO RELOGIN ERROR ===');
        developer.log('Error status: ${response.statusCode}');
        developer.log('Error body: ${response.body}');

        final errorBody = response.body.isNotEmpty
            ? jsonDecode(response.body) as Map<String, dynamic>
            : <String, dynamic>{};
        throw AuthenticationException(
            'Failed to refresh token: ${response.statusCode} - ${errorBody['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      developer.log('=== AUTO RELOGIN EXCEPTION ===');
      developer.log('Exception type: ${e.runtimeType}');
      developer.log('Exception message: $e');

      // Обрабатываем ошибку аутентификации
      AuthErrorHandler.handleAuthError(e);

      rethrow;
    }
  }

  Future<Map<String, dynamic>> _retryRequest(
    http.BaseRequest originalRequest,
  ) async {
    developer.log('=== RETRY REQUEST START ===');
    developer.log('Original method: ${originalRequest.method}');
    developer.log('Original URL: ${originalRequest.url}');

    final headers = await _getHeaders();
    final uri = originalRequest.url;

    http.Response response;
    switch (originalRequest.method.toUpperCase()) {
      case 'GET':
        developer.log('Retrying GET request');
        response = await http.get(uri, headers: headers);
        break;
      case 'POST':
        developer.log('Retrying POST request');
        response = await http.post(
          uri,
          headers: headers,
          body: originalRequest is http.Request ? originalRequest.body : null,
        );
        break;
      case 'PUT':
        developer.log('Retrying PUT request');
        response = await http.put(
          uri,
          headers: headers,
          body: originalRequest is http.Request ? originalRequest.body : null,
        );
        break;
      case 'DELETE':
        developer.log('Retrying DELETE request');
        response = await http.delete(uri, headers: headers);
        break;
      default:
        throw Exception('Unsupported HTTP method: ${originalRequest.method}');
    }

    developer.log('Retry response status: ${response.statusCode}');
    developer.log('=== RETRY REQUEST END ===');

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

  // Проверяет, является ли endpoint аутентификационным
  bool _isAuthEndpoint(String endpoint) {
    final authEndpoints = [
      '/login',
      '/register',
      '/verify-email',
      '/reset-password',
      '/reset-password/verify',
      '/reset-password/confirm',
      '/refresh-token',
      '/profile',
    ];
    return authEndpoints
        .any((authEndpoint) => endpoint.startsWith(authEndpoint));
  }

  // Маскирует чувствительные данные в теле запроса
  Map<String, dynamic> _maskSensitiveData(Map<String, dynamic> body) {
    final maskedBody = Map<String, dynamic>.from(body);

    // Маскируем пароли
    if (maskedBody.containsKey('password')) {
      maskedBody['password'] = '***MASKED***';
    }
    if (maskedBody.containsKey('newPassword')) {
      maskedBody['newPassword'] = '***MASKED***';
    }

    // Маскируем токены
    if (maskedBody.containsKey('refreshToken')) {
      final token = maskedBody['refreshToken'] as String?;
      if (token != null && token.isNotEmpty) {
        maskedBody['refreshToken'] = '${token.substring(0, 8)}...***MASKED***';
      }
    }

    return maskedBody;
  }
}
