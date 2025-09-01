import '../models/auth_models.dart';
import '../utils/token_manager.dart';
import 'api_client.dart';
import 'dart:developer' as developer;

class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<LoginResponse> login(String email, String password) async {
    try {
      developer.log('Начинаю процесс авторизации для email: $email');
      
      final request = LoginRequest(email: email, password: password);
      developer.log('Отправляю запрос на /login');
      
      final response = await _apiClient.post('/login', body: request.toJson());
      developer.log('Получен ответ от сервера: ${response.toString()}');
      
      final loginResponse = LoginResponse.fromJson(response);
      developer.log('Ответ успешно десериализован');
      
      developer.log('Сохраняю токен в TokenManager');
      await TokenManager.saveToken(loginResponse.token);
      
      if (loginResponse.refreshToken != null && loginResponse.refreshToken!.isNotEmpty) {
        developer.log('Сохраняю refresh token');
        await TokenManager.saveRefreshToken(loginResponse.refreshToken!);
      }
      
      developer.log('Сохраняю информацию о пользователе');
      await TokenManager.saveUserInfo(loginResponse.user.id, loginResponse.user.email);
      
      developer.log('Авторизация завершена успешно');
      return loginResponse;
    } catch (e, stackTrace) {
      developer.log('Ошибка при авторизации: $e');
      developer.log('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> register(String email, String password) async {
    try {
      final request = RegisterRequest(email: email, password: password);
      await _apiClient.post('/register', body: request.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> verifyEmail(String email, String code) async {
    try {
      final request = VerifyEmailRequest(email: email, code: code);
      await _apiClient.post('/verify-email', body: request.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> requestPasswordReset(String email) async {
    try {
      final request = ResetPasswordRequest(email: email);
      await _apiClient.post('/auth/reset-password', body: request.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> verifyPasswordResetOTP(String email, String code) async {
    try {
      final request = ResetPasswordVerifyRequest(email: email, code: code);
      await _apiClient.post('/auth/reset-password/verify', body: request.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> confirmPasswordReset(String email, String code, String newPassword) async {
    try {
      final request = ResetPasswordConfirmRequest(
        email: email,
        code: code,
        password: newPassword,
      );
      await _apiClient.post('/auth/reset-password/confirm', body: request.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await TokenManager.clearAll();
  }

  Future<bool> isLoggedIn() async {
    return await TokenManager.isLoggedIn();
  }

  Future<String?> getToken() async {
    return await TokenManager.getToken();
  }

  Future<String?> getUserId() async {
    return await TokenManager.getUserId();
  }

  Future<String?> getUserEmail() async {
    return await TokenManager.getUserEmail();
  }

  Future<LoginResponse> refreshToken() async {
    try {
      final refreshToken = await TokenManager.getRefreshToken();
      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }

      final request = RefreshTokenRequest(refreshToken: refreshToken);
      final response = await _apiClient.post('/refresh', body: request.toJson());
      
      final loginResponse = LoginResponse.fromJson(response);
      
      await TokenManager.saveToken(loginResponse.token);
      if (loginResponse.refreshToken != null && loginResponse.refreshToken!.isNotEmpty) {
        await TokenManager.saveRefreshToken(loginResponse.refreshToken!);
      }
      
      return loginResponse;
    } catch (e) {
      rethrow;
    }
  }
}
