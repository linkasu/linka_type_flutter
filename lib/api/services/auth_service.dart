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

      if (loginResponse.refreshToken != null &&
          loginResponse.refreshToken!.isNotEmpty) {
        developer.log('Сохраняю refresh token');
        await TokenManager.saveRefreshToken(loginResponse.refreshToken!);
      }

      developer.log('Сохраняю информацию о пользователе');
      await TokenManager.saveUserInfo(
        loginResponse.user.id,
        loginResponse.user.email,
      );

      developer.log('Авторизация завершена успешно');
      return loginResponse;
    } catch (e, stackTrace) {
      developer.log('Ошибка при авторизации: $e');
      developer.log('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<RegisterResponse> register(String email, String password) async {
    try {
      developer.log('Начинаю процесс регистрации для email: $email');

      final request = RegisterRequest(email: email, password: password);
      developer.log('Отправляю запрос на /register');

      final response =
          await _apiClient.post('/register', body: request.toJson());
      developer.log('Получен ответ от сервера: ${response.toString()}');

      final registerResponse = RegisterResponse.fromJson(response);
      developer.log('Ответ успешно десериализован');

      // Сохраняем токен если он есть
      if (registerResponse.token.isNotEmpty) {
        developer.log('Сохраняю токен в TokenManager');
        await TokenManager.saveToken(registerResponse.token);
      }

      if (registerResponse.refreshToken != null &&
          registerResponse.refreshToken!.isNotEmpty) {
        developer.log('Сохраняю refresh token');
        await TokenManager.saveRefreshToken(registerResponse.refreshToken!);
      }

      developer.log('Сохраняю информацию о пользователе');
      await TokenManager.saveUserInfo(
        registerResponse.user.id,
        registerResponse.user.email,
      );

      developer.log('Регистрация завершена успешно');
      return registerResponse;
    } catch (e, stackTrace) {
      developer.log('Ошибка при регистрации: $e');
      developer.log('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<VerifyEmailResponse> verifyEmail(String email, String code) async {
    try {
      final request = VerifyEmailRequest(email: email, code: code);
      final response =
          await _apiClient.post('/verify-email', body: request.toJson());
      return VerifyEmailResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<ResetPasswordResponse> requestPasswordReset(String email) async {
    try {
      final request = ResetPasswordRequest(email: email);
      final response =
          await _apiClient.post('/reset-password', body: request.toJson());
      return ResetPasswordResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<ResetPasswordVerifyResponse> verifyPasswordResetOTP(
      String email, String code) async {
    try {
      final request = ResetPasswordVerifyRequest(email: email, code: code);
      final response = await _apiClient.post(
        '/reset-password/verify',
        body: request.toJson(),
      );
      return ResetPasswordVerifyResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<ResetPasswordConfirmResponse> confirmPasswordReset(
    String email,
    String code,
    String newPassword,
  ) async {
    try {
      final request = ResetPasswordConfirmRequest(
        email: email,
        code: code,
        newPassword: newPassword,
      );
      final response = await _apiClient.post(
        '/reset-password/confirm',
        body: request.toJson(),
      );
      return ResetPasswordConfirmResponse.fromJson(response);
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

      developer.log('Обновляю токен с помощью refresh token');

      // Создаем запрос с refresh token в теле
      final request = {'refreshToken': refreshToken};
      final response = await _apiClient.post('/refresh-token', body: request);

      final loginResponse = LoginResponse.fromJson(response);

      developer.log('Токен успешно обновлен, сохраняю новые токены');
      await TokenManager.saveToken(loginResponse.token);
      if (loginResponse.refreshToken != null &&
          loginResponse.refreshToken!.isNotEmpty) {
        await TokenManager.saveRefreshToken(loginResponse.refreshToken!);
      }

      return loginResponse;
    } catch (e) {
      developer.log('Ошибка при обновлении токена: $e');
      rethrow;
    }
  }

  Future<ProfileResponse> getProfile() async {
    try {
      final response = await _apiClient.get('/profile');
      return ProfileResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
