import '../models/auth_models.dart';
import '../utils/token_manager.dart';
import '../exceptions.dart';
import '../../services/auth_error_handler.dart';
import 'api_client.dart';
import 'dart:developer' as developer;

class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<LoginResponse> login(String email, String password) async {
    developer.log('=== AUTH LOGIN START ===');
    developer.log('Email: $email');
    developer.log('Password length: ${password.length}');

    try {
      final request = LoginRequest(email: email, password: password);
      developer.log('Отправляю запрос на логин');

      final response = await _apiClient.post('/login', body: request.toJson());
      developer.log('Получен ответ от сервера, парсинг данных');

      final loginResponse = LoginResponse.fromJson(response);
      developer.log('Login response parsed successfully');
      developer.log('User ID: ${loginResponse.user.id}');
      developer.log('User email: ${loginResponse.user.email}');
      developer.log('Token length: ${loginResponse.token.length}');
      developer
          .log('Refresh token present: ${loginResponse.refreshToken != null}');

      // Проверяем, что refresh token пришел
      if (loginResponse.refreshToken == null ||
          loginResponse.refreshToken!.isEmpty) {
        developer.log('ERROR: Refresh token not provided by server');
        throw AuthenticationException(
            'Login failed: refresh token not provided by server');
      }

      developer.log('Сохраняю токены и информацию о пользователе');
      await TokenManager.saveToken(loginResponse.token);
      await TokenManager.saveRefreshToken(loginResponse.refreshToken!);
      await TokenManager.saveUserInfo(
        loginResponse.user.id,
        loginResponse.user.email,
      );

      developer.log('=== AUTH LOGIN SUCCESS ===');
      return loginResponse;
    } catch (e) {
      developer.log('=== AUTH LOGIN ERROR ===');
      developer.log('Error type: ${e.runtimeType}');
      developer.log('Error message: $e');
      if (e is ApiException) {
        developer.log('API Error status: ${e.statusCode}');
        developer.log('API Error details: ${e.details}');
      }
      rethrow;
    }
  }

  Future<RegisterResponse> register(String email, String password) async {
    developer.log('=== AUTH REGISTER START ===');
    developer.log('Email: $email');
    developer.log('Password length: ${password.length}');

    try {
      final request = RegisterRequest(email: email, password: password);
      developer.log('Отправляю запрос на регистрацию');

      final response =
          await _apiClient.post('/register', body: request.toJson());
      developer.log('Получен ответ от сервера, парсинг данных');

      final registerResponse = RegisterResponse.fromJson(response);
      developer.log('Register response parsed successfully');
      developer.log('User ID: ${registerResponse.user.id}');
      developer.log('User email: ${registerResponse.user.email}');
      developer.log('Token length: ${registerResponse.token.length}');
      developer.log(
          'Refresh token present: ${registerResponse.refreshToken != null}');

      // Проверяем, что refresh token пришел
      if (registerResponse.refreshToken == null ||
          registerResponse.refreshToken!.isEmpty) {
        developer.log('ERROR: Refresh token not provided by server');
        throw AuthenticationException(
            'Registration failed: refresh token not provided by server');
      }

      // Сохраняем токен если он есть
      if (registerResponse.token.isNotEmpty) {
        developer.log('Сохраняю access token');
        await TokenManager.saveToken(registerResponse.token);
      }

      developer.log('Сохраняю refresh token и информацию о пользователе');
      await TokenManager.saveRefreshToken(registerResponse.refreshToken!);
      await TokenManager.saveUserInfo(
        registerResponse.user.id,
        registerResponse.user.email,
      );

      developer.log('=== AUTH REGISTER SUCCESS ===');
      return registerResponse;
    } catch (e) {
      developer.log('=== AUTH REGISTER ERROR ===');
      developer.log('Error type: ${e.runtimeType}');
      developer.log('Error message: $e');
      if (e is ApiException) {
        developer.log('API Error status: ${e.statusCode}');
        developer.log('API Error details: ${e.details}');
      }
      rethrow;
    }
  }

  Future<VerifyEmailResponse> verifyEmail(String email, String code) async {
    developer.log('=== AUTH VERIFY EMAIL START ===');
    developer.log('Email: $email');
    developer.log('Code length: ${code.length}');

    try {
      final request = VerifyEmailRequest(email: email, code: code);
      developer.log('Отправляю запрос на верификацию email');

      final response =
          await _apiClient.post('/verify-email', body: request.toJson());
      developer.log('Получен ответ от сервера, парсинг данных');

      final verifyResponse = VerifyEmailResponse.fromJson(response);
      developer.log('=== AUTH VERIFY EMAIL SUCCESS ===');
      return verifyResponse;
    } catch (e) {
      developer.log('=== AUTH VERIFY EMAIL ERROR ===');
      developer.log('Error type: ${e.runtimeType}');
      developer.log('Error message: $e');
      if (e is ApiException) {
        developer.log('API Error status: ${e.statusCode}');
        developer.log('API Error details: ${e.details}');
      }
      rethrow;
    }
  }

  Future<ResetPasswordResponse> requestPasswordReset(String email) async {
    developer.log('=== AUTH RESET PASSWORD REQUEST START ===');
    developer.log('Email: $email');

    try {
      final request = ResetPasswordRequest(email: email);
      developer.log('Отправляю запрос на сброс пароля');

      final response =
          await _apiClient.post('/reset-password', body: request.toJson());
      developer.log('Получен ответ от сервера, парсинг данных');

      final resetResponse = ResetPasswordResponse.fromJson(response);
      developer.log('=== AUTH RESET PASSWORD REQUEST SUCCESS ===');
      return resetResponse;
    } catch (e) {
      developer.log('=== AUTH RESET PASSWORD REQUEST ERROR ===');
      developer.log('Error type: ${e.runtimeType}');
      developer.log('Error message: $e');
      if (e is ApiException) {
        developer.log('API Error status: ${e.statusCode}');
        developer.log('API Error details: ${e.details}');
      }
      rethrow;
    }
  }

  Future<ResetPasswordVerifyResponse> verifyPasswordResetOTP(
      String email, String code) async {
    developer.log('=== AUTH VERIFY PASSWORD RESET OTP START ===');
    developer.log('Email: $email');
    developer.log('Code length: ${code.length}');

    try {
      final request = ResetPasswordVerifyRequest(email: email, code: code);
      developer.log('Отправляю запрос на верификацию OTP для сброса пароля');

      final response = await _apiClient.post(
        '/reset-password/verify',
        body: request.toJson(),
      );
      developer.log('Получен ответ от сервера, парсинг данных');

      final verifyResponse = ResetPasswordVerifyResponse.fromJson(response);
      developer.log('=== AUTH VERIFY PASSWORD RESET OTP SUCCESS ===');
      return verifyResponse;
    } catch (e) {
      developer.log('=== AUTH VERIFY PASSWORD RESET OTP ERROR ===');
      developer.log('Error type: ${e.runtimeType}');
      developer.log('Error message: $e');
      if (e is ApiException) {
        developer.log('API Error status: ${e.statusCode}');
        developer.log('API Error details: ${e.details}');
      }
      rethrow;
    }
  }

  Future<ResetPasswordConfirmResponse> confirmPasswordReset(
    String email,
    String code,
    String newPassword,
  ) async {
    developer.log('=== AUTH CONFIRM PASSWORD RESET START ===');
    developer.log('Email: $email');
    developer.log('Code length: ${code.length}');
    developer.log('New password length: ${newPassword.length}');

    try {
      final request = ResetPasswordConfirmRequest(
        email: email,
        code: code,
        newPassword: newPassword,
      );
      developer.log('Отправляю запрос на подтверждение сброса пароля');

      final response = await _apiClient.post(
        '/reset-password/confirm',
        body: request.toJson(),
      );
      developer.log('Получен ответ от сервера, парсинг данных');

      final confirmResponse = ResetPasswordConfirmResponse.fromJson(response);
      developer.log('=== AUTH CONFIRM PASSWORD RESET SUCCESS ===');
      return confirmResponse;
    } catch (e) {
      developer.log('=== AUTH CONFIRM PASSWORD RESET ERROR ===');
      developer.log('Error type: ${e.runtimeType}');
      developer.log('Error message: $e');
      if (e is ApiException) {
        developer.log('API Error status: ${e.statusCode}');
        developer.log('API Error details: ${e.details}');
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    developer.log('=== AUTH LOGOUT START ===');
    try {
      await TokenManager.clearAll();
      developer.log('=== AUTH LOGOUT SUCCESS ===');
    } catch (e) {
      developer.log('=== AUTH LOGOUT ERROR ===');
      developer.log('Error: $e');
      rethrow;
    }
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
    developer.log('=== AUTH REFRESH TOKEN START ===');

    try {
      final refreshToken = await TokenManager.getRefreshToken();
      if (refreshToken == null) {
        developer.log('ERROR: No refresh token available');
        throw AuthenticationException('No refresh token available');
      }

      developer.log('Refresh token found, length: ${refreshToken.length}');
      developer.log('Отправляю запрос на обновление токена');

      // Создаем запрос с refresh token в теле
      final request = {'refreshToken': refreshToken};
      final response = await _apiClient.post('/refresh-token', body: request);
      developer.log('Получен ответ от сервера, парсинг данных');

      final loginResponse = LoginResponse.fromJson(response);
      developer.log('Refresh response parsed successfully');
      developer.log('New token length: ${loginResponse.token.length}');
      developer.log(
          'New refresh token present: ${loginResponse.refreshToken != null}');

      // Проверяем, что токен действительно обновился
      if (loginResponse.token.isEmpty) {
        developer.log('ERROR: Empty token received from server');
        throw AuthenticationException(
            'Failed to refresh token: empty token received');
      }

      developer.log('Сохраняю новые токены');
      await TokenManager.saveToken(loginResponse.token);
      if (loginResponse.refreshToken != null &&
          loginResponse.refreshToken!.isNotEmpty) {
        await TokenManager.saveRefreshToken(loginResponse.refreshToken!);
      }

      // Дополнительная проверка: убеждаемся, что токен сохранился
      final savedToken = await TokenManager.getToken();
      if (savedToken != loginResponse.token) {
        developer.log('ERROR: Token was not saved correctly');
        throw AuthenticationException('Failed to save refreshed token');
      }

      developer.log('=== AUTH REFRESH TOKEN SUCCESS ===');
      return loginResponse;
    } catch (e) {
      developer.log('=== AUTH REFRESH TOKEN ERROR ===');
      developer.log('Error type: ${e.runtimeType}');
      developer.log('Error message: $e');

      if (e is AuthenticationException) {
        // Обрабатываем ошибку аутентификации
        AuthErrorHandler.handleAuthError(e);
        rethrow;
      }
      final authException =
          AuthenticationException('Token refresh failed: ${e.toString()}');
      AuthErrorHandler.handleAuthError(authException);
      throw authException;
    }
  }

  Future<ProfileResponse> getProfile() async {
    developer.log('=== AUTH GET PROFILE START ===');

    try {
      developer.log('Отправляю запрос на получение профиля');
      final response = await _apiClient.get('/profile');
      developer.log('Получен ответ от сервера, парсинг данных');

      final profileResponse = ProfileResponse.fromJson(response);
      developer.log('=== AUTH GET PROFILE SUCCESS ===');
      return profileResponse;
    } on AuthenticationException catch (e) {
      developer.log('=== AUTH GET PROFILE ERROR ===');
      developer.log('Authentication error: $e');
      AuthErrorHandler.handleAuthError(e);
      rethrow;
    } catch (e) {
      developer.log('=== AUTH GET PROFILE ERROR ===');
      developer.log('Error type: ${e.runtimeType}');
      developer.log('Error message: $e');
      if (e is ApiException) {
        developer.log('API Error status: ${e.statusCode}');
        developer.log('API Error details: ${e.details}');
      }
      rethrow;
    }
  }
}
