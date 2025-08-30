import '../models/auth_models.dart';
import '../utils/token_manager.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<LoginResponse> login(String email, String password) async {
    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _apiClient.post('/login', body: request.toJson());
      
      final loginResponse = LoginResponse.fromJson(response);
      
      await TokenManager.saveToken(loginResponse.token);
      await TokenManager.saveUserInfo(loginResponse.user.id, loginResponse.user.email);
      
      return loginResponse;
    } catch (e) {
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
    // TODO: Реализовать на сервере
    // Временно возвращаем успех для демонстрации UI
    await Future.delayed(const Duration(seconds: 1));
    // throw ApiException(
    //   statusCode: 501,
    //   message: 'Функциональность сброса пароля пока не реализована на сервере',
    // );
  }

  Future<void> verifyPasswordResetOTP(String email, String code) async {
    // TODO: Реализовать на сервере
    // Временно возвращаем успех для демонстрации UI
    await Future.delayed(const Duration(seconds: 1));
    // throw ApiException(
    //   statusCode: 501,
    //   message: 'Функциональность сброса пароля пока не реализована на сервере',
    // );
  }

  Future<void> confirmPasswordReset(String email, String code, String newPassword) async {
    // TODO: Реализовать на сервере
    // Временно возвращаем успех для демонстрации UI
    await Future.delayed(const Duration(seconds:1));
    // throw ApiException(
    //   statusCode: 501,
    //   message: 'Функциональность сброса пароля пока не реализована на сервере',
    // );
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
}
