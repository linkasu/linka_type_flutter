import 'package:flutter/material.dart';
import '../../api/api.dart';
import '../theme/app_theme.dart';
import 'reset_password_new_password_screen.dart';

class ResetPasswordOTPScreen extends StatefulWidget {
  final String email;

  const ResetPasswordOTPScreen({super.key, required this.email});

  @override
  State<ResetPasswordOTPScreen> createState() => _ResetPasswordOTPScreenState();
}

class _ResetPasswordOTPScreenState extends State<ResetPasswordOTPScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await _authService.verifyPasswordResetOTP(
        widget.email,
        _otpController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _successMessage = 'Код подтвержден';
        });

        // Переход на экран установки нового пароля
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ResetPasswordNewPasswordScreen(
              email: widget.email,
              otp: _otpController.text.trim(),
            ),
          ),
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

  Future<void> _resendOTP() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.requestPasswordReset(widget.email);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Новый код отправлен на ваш email'),
            backgroundColor: Colors.green,
          ),
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
        return 'Неверный код подтверждения';
      case 404:
        return 'Код не найден или истек';
      case 429:
        return 'Слишком много попыток. Попробуйте позже';
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
        title: const Text('Подтверждение кода'),
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
                        Icons.security,
                        size: 80,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Введите код подтверждения',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Код отправлен на ${widget.email}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // OTP поле
                      TextFormField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _verifyOTP(),
                        decoration: const InputDecoration(
                          labelText: 'Код подтверждения',
                          prefixIcon: Icon(Icons.security),
                          counterText: '',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите код подтверждения';
                          }
                          if (value.length != 6) {
                            return 'Код должен содержать 6 цифр';
                          }
                          if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                            return 'Код должен содержать только цифры';
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

                      // Кнопка подтверждения
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _verifyOTP,
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
                              : const Text('Подтвердить'),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Кнопка повторной отправки
                      TextButton(
                        onPressed: _isLoading ? null : _resendOTP,
                        child: const Text('Отправить код повторно'),
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
