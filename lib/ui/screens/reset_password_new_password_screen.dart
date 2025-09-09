import 'package:flutter/material.dart';
import '../../api/api.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class ResetPasswordNewPasswordScreen extends StatefulWidget {
  final String email;
  final String otp;

  const ResetPasswordNewPasswordScreen({
    super.key,
    required this.email,
    required this.otp,
  });

  @override
  State<ResetPasswordNewPasswordScreen> createState() =>
      _ResetPasswordNewPasswordScreenState();
}

class _ResetPasswordNewPasswordScreenState
    extends State<ResetPasswordNewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await _authService.confirmPasswordReset(
        widget.email,
        widget.otp,
        _passwordController.text,
      );

      if (mounted) {
        setState(() {
          _successMessage = 'Пароль успешно изменен';
        });

        // Показать сообщение об успехе и перейти на экран входа
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Пароль успешно изменен. Теперь вы можете войти в систему',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // Переход на экран входа
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e.statusCode);
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Произошла ошибка: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Неверные данные для сброса пароля';
      case 404:
        return 'Код подтверждения не найден или истек';
      case 422:
        return 'Новый пароль не соответствует требованиям';
      case 500:
        return 'Ошибка сервера';
      default:
        return 'Произошла ошибка';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Новый пароль'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.lock_outline,
                        size: 80,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Установите новый пароль',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Придумайте надежный пароль для вашего аккаунта',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 32),

                      // Новый пароль
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Новый пароль',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите новый пароль';
                          }
                          if (value.length < 8) {
                            return 'Пароль должен содержать минимум 8 символов';
                          }
                          if (!RegExp(
                            r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)',
                          ).hasMatch(value)) {
                            return 'Пароль должен содержать буквы в разных регистрах и цифры';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Подтверждение пароля
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _resetPassword(),
                        decoration: InputDecoration(
                          labelText: 'Подтвердите пароль',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Подтвердите пароль';
                          }
                          if (value != _passwordController.text) {
                            return 'Пароли не совпадают';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Сообщение об ошибке
                      if (_errorMessage != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.errorColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.errorColor),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: AppTheme.errorColor),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Сообщение об успехе
                      if (_successMessage != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green),
                          ),
                          child: Text(
                            _successMessage!,
                            style: const TextStyle(color: Colors.green),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Кнопка сброса пароля
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _resetPassword,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text('Изменить пароль'),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Кнопка возврата
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Вернуться назад'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
