import 'package:flutter/material.dart';
import 'package:linka_type_flutter/services/offline_data_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('Инициализация оффлайн сервиса...');
  final offlineService = OfflineDataService();
  await offlineService.initialize();

  print('Тестирование создания категории оффлайн...');
  try {
    final category = await offlineService.createCategory('Тестовая категория');
    print('Категория создана: ${category.title} (ID: ${category.id})');

    print('Тестирование создания фразы оффлайн...');
    final statement = await offlineService.createStatement(
      'Тестовая фраза',
      category.id,
    );
    print('Фраза создана: ${statement.title} (ID: ${statement.id})');

    print('Получение всех категорий...');
    final categories = await offlineService.getCategories();
    print('Найдено категорий: ${categories.length}');
    for (var cat in categories) {
      print('  - ${cat.title} (ID: ${cat.id})');
    }

    print('Получение всех фраз...');
    final statements = await offlineService.getStatements();
    print('Найдено фраз: ${statements.length}');
    for (var stmt in statements) {
      print('  - ${stmt.title} (ID: ${stmt.id})');
    }

    print('Проверка количества ожидающих синхронизации элементов...');
    final pendingCount = await offlineService.getPendingSyncCount();
    print('Ожидает синхронизации: $pendingCount элементов');

    print('Статистика очереди синхронизации...');
    final stats = await offlineService.getSyncQueueStats();
    print('Статистика: $stats');

    print('Тест завершен успешно!');
  } catch (e) {
    print('Ошибка тестирования: $e');
    print('StackTrace: ${StackTrace.current}');
  }
}
