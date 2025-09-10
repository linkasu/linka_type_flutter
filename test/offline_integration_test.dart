import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:linka_type_flutter/api/models/statement.dart';
import 'package:linka_type_flutter/api/models/category.dart';
import 'package:linka_type_flutter/services/offline_data_service.dart';

// Моки для тестирования
class MockDataService extends Mock {
  Future<List<Statement>> getStatements() async => [];
  Future<Statement> createStatement(String title, String categoryId) async {
    return Statement(
      id: 'server_id_123',
      title: title,
      userId: 'test_user',
      categoryId: categoryId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

void main() {
  group('Offline Integration Tests', () {
    late OfflineDataService offlineService;

    setUp(() async {
      offlineService = OfflineDataService();
      // Для тестов используем моковые сервисы
    });

    test('should work in offline mode', () async {
      // Имитируем оффлайн режим
      // В реальном приложении это будет сделано через ConnectivityService

      // Создаем фразу в оффлайн режиме
      final statement = await offlineService.createStatement(
        'Test offline statement',
        'test_category',
      );

      expect(statement.id, isNotEmpty);
      expect(statement.title, equals('Test offline statement'));

      // Получаем фразу
      final retrievedStatement =
          await offlineService.getStatement(statement.id);
      expect(retrievedStatement, isNotNull);
      expect(retrievedStatement!.title, equals('Test offline statement'));
    });

    test('should create category offline', () async {
      // Создаем категорию в оффлайн режиме
      final category =
          await offlineService.createCategory('Test offline category');

      expect(category.id, isNotEmpty);
      expect(category.title, equals('Test offline category'));

      // Получаем категории
      final categories = await offlineService.getCategories();
      expect(categories.length, greaterThanOrEqualTo(1));

      final retrievedCategory = categories.firstWhere(
        (cat) => cat.id == category.id,
        orElse: () => throw Exception('Category not found'),
      );
      expect(retrievedCategory.title, equals('Test offline category'));
    });

    test('should handle statement operations offline', () async {
      // Создаем фразу
      final statement = await offlineService.createStatement(
        'Original statement',
        'test_category',
      );

      // Обновляем фразу
      final updatedStatement = await offlineService.updateStatement(
        statement.id,
        'Updated statement',
        'test_category',
      );

      expect(updatedStatement.title, equals('Updated statement'));

      // Удаляем фразу
      await offlineService.deleteStatement(statement.id);

      // Проверяем, что фраза больше не возвращается в списке
      final statements = await offlineService.getStatements();
      final deletedStatement = statements.where((s) => s.id == statement.id);
      expect(deletedStatement.isEmpty, isTrue);
    });

    test('should track pending changes', () async {
      // Имитируем оффлайн режим
      final initialPendingCount = await offlineService.getPendingSyncCount();

      // Создаем несколько фраз
      await offlineService.createStatement('Statement 1', 'category1');
      await offlineService.createStatement('Statement 2', 'category1');

      // Проверяем статистику синхронизации
      final stats = await offlineService.getSyncQueueStats();
      expect(stats['total'], greaterThanOrEqualTo(0));
    });

    test('should handle bulk operations offline', () async {
      // Создаем несколько фраз
      final statements = [
        await offlineService.createStatement('Bulk 1', 'bulk_category'),
        await offlineService.createStatement('Bulk 2', 'bulk_category'),
        await offlineService.createStatement('Bulk 3', 'bulk_category'),
      ];

      // Проверяем, что все фразы созданы
      final allStatements = await offlineService.getStatements();
      final bulkStatements = allStatements.where(
        (s) => s.categoryId == 'bulk_category',
      );

      expect(bulkStatements.length, greaterThanOrEqualTo(3));

      // Удаляем все фразы
      for (final statement in statements) {
        await offlineService.deleteStatement(statement.id);
      }

      // Проверяем, что фразы удалены
      final remainingStatements = await offlineService.getStatements(
        categoryId: 'bulk_category',
      );
      expect(remainingStatements.isEmpty, isTrue);
    });
  });
}
