import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'ui/ui.dart';
import 'services/shortcut_controller.dart';
import 'services/data_manager.dart';
import 'services/auth_error_handler.dart';
import 'api/services/data_service.dart';
import 'offline/providers/sync_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализируем менеджер данных
  final dataService = DataService();
  final dataManager = await DataManager.create(dataService);

  runApp(MyApp(dataManager: dataManager));
}

class MyApp extends StatelessWidget {
  final DataManager dataManager;

  const MyApp({super.key, required this.dataManager});

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
      ],
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
        ),
      ),
    );
  }
}
