import 'dart:async';
import '../api/api.dart';
import '../api/models/statement.dart';
import '../api/models/category.dart';
import '../api/models/local_statement.dart';
import '../api/models/local_category.dart';
import '../api/models/sync_status.dart';
import '../api/exceptions.dart';
import 'local_database_service.dart';
import 'connectivity_service.dart';
import 'sync_service.dart';
import 'sync_queue_service.dart';
import 'notification_service.dart';

class OfflineDataService {
  final LocalDatabaseService _localDb = LocalDatabaseService();
  final ConnectivityService _connectivity = ConnectivityService();
  final SyncService _syncService = SyncService();
  final SyncQueueService _syncQueue = SyncQueueService();

  Future<void> initialize() async {
    await _connectivity.initialize();
    await _syncService.initialize();

    // Слушаем изменения состояния подключения
    _connectivity.statusStream.listen((status) {
      final notificationService = NotificationService();

      if (status == ConnectivityStatus.offline) {
        notificationService.showOfflineMode();
      } else if (status == ConnectivityStatus.online) {
        notificationService.showConnectionRestored();
      }
    });
  }

  // Получение фраз
  Future<List<Statement>> getStatements(
      {String? categoryId, String? userId}) async {
    try {
      final localStatements = await _localDb.getStatements(
        categoryId: categoryId,
        userId: userId,
      );

      // Конвертируем локальные модели в API модели, исключая дубликаты
      final statements = <Statement>[];
      final seenIds = <String>{};

      for (final local in localStatements) {
        final id = local.id ?? local.localId ?? '';
        if (!seenIds.contains(id)) {
          statements.add(Statement(
            id: local.id ?? local.localId ?? '',
            title: local.title,
            userId: local.userId,
            categoryId: local.categoryId,
            createdAt: DateTime.fromMillisecondsSinceEpoch(local.createdAt),
            updatedAt: DateTime.fromMillisecondsSinceEpoch(local.updatedAt),
          ));
          seenIds.add(id);
        }
      }

      // Если онлайн, пытаемся синхронизировать в фоне
      if (_connectivity.currentStatus == ConnectivityStatus.online) {
        _syncService.syncData().catchError((e) {
          print('Background sync error: $e');
        });
      }

      return statements;
    } catch (e) {
      throw Exception('Failed to get statements: $e');
    }
  }

  // Получение одной фразы
  Future<Statement?> getStatement(String id) async {
    try {
      final localStatement = await _localDb.getStatement(id);

      if (localStatement == null) return null;

      return Statement(
        id: localStatement.id ?? '',
        title: localStatement.title,
        userId: localStatement.userId,
        categoryId: localStatement.categoryId,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(localStatement.createdAt),
        updatedAt:
            DateTime.fromMillisecondsSinceEpoch(localStatement.updatedAt),
      );
    } catch (e) {
      throw Exception('Failed to get statement: $e');
    }
  }

  // Создание фразы
  Future<Statement> createStatement(String title, String categoryId) async {
    final now = DateTime.now();
    final localStatement = LocalStatement(
      title: title,
      userId: 'current_user', // TODO: Получить из auth service
      categoryId: categoryId,
      createdAt: now.millisecondsSinceEpoch,
      updatedAt: now.millisecondsSinceEpoch,
      syncStatus: _connectivity.currentStatus == ConnectivityStatus.online
          ? SyncStatus.synced
          : SyncStatus.pending,
    );

    try {
      final localId = await _localDb.insertStatement(localStatement);

      // Если оффлайн, добавляем в очередь синхронизации
      if (_connectivity.currentStatus == ConnectivityStatus.offline) {
        await _syncQueue.addStatementCreate(
          localStatement.copyWith(localId: localId),
        );
      } else {
        // Если онлайн, пытаемся сразу создать на сервере
        try {
          final serverStatement =
              await DataService().createStatement(title, categoryId);

          // Обновляем локальную запись с реальным ID
          await _localDb.updateStatement(
            localStatement.copyWith(
              id: serverStatement.id,
              syncStatus: SyncStatus.synced,
            ),
          );

          return serverStatement;
        } catch (e) {
          // Если не удалось создать на сервере, помечаем как pending
          await _syncQueue.addStatementCreate(
            localStatement.copyWith(localId: localId),
          );
        }
      }

      return Statement(
        id: localId,
        title: title,
        userId: localStatement.userId,
        categoryId: categoryId,
        createdAt: now,
        updatedAt: now,
      );
    } catch (e) {
      throw Exception('Failed to create statement: $e');
    }
  }

