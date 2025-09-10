import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../api/api.dart';
import '../api/models/statement.dart';
import '../api/models/category.dart';
import '../api/models/local_statement.dart';
import '../api/models/local_category.dart';
import '../api/models/sync_queue_item.dart';
import '../api/models/sync_status.dart';
import '../api/exceptions.dart';
import 'local_database_service.dart';
import 'connectivity_service.dart';

class SyncService {
  final LocalDatabaseService _localDb = LocalDatabaseService();
  final DataService _dataService = DataService();
  final ConnectivityService _connectivity = ConnectivityService();

  final StreamController<SyncProcessStatus> _syncStatusController =
      StreamController<SyncProcessStatus>.broadcast();

  Stream<SyncProcessStatus> get syncStatusStream =>
      _syncStatusController.stream;

  Future<void> initialize() async {
    // Слушаем изменения состояния подключения
    _connectivity.statusStream.listen((status) {
      if (status == ConnectivityStatus.online) {
        // При появлении интернета запускаем синхронизацию
        syncData();
      }
    });
  }

  Future<void> syncData() async {
    if (_connectivity.currentStatus == ConnectivityStatus.offline) {
      _syncStatusController.add(SyncProcessStatus.offline);
      return;
    }

    _syncStatusController.add(SyncProcessStatus.syncing);

    try {
      // Синхронизируем фразы
      await _syncStatements();

      // Синхронизируем категории
      await _syncCategories();

      // Обрабатываем очередь синхронизации
      await _processSyncQueue();

      _syncStatusController.add(SyncProcessStatus.completed);
    } catch (e) {
      _syncStatusController.add(SyncProcessStatus.error);
      rethrow;
    }
  }

  Future<void> _syncStatements() async {
    try {
      // Получаем данные с сервера
      final serverStatements = await _dataService.getStatements();

      // Получаем все локальные данные (включая pending)
      final allLocalStatements = await _localDb.getStatements();
      final syncedLocalStatements =
          allLocalStatements.where((stmt) => stmt.id != null).toList();
      final pendingLocalStatements = allLocalStatements
          .where((stmt) =>
              stmt.id == null && stmt.syncStatus == SyncStatus.pending)
          .toList();

      // 1. Синхронизируем серверные данные
      for (final serverStatement in serverStatements) {
        final localStatement = syncedLocalStatements
            .where((local) => local.id == serverStatement.id)
            .firstOrNull;

        if (localStatement == null) {
          // Новая фраза с сервера
          await _localDb.insertStatement(
            LocalStatement.fromApi(serverStatement),
          );
        } else if (serverStatement.updatedAt.isAfter(
          DateTime.fromMillisecondsSinceEpoch(localStatement.updatedAt),
        )) {
          // Серверная версия новее - обновляем локальную
          await _localDb.updateStatement(
            LocalStatement.fromApi(serverStatement),
          );
        } else if (localStatement.updatedAt >
                serverStatement.updatedAt.millisecondsSinceEpoch &&
            localStatement.syncStatus == SyncStatus.pending) {
          // Локальная версия новее и ожидает синхронизации - конфликт
          await _resolveStatementConflict(localStatement, serverStatement);
        }
      }

      // 2. Удаляем локальные фразы, которых нет на сервере
      final serverIds = serverStatements.map((stmt) => stmt.id).toSet();
      for (final localStatement in syncedLocalStatements) {
        if (localStatement.id != null &&
            !serverIds.contains(localStatement.id)) {
          await _localDb.deleteStatement(localStatement.id!);
        }
      }

      // 3. Обрабатываем pending фразы
      for (final pendingStatement in pendingLocalStatements) {
        try {
          // Пытаемся создать на сервере
          final serverStatement = await _dataService.createStatement(
            pendingStatement.title,
            pendingStatement.categoryId,
          );
          await _localDb.updateStatement(
            pendingStatement.copyWith(
              id: serverStatement.id,
              syncStatus: SyncStatus.synced,
            ),
          );
        } catch (e) {
          // Если не удалось, оставляем как pending
          print('Failed to sync pending statement: $e');
        }
      }
    } catch (e) {
      // В случае ошибки с сервером продолжаем работу с локальными данными
      print('Error syncing statements: $e');
    }
  }

