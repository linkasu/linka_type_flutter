import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

class TokenManager {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _emailKey = 'user_email';

  static Future<void> saveToken(String token) async {
    try {
      developer.log('Пытаюсь сохранить токен в SharedPreferences');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      developer.log('Токен успешно сохранен');
    } catch (e) {
      developer.log('Ошибка при сохранении токена: $e');
      rethrow;
    }
  }

  static Future<String?> getToken() async {
    try {
      developer.log('Получаю токен из SharedPreferences');
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      developer.log('Токен получен: ${token != null ? 'да' : 'нет'}');
      return token;
    } catch (e) {
      developer.log('Ошибка при получении токена: $e');
      return null;
    }
  }

  static Future<void> saveRefreshToken(String refreshToken) async {
    try {
      developer.log('Пытаюсь сохранить refresh token');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_refreshTokenKey, refreshToken);
      developer.log('Refresh token успешно сохранен');
    } catch (e) {
      developer.log('Ошибка при сохранении refresh token: $e');
      rethrow;
    }
  }

  static Future<String?> getRefreshToken() async {
    try {
      developer.log('Получаю refresh token из SharedPreferences');
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(_refreshTokenKey);
      developer.log(
        'Refresh token получен: ${refreshToken != null ? 'да' : 'нет'}',
      );
      return refreshToken;
    } catch (e) {
      developer.log('Ошибка при получении refresh token: $e');
      return null;
    }
  }

  static Future<void> saveUserInfo(String userId, String email) async {
    try {
      developer.log(
        'Сохраняю информацию о пользователе: userId=$userId, email=$email',
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userIdKey, userId);
      await prefs.setString(_emailKey, email);
      developer.log('Информация о пользователе успешно сохранена');
    } catch (e) {
      developer.log('Ошибка при сохранении информации о пользователе: $e');
      rethrow;
    }
  }

  static Future<String?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userIdKey);
    } catch (e) {
      developer.log('Ошибка при получении userId: $e');
      return null;
    }
  }

  static Future<String?> getUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_emailKey);
    } catch (e) {
      developer.log('Ошибка при получении email: $e');
      return null;
    }
  }

  static Future<void> clearAll() async {
    try {
      developer.log('Очищаю все данные из SharedPreferences');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_userIdKey);
      await prefs.remove(_emailKey);
      developer.log('Все данные успешно очищены');
    } catch (e) {
      developer.log('Ошибка при очистке данных: $e');
      rethrow;
    }
  }

  static Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      final isLoggedIn = token != null && token.isNotEmpty;
      developer.log(
        'Проверка авторизации: ${isLoggedIn ? 'авторизован' : 'не авторизован'}',
      );
      return isLoggedIn;
    } catch (e) {
      developer.log('Ошибка при проверке авторизации: $e');
      return false;
    }
  }
}