  // Обновление фразы
  Future<Statement> updateStatement(
    String id,
    String title,
    String categoryId,
  ) async {
    try {
      final existingStatement = await _localDb.getStatement(id);
      if (existingStatement == null) {
        throw Exception('Statement not found');
      }

      final now = DateTime.now();
      final updatedStatement = existingStatement.copyWith(
        title: title,
        categoryId: categoryId,
        updatedAt: now.millisecondsSinceEpoch,
        syncStatus: _connectivity.currentStatus == ConnectivityStatus.online
            ? SyncStatus.synced
            : SyncStatus.pending,
      );

      await _localDb.updateStatement(updatedStatement);

      // Если оффлайн, добавляем в очередь синхронизации
      if (_connectivity.currentStatus == ConnectivityStatus.offline) {
        await _syncQueue.addStatementUpdate(updatedStatement);
      } else {
        // Если онлайн, пытаемся сразу обновить на сервере
        try {
          final serverStatement = await DataService().updateStatement(
            id,
            title,
            categoryId,
          );

          // Обновляем локальную запись
          await _localDb.updateStatement(
            updatedStatement.copyWith(syncStatus: SyncStatus.synced),
          );

          return serverStatement;
        } catch (e) {
          // Если не удалось обновить на сервере, помечаем как pending
          await _syncQueue.addStatementUpdate(updatedStatement);
        }
      }

      return Statement(
        id: updatedStatement.id ?? id,
        title: title,
        userId: updatedStatement.userId,
        categoryId: categoryId,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(updatedStatement.createdAt),
        updatedAt: now,
      );
    } catch (e) {
      throw Exception('Failed to update statement: $e');
    }
  }

  // Удаление фразы
  Future<void> deleteStatement(String id) async {
    try {
      final existingStatement = await _localDb.getStatement(id);
      if (existingStatement == null) {
        throw Exception('Statement not found');
      }

      // Если оффлайн, добавляем в очередь и помечаем как deleted локально
      if (_connectivity.currentStatus == ConnectivityStatus.offline) {
        await _syncQueue.addStatementDelete(id);
        await _localDb.deleteStatement(id);
      } else {
        // Если онлайн, пытаемся сразу удалить на сервере
        try {
          await DataService().deleteStatement(id);
          await _localDb.deleteStatement(id);
        } catch (e) {
          // Если не удалось удалить на сервере, помечаем как pending delete
          await _syncQueue.addStatementDelete(id);
          await _localDb.updateStatement(
            existingStatement.copyWith(syncStatus: SyncStatus.deleted),
          );
        }
      }
    } catch (e) {
      throw Exception('Failed to delete statement: $e');
    }
  }

  // Методы для работы с категориями аналогичны фразам
  Future<List<Category>> getCategories({String? userId}) async {
    try {
      final localCategories = await _localDb.getCategories(userId: userId);

      // Конвертируем локальные модели в API модели, исключая дубликаты
      final categories = <Category>[];
      final seenIds = <String>{};

      for (final local in localCategories) {
        final id = local.id ?? local.localId ?? '';
        if (!seenIds.contains(id)) {
          categories.add(Category(
            id: local.id ?? local.localId ?? '',
            title: local.title,
            userId: local.userId,
            createdAt: DateTime.fromMillisecondsSinceEpoch(local.createdAt),
            updatedAt: DateTime.fromMillisecondsSinceEpoch(local.updatedAt),
          ));
          seenIds.add(id);
        }
      }

      if (_connectivity.currentStatus == ConnectivityStatus.online) {
        _syncService.syncData().catchError((e) {
          print('Background sync error: $e');
        });
      }

      return categories;
    } catch (e) {
      throw Exception('Failed to get categories: $e');
    }
  }

