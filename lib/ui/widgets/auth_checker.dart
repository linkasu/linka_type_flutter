import 'package:flutter/material.dart';
import '../../api/api.dart';
import '../../api/exceptions.dart';
import '../../services/auth_error_handler.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';

class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();

      setState(() {
        _isLoggedIn = isLoggedIn;
        _isLoading = false;
      });
    } on AuthenticationException catch (e) {
      print('AuthChecker: Authentication error: $e');
      // Обрабатываем ошибку аутентификации
      AuthErrorHandler.handleAuthError(e);
      setState(() {
        _isLoggedIn = false;
        _isLoading = false;
      });
    } catch (e) {
      print('AuthChecker: Error checking auth status: $e');
      setState(() {
        _isLoggedIn = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Проверка авторизации...'),
            ],
          ),
        ),
      );
    }

    return _isLoggedIn ? const HomeScreen() : const LoginScreen();
  }
}
