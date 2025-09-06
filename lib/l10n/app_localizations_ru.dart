// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'LINKa напиши';

  @override
  String get login => 'Войти';

  @override
  String get register => 'Регистрация';

  @override
  String get forgotPassword => 'Забыли пароль?';

  @override
  String get email => 'Email';

  @override
  String get password => 'Пароль';

  @override
  String get enterEmail => 'Введите email';

  @override
  String get enterPassword => 'Введите пароль';

  @override
  String get passwordMinLength => 'Пароль должен содержать минимум 6 символов';

  @override
  String welcomeMessage(String email) {
    return 'Добро пожаловать, $email!';
  }

  @override
  String get errorInvalidCredentials => 'Неверный email или пароль';

  @override
  String get errorInvalidFormat => 'Неверный формат данных';

  @override
  String get errorServer => 'Ошибка сервера';

  @override
  String get errorNetwork => 'Ошибка сети';

  @override
  String get errorUnauthorized => 'Не авторизован';

  @override
  String get errorUnknown => 'Неизвестная ошибка';

  @override
  String errorOccurred(String error) {
    return 'Произошла ошибка: $error';
  }

  @override
  String loadingDataError(String error) {
    return 'Ошибка загрузки данных: $error';
  }

  @override
  String updateError(String error) {
    return 'Ошибка обновления: $error';
  }

  @override
  String deleteError(String error) {
    return 'Ошибка удаления: $error';
  }

  @override
  String addError(String error) {
    return 'Ошибка добавления: $error';
  }

  @override
  String get settings => 'Настройки';

  @override
  String get logout => 'Выйти';

  @override
  String ttsError(String error) {
    return 'Ошибка воспроизведения: $error';
  }

  @override
  String ttsStatus(String error) {
    return 'Ошибка: $error';
  }

  @override
  String get errorCopied => 'Ошибка скопирована в буфер обмена';

  @override
  String get errorCopiedShort => 'Ошибка скопирована';
}