  Future<Category> createCategory(String title) async {
    final now = DateTime.now();
    final localCategory = LocalCategory(
      title: title,
      userId: 'current_user', // TODO: Получить из auth service
      createdAt: now.millisecondsSinceEpoch,
      updatedAt: now.millisecondsSinceEpoch,
      syncStatus: _connectivity.currentStatus == ConnectivityStatus.online
          ? SyncStatus.synced
          : SyncStatus.pending,
    );

    try {
      final localId = await _localDb.insertCategory(localCategory);

      if (_connectivity.currentStatus == ConnectivityStatus.offline) {
        await _syncQueue.addCategoryCreate(
          localCategory.copyWith(localId: localId),
        );
      } else {
        try {
          final serverCategory = await DataService().createCategory(title);
          await _localDb.updateCategory(
            localCategory.copyWith(
              id: serverCategory.id,
              syncStatus: SyncStatus.synced,
            ),
          );
          return serverCategory;
        } catch (e) {
          await _syncQueue.addCategoryCreate(
            localCategory.copyWith(localId: localId),
          );
        }
      }

      return Category(
        id: localId,
        title: title,
        userId: localCategory.userId,
        createdAt: now,
        updatedAt: now,
      );
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  Future<Category> updateCategory(String id, String title) async {
    try {
      final existingCategory = await _localDb.getCategory(id);
      if (existingCategory == null) {
        throw Exception('Category not found');
      }

      final now = DateTime.now();
      final updatedCategory = existingCategory.copyWith(
        title: title,
        updatedAt: now.millisecondsSinceEpoch,
        syncStatus: _connectivity.currentStatus == ConnectivityStatus.online
            ? SyncStatus.synced
            : SyncStatus.pending,
      );

      await _localDb.updateCategory(updatedCategory);

      if (_connectivity.currentStatus == ConnectivityStatus.offline) {
        await _syncQueue.addCategoryUpdate(updatedCategory);
      } else {
        try {
          final serverCategory = await DataService().updateCategory(id, title);
          await _localDb.updateCategory(
            updatedCategory.copyWith(syncStatus: SyncStatus.synced),
          );
          return serverCategory;
        } catch (e) {
          await _syncQueue.addCategoryUpdate(updatedCategory);
        }
      }

      return Category(
        id: updatedCategory.id ?? id,
        title: title,
        userId: updatedCategory.userId,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(updatedCategory.createdAt),
        updatedAt: now,
      );
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      final existingCategory = await _localDb.getCategory(id);
      if (existingCategory == null) {
        throw Exception('Category not found');
      }

      if (_connectivity.currentStatus == ConnectivityStatus.offline) {
        await _syncQueue.addCategoryDelete(id);
        await _localDb.deleteCategory(id);
      } else {
        try {
          await DataService().deleteCategory(id);
          await _localDb.deleteCategory(id);
        } catch (e) {
          await _syncQueue.addCategoryDelete(id);
          await _localDb.updateCategory(
            existingCategory.copyWith(syncStatus: SyncStatus.deleted),
          );
        }
      }
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  // Статус подключения и синхронизации
  Stream<ConnectivityStatus> get connectivityStream =>
      _connectivity.statusStream;
  Stream<SyncProcessStatus> get syncStatusStream =>
      _syncService.syncStatusStream;

  ConnectivityStatus get currentConnectivityStatus =>
      _connectivity.currentStatus;

  Future<bool> isOnline() => _connectivity.isOnline();
  Future<int> getPendingSyncCount() => _syncQueue.getPendingSyncCount();
  Future<Map<String, int>> getSyncQueueStats() => _syncQueue.getQueueStats();

  // Ручная синхронизация
  Future<void> syncData() => _syncService.syncData();

  Future<void> clearUserData() async {
    await _localDb.clearUserData();
  }

  Future<void> dispose() async {
    await _syncService.dispose();
    await _connectivity.dispose();
  }
}
