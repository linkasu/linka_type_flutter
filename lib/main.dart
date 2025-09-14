import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'ui/ui.dart';
import 'services/shortcut_controller.dart';
import 'services/data_manager.dart';
import 'services/auth_error_handler.dart';
import 'services/analytics_manager.dart';
import 'api/services/data_service.dart';
import 'offline/providers/sync_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Отключаем анимации на десктопных платформах для предотвращения мерцания
  if (kIsWeb || 
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.windows) {
    timeDilation = 0.0;
  }

  // Инициализируем менеджер данных
  final dataService = DataService();
  final dataManager = await DataManager.create(dataService);

  // Инициализируем аналитику
  final analyticsManager = AnalyticsManager();
  await analyticsManager.initialize();

  // Трекинг запуска приложения
  await analyticsManager.trackEvent('app_startup', data: {
    'timestamp': DateTime.now().toIso8601String(),
    'platform': 'flutter',
  });

  runApp(MyApp(dataManager: dataManager, analyticsManager: analyticsManager));
}

class MyApp extends StatelessWidget {
  final DataManager dataManager;
  final AnalyticsManager analyticsManager;

  const MyApp(
      {super.key, required this.dataManager, required this.analyticsManager});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Провайдер для управления синхронизацией
        ChangeNotifierProvider<SyncProvider>(
          create: (_) => SyncProvider(dataManager.offlineManager),
        ),
        // Провайдер для доступа к менеджеру данных
        Provider<DataManager>.value(value: dataManager),
        // Провайдер для доступа к аналитике
        Provider<AnalyticsManager>.value(value: analyticsManager),
      ],
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) {
          if (event is KeyDownEvent) {
            final shortcutController = ShortcutController();
            shortcutController.handleKeyEvent(event);
          }
        },
        child: MaterialApp(
          title: 'LINKa напиши',
          theme: AppTheme.lightTheme,
          navigatorKey: AuthErrorHandler.navigatorKey,
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
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaleFactor:
                    MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2),
                disableAnimations: kIsWeb || 
                    defaultTargetPlatform == TargetPlatform.linux ||
                    defaultTargetPlatform == TargetPlatform.macOS ||
                    defaultTargetPlatform == TargetPlatform.windows,
              ),
              child: child!,
            );
          },
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
