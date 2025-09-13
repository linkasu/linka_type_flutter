import 'dart:async';
import 'dart:developer' as developer;
import '../api/services/analytics_service.dart';
import '../offline/services/offline_analytics_service.dart';
import '../offline/services/json_storage_service.dart';
import '../offline/models/offline_event.dart';

class AnalyticsManager {
  static final AnalyticsManager _instance = AnalyticsManager._internal();
  factory AnalyticsManager() => _instance;
  AnalyticsManager._internal();

  late final AnalyticsService _analyticsService;
  late final OfflineAnalyticsService _offlineAnalyticsService;
  late final JsonStorageService _storageService;

  Timer? _syncTimer;
  bool _isInitialized = false;
  bool _isOnline = true;

  /// Инициализирует менеджер аналитики
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _storageService = JsonStorageService();
      _analyticsService = AnalyticsService();
      _offlineAnalyticsService = OfflineAnalyticsService(_storageService);

      // Запускаем периодическую синхронизацию каждые 30 секунд
      _syncTimer = Timer.periodic(Duration(seconds: 30), (_) {
        _syncPendingEvents();
      });

      // Очищаем старые события при инициализации
      await _offlineAnalyticsService.cleanupOldEvents();

      _isInitialized = true;
      developer.log('AnalyticsManager инициализирован');
    } catch (e) {
      developer.log('Ошибка при инициализации AnalyticsManager: $e');
    }
  }

  /// Отправляет событие (онлайн или оффлайн)
  Future<void> trackEvent(String event, {Map<String, dynamic>? data}) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      if (_isOnline) {
        // Пытаемся отправить онлайн
        try {
          await _analyticsService.trackEvent(event, data: data);
          developer.log('Событие отправлено онлайн: $event');
          return;
        } catch (e) {
          developer
              .log('Не удалось отправить событие онлайн, сохраняю оффлайн: $e');
          _isOnline = false;
        }
      }

      // Сохраняем оффлайн
      await _offlineAnalyticsService.saveEvent(event, data: data);
      developer.log('Событие сохранено оффлайн: $event');
    } catch (e) {
      developer.log('Ошибка при трекинге события: $e');
    }
  }

  /// Отправляет несколько событий
  Future<void> trackEvents(List<Map<String, dynamic>> events) async {
    for (final eventData in events) {
      final event = eventData['event'] as String;
      final data = eventData['data'] as Map<String, dynamic>?;
      await trackEvent(event, data: data);
    }
  }

  /// Синхронизирует неотправленные события
  Future<void> syncPendingEvents() async {
    if (!_isInitialized) return;

    try {
      final pendingEvents = await _offlineAnalyticsService.getPendingEvents();
      if (pendingEvents.isEmpty) return;

      developer
          .log('Синхронизирую ${pendingEvents.length} неотправленных событий');

      // Проверяем доступность сервера
      final isServerAvailable = await _analyticsService.isServerAvailable();
      if (!isServerAvailable) {
        developer.log('Сервер недоступен, пропускаю синхронизацию');
        return;
      }

      _isOnline = true;
      final sentEventIds = <String>[];

      // Отправляем события по одному
      for (final offlineEvent in pendingEvents) {
        try {
          await _analyticsService.trackEvent(
            offlineEvent.event,
            data: offlineEvent.data,
          );
          sentEventIds.add(offlineEvent.id);
          developer.log('Событие синхронизировано: ${offlineEvent.event}');
        } catch (e) {
          developer
              .log('Ошибка при синхронизации события ${offlineEvent.id}: $e');
          // Если не удалось отправить, прерываем синхронизацию
          break;
        }
      }

      // Помечаем отправленные события
      if (sentEventIds.isNotEmpty) {
        await _offlineAnalyticsService.markEventsAsSent(sentEventIds);
        developer
            .log('Помечено как отправленные: ${sentEventIds.length} событий');
      }
    } catch (e) {
      developer.log('Ошибка при синхронизации событий: $e');
    }
  }

  /// Принудительная синхронизация
  Future<void> forceSync() async {
    await syncPendingEvents();
  }

  /// Получает количество неотправленных событий
  Future<int> getPendingEventsCount() async {
    if (!_isInitialized) return 0;
    return await _offlineAnalyticsService.getPendingEventsCount();
  }

  /// Получает все события (включая отправленные)
  Future<List<OfflineEvent>> getAllEvents() async {
    if (!_isInitialized) return [];
    return await _offlineAnalyticsService.getAllEvents();
  }

  /// Очищает все события
  Future<void> clearAllEvents() async {
    if (!_isInitialized) return;
    await _offlineAnalyticsService.clearAllEvents();
  }

  /// Устанавливает статус онлайн/оффлайн
  void setOnlineStatus(bool isOnline) {
    _isOnline = isOnline;
    developer
        .log('Статус соединения изменен: ${isOnline ? "онлайн" : "оффлайн"}');
  }

  /// Проверяет, инициализирован ли менеджер
  bool get isInitialized => _isInitialized;

  /// Проверяет, находится ли приложение в онлайн режиме
  bool get isOnline => _isOnline;

  /// Освобождает ресурсы
  void dispose() {
    _syncTimer?.cancel();
    _syncTimer = null;
    _isInitialized = false;
    developer.log('AnalyticsManager освобожден');
  }

  /// Автоматическая синхронизация (вызывается таймером)
  void _syncPendingEvents() {
    syncPendingEvents();
  }
}
