import '../models/auth_models.dart';
import '../utils/token_manager.dart';
import '../exceptions.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<LoginResponse> login(String email, String password) async {
    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _apiClient.post('/login', body: request.toJson());
      final loginResponse = LoginResponse.fromJson(response);

      // Проверяем, что refresh token пришел
      if (loginResponse.refreshToken == null ||
          loginResponse.refreshToken!.isEmpty) {
        throw AuthenticationException(
            'Login failed: refresh token not provided by server');
      }

      await TokenManager.saveToken(loginResponse.token);
      await TokenManager.saveRefreshToken(loginResponse.refreshToken!);
      await TokenManager.saveUserInfo(
        loginResponse.user.id,
        loginResponse.user.email,
      );

      return loginResponse;
    } catch (e) {
      rethrow;
    }
  }

  Future<RegisterResponse> register(String email, String password) async {
    try {
      final request = RegisterRequest(email: email, password: password);
      final response =
          await _apiClient.post('/register', body: request.toJson());
      final registerResponse = RegisterResponse.fromJson(response);

      // Проверяем, что refresh token пришел
      if (registerResponse.refreshToken == null ||
          registerResponse.refreshToken!.isEmpty) {
        throw AuthenticationException(
            'Registration failed: refresh token not provided by server');
      }

      // Сохраняем токен если он есть
      if (registerResponse.token.isNotEmpty) {
        await TokenManager.saveToken(registerResponse.token);
      }

      await TokenManager.saveRefreshToken(registerResponse.refreshToken!);
      await TokenManager.saveUserInfo(
        registerResponse.user.id,
        registerResponse.user.email,
      );

      return registerResponse;
    } catch (e) {
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
        throw AuthenticationException('No refresh token available');
      }

      // Создаем запрос с refresh token в теле
      final request = {'refreshToken': refreshToken};
      final response = await _apiClient.post('/refresh-token', body: request);
      final loginResponse = LoginResponse.fromJson(response);

      // Проверяем, что токен действительно обновился
      if (loginResponse.token.isEmpty) {
        throw AuthenticationException(
            'Failed to refresh token: empty token received');
      }

      await TokenManager.saveToken(loginResponse.token);
      if (loginResponse.refreshToken != null &&
          loginResponse.refreshToken!.isNotEmpty) {
        await TokenManager.saveRefreshToken(loginResponse.refreshToken!);
      }

      // Дополнительная проверка: убеждаемся, что токен сохранился
      final savedToken = await TokenManager.getToken();
      if (savedToken != loginResponse.token) {
        throw AuthenticationException('Failed to save refreshed token');
      }

      return loginResponse;
    } catch (e) {
      if (e is AuthenticationException) {
        rethrow;
      }
      throw AuthenticationException('Token refresh failed: ${e.toString()}');
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
