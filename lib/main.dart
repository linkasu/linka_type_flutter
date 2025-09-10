import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'ui/ui.dart';
import 'services/shortcut_controller.dart';
import 'services/offline_data_service.dart';
import 'services/offline_provider.dart';
import 'dart:io' show Platform;

// Импорты для работы с sqflite
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as sqflite_common_ffi;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализируем databaseFactory для desktop платформ
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    // Для desktop платформ используем sqflite_common_ffi
    try {
      sqflite_common_ffi.sqfliteFfiInit();
      sqflite.databaseFactory = sqflite_common_ffi.databaseFactoryFfi;
    } catch (e) {
      // Если импорт не удался, продолжаем с обычным sqflite
    }
  }

  // Инициализируем оффлайн сервисы
  final offlineService = OfflineDataService();
  await offlineService.initialize();

  runApp(MyApp(offlineService: offlineService));
}

class MyApp extends StatelessWidget {
  final OfflineDataService offlineService;

  const MyApp({super.key, required this.offlineService});

  @override
  Widget build(BuildContext context) {
    return OfflineProvider(
      offlineService: offlineService,
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) {
          if (event is KeyDownEvent) {
            final shortcutController = ShortcutController();
            final result = shortcutController.handleKeyEvent(event);
            if (result == KeyEventResult.handled) {
              return;
            }
          }
        },
        child: MaterialApp(
          title: 'LINKa напиши',
          theme: AppTheme.lightTheme,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ru', ''),
            Locale('en', ''),
          ],
          home: const AuthChecker(),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/home': (context) => const HomeScreen(),
          },
        ),
      ),
    );
  }
}
