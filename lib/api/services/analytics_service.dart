import 'dart:convert';
import '../models/event.dart';
import 'api_client.dart';
import 'dart:developer' as developer;

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final ApiClient _apiClient = ApiClient();

  /// Отправляет событие на сервер
  Future<Event> trackEvent(String event, {Map<String, dynamic>? data}) async {
    try {
      developer.log('Отправляю событие: $event с данными: $data');

      final requestBody = <String, dynamic>{
        'event': event,
      };

      if (data != null && data.isNotEmpty) {
        requestBody['data'] = _encodeData(data);
      }

      final response = await _apiClient.post('/events', body: requestBody);

      final eventResponse = Event.fromJson(response);
      developer.log('Событие успешно отправлено: ${eventResponse.id}');

      return eventResponse;
    } catch (e) {
      developer.log('Ошибка при отправке события: $e');
      rethrow;
    }
  }

  /// Отправляет несколько событий пакетом
  Future<List<Event>> trackEvents(List<Map<String, dynamic>> events) async {
    final results = <Event>[];

    for (final eventData in events) {
      try {
        final event = eventData['event'] as String;
        final data = eventData['data'] as Map<String, dynamic>?;

        final result = await trackEvent(event, data: data);
        results.add(result);
      } catch (e) {
        developer.log('Ошибка при отправке события в пакете: $e');
        // Продолжаем отправку остальных событий
      }
    }

    return results;
  }

  /// Кодирует данные в JSON строку
  String _encodeData(Map<String, dynamic> data) {
    try {
      return jsonEncode(data);
    } catch (e) {
      developer.log('Ошибка при кодировании данных: $e');
      return '{}';
    }
  }

  /// Проверяет доступность сервера для отправки событий
  Future<bool> isServerAvailable() async {
    try {
      // Попробуем отправить тестовое событие
      await _apiClient.get('/events');
      return true;
    } catch (e) {
      developer.log('Сервер недоступен для аналитики: $e');
      return false;
    }
  }
}
