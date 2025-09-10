import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:linka_type_flutter/api/models/local_statement.dart';
import 'package:linka_type_flutter/api/models/local_category.dart';
import 'package:linka_type_flutter/api/models/sync_status.dart';
import 'package:linka_type_flutter/services/local_database_service.dart';

void main() {
  // Инициализация для тестирования
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('LocalDatabaseService', () {
    late LocalDatabaseService dbService;

    setUp(() async {
      dbService = LocalDatabaseService();
      // Создаем временную базу данных для тестов
      await dbService.database;
    });

    tearDown(() async {
      await dbService.clearDatabase();
      await dbService.close();
    });

    test('should create and retrieve statement', () async {
      // Создаем тестовую фразу
      final testStatement = LocalStatement(
        title: 'Test Statement',
        userId: 'test_user',
        categoryId: 'test_category',
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        syncStatus: SyncStatus.pending,
      );

      // Сохраняем фразу
      final localId = await dbService.insertStatement(testStatement);
      expect(localId, isNotNull);
      expect(localId, isNotEmpty);

      // Получаем фразу по ID
      final retrievedStatement = await dbService.getStatement(localId);
      expect(retrievedStatement, isNotNull);
      expect(retrievedStatement!.title, equals('Test Statement'));
      expect(retrievedStatement.userId, equals('test_user'));
      expect(retrievedStatement.syncStatus, equals(SyncStatus.pending));
    });

    test('should update statement', () async {
      // Создаем тестовую фразу
      final testStatement = LocalStatement(
        title: 'Original Title',
        userId: 'test_user',
        categoryId: 'test_category',
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        syncStatus: SyncStatus.pending,
      );

      final localId = await dbService.insertStatement(testStatement);

      // Обновляем фразу
      final updatedStatement = testStatement.copyWith(
        title: 'Updated Title',
        syncStatus: SyncStatus.synced,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );

      await dbService.updateStatement(updatedStatement);

      // Проверяем обновление
      final retrievedStatement = await dbService.getStatement(localId);
      expect(retrievedStatement!.title, equals('Updated Title'));
      expect(retrievedStatement.syncStatus, equals(SyncStatus.synced));
    });

    test('should delete statement', () async {
      // Создаем тестовую фразу
      final testStatement = LocalStatement(
        title: 'Test Statement',
        userId: 'test_user',
        categoryId: 'test_category',
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        syncStatus: SyncStatus.pending,
      );

      final localId = await dbService.insertStatement(testStatement);

      // Удаляем фразу
      await dbService.deleteStatement(localId);

      // Проверяем, что фраза помечена как удаленная
      final retrievedStatement = await dbService.getStatement(localId);
      expect(retrievedStatement!.syncStatus, equals(SyncStatus.deleted));
    });

    test('should get statements by category', () async {
      // Создаем фразы разных категорий
      final statement1 = LocalStatement(
        title: 'Statement 1',
        userId: 'test_user',
        categoryId: 'category1',
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        syncStatus: SyncStatus.synced,
      );

      final statement2 = LocalStatement(
        title: 'Statement 2',
        userId: 'test_user',
        categoryId: 'category1',
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        syncStatus: SyncStatus.synced,
      );

      final statement3 = LocalStatement(
        title: 'Statement 3',
        userId: 'test_user',
        categoryId: 'category2',
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        syncStatus: SyncStatus.synced,
      );

      await dbService.insertStatement(statement1);
      await dbService.insertStatement(statement2);
      await dbService.insertStatement(statement3);

      // Получаем фразы по категории
      final category1Statements =
          await dbService.getStatements(categoryId: 'category1');
      expect(category1Statements.length, equals(2));

      final category2Statements =
          await dbService.getStatements(categoryId: 'category2');
      expect(category2Statements.length, equals(1));
    });

    test('should create and retrieve category', () async {
      // Создаем тестовую категорию
      final testCategory = LocalCategory(
        title: 'Test Category',
        userId: 'test_user',
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        syncStatus: SyncStatus.pending,
      );

      // Сохраняем категорию
      final localId = await dbService.insertCategory(testCategory);
      expect(localId, isNotNull);
      expect(localId, isNotEmpty);

      // Получаем категорию по ID
      final retrievedCategory = await dbService.getCategory(localId);
      expect(retrievedCategory, isNotNull);
      expect(retrievedCategory!.title, equals('Test Category'));
      expect(retrievedCategory.syncStatus, equals(SyncStatus.pending));
    });

    test('should get pending sync count', () async {
      // Создаем фразы с разными статусами синхронизации
      final syncedStatement = LocalStatement(
        title: 'Synced Statement',
        userId: 'test_user',
        categoryId: 'test_category',
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        syncStatus: SyncStatus.synced,
      );

      final pendingStatement = LocalStatement(
        title: 'Pending Statement',
        userId: 'test_user',
        categoryId: 'test_category',
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        syncStatus: SyncStatus.pending,
      );

      await dbService.insertStatement(syncedStatement);
      await dbService.insertStatement(pendingStatement);

      // Проверяем количество элементов в очереди синхронизации
      final pendingCount = await dbService.getPendingSyncCount();
      expect(pendingCount, equals(0)); // Пока нет элементов в очереди
    });
  });
}