  Future<void> _syncCategories() async {
    try {
      // Получаем данные с сервера
      final serverCategories = await _dataService.getCategories();

      // Получаем все локальные данные (включая pending)
      final allLocalCategories = await _localDb.getCategories();
      final syncedLocalCategories =
          allLocalCategories.where((cat) => cat.id != null).toList();
      final pendingLocalCategories = allLocalCategories
          .where(
              (cat) => cat.id == null && cat.syncStatus == SyncStatus.pending)
          .toList();

      // 1. Синхронизируем серверные данные
      for (final serverCategory in serverCategories) {
        final localCategory = syncedLocalCategories
            .where((local) => local.id == serverCategory.id)
            .firstOrNull;

        if (localCategory == null) {
          // Новая категория с сервера
          await _localDb.insertCategory(
            LocalCategory.fromApi(serverCategory),
          );
        } else if (serverCategory.updatedAt.isAfter(
          DateTime.fromMillisecondsSinceEpoch(localCategory.updatedAt),
        )) {
          // Серверная версия новее - обновляем локальную
          await _localDb.updateCategory(
            LocalCategory.fromApi(serverCategory),
          );
        } else if (localCategory.updatedAt >
                serverCategory.updatedAt.millisecondsSinceEpoch &&
            localCategory.syncStatus == SyncStatus.pending) {
          // Локальная версия новее и ожидает синхронизации - конфликт
          await _resolveCategoryConflict(localCategory, serverCategory);
        }
      }

      // 2. Удаляем локальные категории, которых нет на сервере
      final serverIds = serverCategories.map((cat) => cat.id).toSet();
      for (final localCategory in syncedLocalCategories) {
        if (localCategory.id != null && !serverIds.contains(localCategory.id)) {
          await _localDb.deleteCategory(localCategory.id!);
        }
      }

      // 3. Обрабатываем pending категории
      for (final pendingCategory in pendingLocalCategories) {
        try {
          // Пытаемся создать на сервере
          final serverCategory =
              await _dataService.createCategory(pendingCategory.title);
          await _localDb.updateCategory(
            pendingCategory.copyWith(
              id: serverCategory.id,
              syncStatus: SyncStatus.synced,
            ),
          );
        } catch (e) {
          // Если не удалось, оставляем как pending
          print('Failed to sync pending category: $e');
        }
      }
    } catch (e) {
      // В случае ошибки с сервером продолжаем работу с локальными данными
      print('Error syncing categories: $e');
    }
  }

  Future<void> _resolveStatementConflict(
    LocalStatement localStatement,
    dynamic serverStatement,
  ) async {
    // Стратегия разрешения конфликтов: сервер имеет приоритет
    // В будущем можно добавить более сложную логику выбора версии

    // Обновляем локальную версию данными с сервера
    await _localDb.updateStatement(
      LocalStatement.fromApi(serverStatement),
    );
  }

  Future<void> _resolveCategoryConflict(
    LocalCategory localCategory,
    dynamic serverCategory,
  ) async {
    // Обновляем локальную версию данными с сервера
    await _localDb.updateCategory(
      LocalCategory.fromApi(serverCategory),
    );
  }

  Future<int> _processSyncQueue() async {
    final queueItems = await _localDb.getSyncQueueItems();
    int processedCount = 0;

    for (final item in queueItems) {
      try {
        await _processQueueItem(item);
        await _localDb.removeFromSyncQueue(item.id!);
        processedCount++;
      } catch (e) {
        // Увеличиваем счетчик попыток
        final newRetryCount = item.retryCount + 1;
        await _localDb.updateSyncQueueRetryCount(item.id!, newRetryCount);

        // Если превысили лимит попыток, удаляем из очереди
        if (newRetryCount >= 5) {
          await _localDb.removeFromSyncQueue(item.id!);
        }

        print('Error processing queue item ${item.id}: $e');
      }
    }

    return processedCount;
  }

  Future<void> _processQueueItem(SyncQueueItem item) async {
    switch (item.operation) {
      case SyncOperation.create:
        await _processCreateOperation(item);
        break;
      case SyncOperation.update:
        await _processUpdateOperation(item);
        break;
      case SyncOperation.delete:
        await _processDeleteOperation(item);
        break;
    }
  }

  Future<void> _processCreateOperation(SyncQueueItem item) async {
    if (item.data == null) return;

    final data = jsonDecode(item.data!) as Map<String, dynamic>;

    if (item.tableName == 'statements') {
      final statement = await _dataService.createStatement(
        data['title'],
        data['categoryId'],
      );

      // Обновляем локальную запись с реальным ID от сервера
      final localStatement = await _localDb.getStatement(item.recordId);
      if (localStatement != null) {
        await _localDb.updateStatement(
          localStatement.copyWith(
            id: statement.id,
            syncStatus: SyncStatus.synced,
          ),
        );
      }
    } else if (item.tableName == 'categories') {
      final category = await _dataService.createCategory(data['title']);

      // Обновляем локальную запись с реальным ID от сервера
      final localCategory = await _localDb.getCategory(item.recordId);
      if (localCategory != null) {
        await _localDb.updateCategory(
          localCategory.copyWith(
            id: category.id,
            syncStatus: SyncStatus.synced,
          ),
        );
      }
    }
  }

  Future<void> _processUpdateOperation(SyncQueueItem item) async {
    if (item.data == null) return;

    final data = jsonDecode(item.data!) as Map<String, dynamic>;

    if (item.tableName == 'statements') {
      await _dataService.updateStatement(
        item.recordId,
        data['title'],
        data['categoryId'],
      );
    } else if (item.tableName == 'categories') {
      await _dataService.updateCategory(
        item.recordId,
        data['title'],
      );
    }
  }

  Future<void> _processDeleteOperation(SyncQueueItem item) async {
    if (item.tableName == 'statements') {
      await _dataService.deleteStatement(item.recordId);
    } else if (item.tableName == 'categories') {
      await _dataService.deleteCategory(item.recordId);
    }
  }

  Future<void> dispose() async {
    await _syncStatusController.close();
  }
}

enum SyncProcessStatus {
  idle,
  syncing,
  completed,
  error,
  offline,
}
