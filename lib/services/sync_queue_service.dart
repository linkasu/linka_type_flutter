import 'dart:convert';
import '../api/models/sync_queue_item.dart';
import '../api/models/local_statement.dart';
import '../api/models/local_category.dart';
import 'local_database_service.dart';

class SyncQueueService {
  final LocalDatabaseService _localDb = LocalDatabaseService();

  // Добавление операций в очередь синхронизации

  Future<void> addStatementCreate(LocalStatement statement) async {
    final queueItem = SyncQueueItem(
      operation: SyncOperation.create,
      tableName: 'statements',
      recordId: statement.localId ?? statement.id ?? '',
      data: jsonEncode(statement.toApiJson()),
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    await _localDb.addToSyncQueue(queueItem);
  }

  Future<void> addStatementUpdate(LocalStatement statement) async {
    final queueItem = SyncQueueItem(
      operation: SyncOperation.update,
      tableName: 'statements',
      recordId: statement.id ?? statement.localId ?? '',
      data: jsonEncode(statement.toApiJson()),
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    await _localDb.addToSyncQueue(queueItem);
  }

  Future<void> addStatementDelete(String statementId) async {
    final queueItem = SyncQueueItem(
      operation: SyncOperation.delete,
      tableName: 'statements',
      recordId: statementId,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    await _localDb.addToSyncQueue(queueItem);
  }

  Future<void> addCategoryCreate(LocalCategory category) async {
    final queueItem = SyncQueueItem(
      operation: SyncOperation.create,
      tableName: 'categories',
      recordId: category.localId ?? category.id ?? '',
      data: jsonEncode(category.toApiJson()),
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    await _localDb.addToSyncQueue(queueItem);
  }

  Future<void> addCategoryUpdate(LocalCategory category) async {
    final queueItem = SyncQueueItem(
      operation: SyncOperation.update,
      tableName: 'categories',
      recordId: category.id ?? category.localId ?? '',
      data: jsonEncode(category.toApiJson()),
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    await _localDb.addToSyncQueue(queueItem);
  }

  Future<void> addCategoryDelete(String categoryId) async {
    final queueItem = SyncQueueItem(
      operation: SyncOperation.delete,
      tableName: 'categories',
      recordId: categoryId,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    await _localDb.addToSyncQueue(queueItem);
  }

  // Получение информации об очереди

  Future<int> getPendingSyncCount() async {
    return await _localDb.getPendingSyncCount();
  }

  Future<List<SyncQueueItem>> getPendingItems({int? limit}) async {
    return await _localDb.getSyncQueueItems(limit: limit);
  }

  Future<bool> hasPendingChanges() async {
    final count = await getPendingSyncCount();
    return count > 0;
  }

  // Очистка очереди (для тестирования или при сбросе)

  Future<void> clearQueue() async {
    final items = await _localDb.getSyncQueueItems();
    for (final item in items) {
      await _localDb.removeFromSyncQueue(item.id!);
    }
  }

  // Статистика по операциям

  Future<Map<String, int>> getQueueStats() async {
    final items = await _localDb.getSyncQueueItems();

    final stats = <String, int>{
      'total': items.length,
      'create': 0,
      'update': 0,
      'delete': 0,
      'statements': 0,
      'categories': 0,
    };

    for (final item in items) {
      switch (item.operation) {
        case SyncOperation.create:
          stats['create'] = (stats['create'] ?? 0) + 1;
          break;
        case SyncOperation.update:
          stats['update'] = (stats['update'] ?? 0) + 1;
          break;
        case SyncOperation.delete:
          stats['delete'] = (stats['delete'] ?? 0) + 1;
          break;
      }

      if (item.tableName == 'statements') {
        stats['statements'] = (stats['statements'] ?? 0) + 1;
      } else if (item.tableName == 'categories') {
        stats['categories'] = (stats['categories'] ?? 0) + 1;
      }
    }

    return stats;
  }
}
