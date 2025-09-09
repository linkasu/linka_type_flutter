// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'LINKa Type';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get enterEmail => 'Enter email';

  @override
  String get enterPassword => 'Enter password';

  @override
  String get passwordMinLength => 'Password must contain at least 6 characters';

  @override
  String welcomeMessage(String email) {
    return 'Welcome, $email!';
  }

  @override
  String get errorInvalidCredentials => 'Invalid email or password';

  @override
  String get errorInvalidFormat => 'Invalid data format';

  @override
  String get errorServer => 'Server error';

  @override
  String get errorNetwork => 'Network error';

  @override
  String get errorUnauthorized => 'Unauthorized';

  @override
  String get errorUnknown => 'Unknown error';

  @override
  String errorOccurred(String error) {
    return 'An error occurred: $error';
  }

  @override
  String loadingDataError(String error) {
    return 'Error loading data: $error';
  }

  @override
  String updateError(String error) {
    return 'Update error: $error';
  }

  @override
  String deleteError(String error) {
    return 'Delete error: $error';
  }

  @override
  String addError(String error) {
    return 'Add error: $error';
  }

  @override
  String get settings => 'Settings';

  @override
  String get logout => 'Logout';

  @override
  String ttsError(String error) {
    return 'Playback error: $error';
  }

  @override
  String ttsStatus(String error) {
    return 'Error: $error';
  }

  @override
  String get errorCopied => 'Error copied to clipboard';

  @override
  String get errorCopiedShort => 'Error copied';
}
