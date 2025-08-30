import 'package:shared_preferences/shared_preferences.dart';
import 'dart:html' as html;

class TokenManager {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _emailKey = 'user_email';

  static Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
    } catch (e) {
      // Fallback для веб
      html.window.localStorage[_tokenKey] = token;
    }
  }

  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      // Fallback для веб
      return html.window.localStorage[_tokenKey];
    }
  }

  static Future<void> saveRefreshToken(String refreshToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_refreshTokenKey, refreshToken);
    } catch (e) {
      html.window.localStorage[_refreshTokenKey] = refreshToken;
    }
  }

  static Future<String?> getRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_refreshTokenKey);
    } catch (e) {
      return html.window.localStorage[_refreshTokenKey];
    }
  }

  static Future<void> saveUserInfo(String userId, String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userIdKey, userId);
      await prefs.setString(_emailKey, email);
    } catch (e) {
      // Fallback для веб
      html.window.localStorage[_userIdKey] = userId;
      html.window.localStorage[_emailKey] = email;
    }
  }

  static Future<String?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userIdKey);
    } catch (e) {
      return html.window.localStorage[_userIdKey];
    }
  }

  static Future<String?> getUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_emailKey);
    } catch (e) {
      return html.window.localStorage[_emailKey];
    }
  }

  static Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_userIdKey);
      await prefs.remove(_emailKey);
    } catch (e) {
      // Fallback для веб
      html.window.localStorage.remove(_tokenKey);
      html.window.localStorage.remove(_refreshTokenKey);
      html.window.localStorage.remove(_userIdKey);
      html.window.localStorage.remove(_emailKey);
    }
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
