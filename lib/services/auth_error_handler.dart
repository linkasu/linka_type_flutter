import 'package:flutter/material.dart';
import '../api/exceptions.dart';
import '../api/utils/token_manager.dart';
import '../ui/screens/login_screen.dart';

class AuthErrorHandler {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static void handleAuthError(dynamic error) {
    if (error is AuthenticationException) {
      _handleAuthenticationException(error);
    }
  }

  static void _handleAuthenticationException(AuthenticationException error) {
    // Очищаем все токены при ошибке аутентификации
    TokenManager.clearAll();

    // Перенаправляем на экран логина
    _navigateToLogin();
  }

  static void _navigateToLogin() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  static void logoutAndNavigateToLogin() {
    TokenManager.clearAll();
    _navigateToLogin();
  }
}
