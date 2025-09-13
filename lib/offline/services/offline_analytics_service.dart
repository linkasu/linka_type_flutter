import 'dart:convert';
import 'dart:developer' as developer;
import '../models/offline_event.dart';
import 'json_storage_service.dart';

class OfflineAnalyticsService {
  static const String _eventsKey = 'offline_analytics_events';
  static const int _maxOfflineEvents =
      1000; // Максимум событий в оффлайн режиме

  final JsonStorageService _storageService;

  OfflineAnalyticsService(this._storageService);

  /// Сохраняет событие в оффлайн хранилище
  Future<void> saveEvent(String event, {Map<String, dynamic>? data}) async {
    try {
      final offlineEvent = OfflineEvent(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        event: event,
        data: data,
        createdAt: DateTime.now().toIso8601String(),
        isSent: false,
      );

      final events = await _getOfflineEvents();

      // Добавляем новое событие в начало списка
      events.insert(0, offlineEvent);

      // Ограничиваем количество событий
      if (events.length > _maxOfflineEvents) {
        events.removeRange(_maxOfflineEvents, events.length);
      }

      await _saveOfflineEvents(events);
      developer.log('Событие сохранено оффлайн: $event');
    } catch (e) {
      developer.log('Ошибка при сохранении оффлайн события: $e');
    }
  }

  /// Получает все неотправленные события
  Future<List<OfflineEvent>> getPendingEvents() async {
    try {
      final events = await _getOfflineEvents();
      return events.where((event) => !event.isSent).toList();
    } catch (e) {
      developer.log('Ошибка при получении оффлайн событий: $e');
      return [];
    }
  }

  /// Получает все события (включая отправленные)
  Future<List<OfflineEvent>> getAllEvents() async {
    try {
      return await _getOfflineEvents();
    } catch (e) {
      developer.log('Ошибка при получении всех оффлайн событий: $e');
      return [];
    }
  }

  /// Помечает событие как отправленное
  Future<void> markEventAsSent(String eventId) async {
    try {
      final events = await _getOfflineEvents();
      final eventIndex = events.indexWhere((event) => event.id == eventId);

      if (eventIndex != -1) {
        events[eventIndex] = events[eventIndex].copyWith(isSent: true);
        await _saveOfflineEvents(events);
        developer.log('Событие помечено как отправленное: $eventId');
      }
    } catch (e) {
      developer.log('Ошибка при пометке события как отправленного: $e');
    }
  }

  /// Помечает несколько событий как отправленные
  Future<void> markEventsAsSent(List<String> eventIds) async {
    try {
      final events = await _getOfflineEvents();

      for (int i = 0; i < events.length; i++) {
        if (eventIds.contains(events[i].id)) {
          events[i] = events[i].copyWith(isSent: true);
        }
      }

      await _saveOfflineEvents(events);
      developer.log('События помечены как отправленные: ${eventIds.length}');
    } catch (e) {
      developer.log('Ошибка при пометке событий как отправленных: $e');
    }
  }

  /// Удаляет отправленные события старше указанного количества дней
  Future<void> cleanupOldEvents({int daysToKeep = 7}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
      final events = await _getOfflineEvents();

      final filteredEvents = events.where((event) {
        if (!event.isSent) return true; // Не удаляем неотправленные события

        final eventDate = DateTime.tryParse(event.createdAt);
        if (eventDate == null) return true;

        return eventDate.isAfter(cutoffDate);
      }).toList();

      if (filteredEvents.length != events.length) {
        await _saveOfflineEvents(filteredEvents);
        developer.log(
            'Очищены старые события: ${events.length - filteredEvents.length}');
      }
    } catch (e) {
      developer.log('Ошибка при очистке старых событий: $e');
    }
  }

  /// Очищает все оффлайн события
  Future<void> clearAllEvents() async {
    try {
      await _storageService.remove(_eventsKey);
      developer.log('Все оффлайн события очищены');
    } catch (e) {
      developer.log('Ошибка при очистке всех оффлайн событий: $e');
    }
  }

  /// Получает количество неотправленных событий
  Future<int> getPendingEventsCount() async {
    try {
      final events = await _getOfflineEvents();
      return events.where((event) => !event.isSent).length;
    } catch (e) {
      developer.log('Ошибка при подсчете неотправленных событий: $e');
      return 0;
    }
  }

  /// Получает оффлайн события из хранилища
  Future<List<OfflineEvent>> _getOfflineEvents() async {
    try {
      final eventsJson = await _storageService.getString(_eventsKey);
      if (eventsJson == null || eventsJson.isEmpty) {
        return [];
      }

      final List<dynamic> eventsList = jsonDecode(eventsJson);
      return eventsList
          .map((json) => OfflineEvent.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      developer.log('Ошибка при чтении оффлайн событий: $e');
      return [];
    }
  }

  /// Сохраняет оффлайн события в хранилище
  Future<void> _saveOfflineEvents(List<OfflineEvent> events) async {
    try {
      final eventsJson =
          jsonEncode(events.map((event) => event.toJson()).toList());
      await _storageService.setString(_eventsKey, eventsJson);
    } catch (e) {
      developer.log('Ошибка при сохранении оффлайн событий: $e');
    }
  }
}
