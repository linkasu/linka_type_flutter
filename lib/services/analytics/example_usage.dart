// Пример использования модуля аналитики

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../analytics_manager.dart';
import '../analytics_events.dart';

class ExampleScreen extends StatefulWidget {
  const ExampleScreen({super.key});

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  late AnalyticsManager _analyticsManager;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _analyticsManager = context.read<AnalyticsManager>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Пример аналитики'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: _forceSync,
            tooltip: 'Синхронизировать события',
          ),
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: _showAnalyticsInfo,
            tooltip: 'Информация об аналитике',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Трекинг просмотра экрана
            ElevatedButton(
              onPressed: _trackScreenView,
              child: const Text('Трекинг просмотра экрана'),
            ),
            const SizedBox(height: 16),

            // Трекинг нажатия кнопки
            ElevatedButton(
              onPressed: _trackButtonClick,
              child: const Text('Трекинг нажатия кнопки'),
            ),
            const SizedBox(height: 16),

            // Трекинг пользовательского действия
            ElevatedButton(
              onPressed: _trackUserAction,
              child: const Text('Трекинг пользовательского действия'),
            ),
            const SizedBox(height: 16),

            // Трекинг ошибки
            ElevatedButton(
              onPressed: _trackError,
              child: const Text('Трекинг ошибки'),
            ),
            const SizedBox(height: 16),

            // Трекинг TTS
            ElevatedButton(
              onPressed: _trackTTS,
              child: const Text('Трекинг TTS'),
            ),
            const SizedBox(height: 16),

            // Трекинг создания контента
            ElevatedButton(
              onPressed: _trackContentCreation,
              child: const Text('Трекинг создания контента'),
            ),
            const SizedBox(height: 16),

            // Трекинг навигации
            ElevatedButton(
              onPressed: _trackNavigation,
              child: const Text('Трекинг навигации'),
            ),
            const SizedBox(height: 16),

            // Трекинг настроек
            ElevatedButton(
              onPressed: _trackSettings,
              child: const Text('Трекинг настроек'),
            ),
          ],
        ),
      ),
    );
  }

  // Трекинг просмотра экрана
  Future<void> _trackScreenView() async {
    await _analyticsManager.trackEvent(AnalyticsEvents.screenView, data: {
      'screen_name': 'example_screen',
      'timestamp': DateTime.now().toIso8601String(),
      'user_agent': 'Flutter App',
    });
    _showSnackBar('Событие просмотра экрана отправлено');
  }

  // Трекинг нажатия кнопки
  Future<void> _trackButtonClick() async {
    await _analyticsManager.trackEvent(AnalyticsEvents.buttonClicked, data: {
      'button_name': 'example_button',
      'screen': 'example_screen',
      'position': 'center',
      'timestamp': DateTime.now().toIso8601String(),
    });
    _showSnackBar('Событие нажатия кнопки отправлено');
  }

  // Трекинг пользовательского действия
  Future<void> _trackUserAction() async {
    await _analyticsManager.trackEvent('user_action', data: {
      'action_type': 'custom_action',
      'action_value': 'example_value',
      'context': 'example_screen',
      'timestamp': DateTime.now().toIso8601String(),
    });
    _showSnackBar('Пользовательское действие отправлено');
  }

  // Трекинг ошибки
  Future<void> _trackError() async {
    await _analyticsManager.trackEvent(AnalyticsEvents.errorOccurred, data: {
      'error_type': 'example_error',
      'error_message': 'This is an example error for testing',
      'error_code': 'EXAMPLE_001',
      'screen': 'example_screen',
      'timestamp': DateTime.now().toIso8601String(),
    });
    _showSnackBar('Событие ошибки отправлено');
  }

  // Трекинг TTS
  Future<void> _trackTTS() async {
    await _analyticsManager.trackEvent(AnalyticsEvents.ttsStarted, data: {
      'text': 'Пример текста для озвучивания',
      'text_length': 35,
      'voice': 'default',
      'source': 'example_screen',
      'timestamp': DateTime.now().toIso8601String(),
    });
    _showSnackBar('Событие TTS отправлено');
  }

  // Трекинг создания контента
  Future<void> _trackContentCreation() async {
    await _analyticsManager.trackEvent(AnalyticsEvents.statementCreated, data: {
      'statement_id': 'example_123',
      'category_id': 'example_category',
      'text_length': 25,
      'creation_method': 'manual',
      'timestamp': DateTime.now().toIso8601String(),
    });
    _showSnackBar('Событие создания контента отправлено');
  }

  // Трекинг навигации
  Future<void> _trackNavigation() async {
    await _analyticsManager.trackEvent('navigation', data: {
      'from_screen': 'example_screen',
      'to_screen': 'settings_screen',
      'navigation_method': 'button_click',
      'timestamp': DateTime.now().toIso8601String(),
    });
    _showSnackBar('Событие навигации отправлено');
  }

  // Трекинг настроек
  Future<void> _trackSettings() async {
    await _analyticsManager.trackEvent(AnalyticsEvents.settingsChanged, data: {
      'setting_name': 'theme',
      'old_value': 'light',
      'new_value': 'dark',
      'timestamp': DateTime.now().toIso8601String(),
    });
    _showSnackBar('Событие изменения настроек отправлено');
  }

  // Принудительная синхронизация
  Future<void> _forceSync() async {
    try {
      await _analyticsManager.forceSync();
      _showSnackBar('Синхронизация завершена');
    } catch (e) {
      _showSnackBar('Ошибка синхронизации: $e');
    }
  }

  // Показать информацию об аналитике
  Future<void> _showAnalyticsInfo() async {
    try {
      final pendingCount = await _analyticsManager.getPendingEventsCount();
      final isOnline = _analyticsManager.isOnline;
      final isInitialized = _analyticsManager.isInitialized;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Информация об аналитике'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Инициализирован: ${isInitialized ? "Да" : "Нет"}'),
              Text('Онлайн режим: ${isOnline ? "Да" : "Нет"}'),
              Text('Неотправленных событий: $pendingCount'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Закрыть'),
            ),
          ],
        ),
      );
    } catch (e) {
      _showSnackBar('Ошибка получения информации: $e');
    }
  }

  // Показать уведомление
  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

// Пример использования в виджете
class ExampleWidget extends StatelessWidget {
  const ExampleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalyticsManager>(
      builder: (context, analyticsManager, child) {
        return ElevatedButton(
          onPressed: () async {
            await analyticsManager
                .trackEvent(AnalyticsEvents.buttonClicked, data: {
              'button_name': 'example_widget_button',
              'widget_type': 'ExampleWidget',
            });
          },
          child: const Text('Кнопка с аналитикой'),
        );
      },
    );
  }
}

// Пример массового трекинга событий
class BatchAnalyticsExample {
  final AnalyticsManager _analyticsManager;

  BatchAnalyticsExample(this._analyticsManager);

  Future<void> trackUserSession() async {
    final events = [
      {
        'event': AnalyticsEvents.screenView,
        'data': {'screen_name': 'main_screen'}
      },
      {
        'event': AnalyticsEvents.buttonClicked,
        'data': {'button_name': 'start_button'}
      },
      {
        'event': 'user_session_started',
        'data': {'session_id': 'session_123'}
      },
    ];

    await _analyticsManager.trackEvents(events);
  }
}
