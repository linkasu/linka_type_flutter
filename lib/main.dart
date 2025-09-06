import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ui/ui.dart';
import 'services/shortcut_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
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
        home: const AuthChecker(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}
