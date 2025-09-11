import '../../api/services/data_service.dart';
import '../../api/models/statement.dart';
import '../../api/models/category.dart';
import '../models/offline_data.dart';
import '../models/sync_state.dart';
import 'json_storage_service.dart';

/// Сервис для интеллектуальной синхронизации данных
class SyncService {
  final DataService _dataService;
  final JsonStorageService _storageService;

  SyncService(this._dataService, this._storageService);

  /// Синхронизирует данные с сервера, используя updatedAt для оптимизации
  Future<OfflineData> syncWithServer({
    DateTime? lastSyncTime,
    bool forceFullSync = false,
  }) async {
    try {
      // Получаем текущие оффлайн данные
      final currentOfflineData =
          await _storageService.loadOfflineData() ?? OfflineData.empty();

      if (forceFullSync || lastSyncTime == null) {
        return await _performFullSync();
      } else {
        return await _performIncrementalSync(currentOfflineData, lastSyncTime);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Выполняет полную синхронизацию
  Future<OfflineData> _performFullSync() async {
    final categories = await _dataService.getCategories();
    final statements = await _dataService.getStatements();

    final offlineData = OfflineData(
      categories: categories,
      statements: statements,
      lastUpdated: DateTime.now(),
      version: 1,
    );

    await _storageService.saveOfflineData(offlineData);
    return offlineData;
  }

  /// Выполняет инкрементальную синхронизацию
  Future<OfflineData> _performIncrementalSync(
    OfflineData currentData,
    DateTime lastSyncTime,
  ) async {
    try {
      // Синхронизируем категории
      final syncedCategories =
          await _syncCategories(currentData.categories, lastSyncTime);

      // Синхронизируем фразы
      final syncedStatements =
          await _syncStatements(currentData.statements, lastSyncTime);

      // Создаем обновленные данные
      final updatedData = OfflineData(
        categories: syncedCategories,
        statements: syncedStatements,
        lastUpdated: DateTime.now(),
        version: currentData.version + 1,
      );

      await _storageService.saveOfflineData(updatedData);
      return updatedData;
    } catch (e) {
      return await _performFullSync();
    }
  }

  /// Синхронизирует категории с оптимизацией по updatedAt
  Future<List<Category>> _syncCategories(
    List<Category> currentCategories,
    DateTime lastSyncTime,
  ) async {
    final serverCategories = await _dataService.getCategories();

    // Создаем карту текущих категорий по ID для быстрого поиска
    final currentCategoriesMap = {
      for (var cat in currentCategories) cat.id: cat
    };

    final syncedCategories = <Category>[];

    for (final serverCategory in serverCategories) {
      final localCategory = currentCategoriesMap[serverCategory.id];

      if (localCategory == null) {
        // Новая категория с сервера
        syncedCategories.add(serverCategory);
      } else if (serverCategory.updatedAt.isAfter(localCategory.updatedAt)) {
        // Категория обновлена на сервере
        syncedCategories.add(serverCategory);
      } else {
        // Используем локальную версию
        syncedCategories.add(localCategory);
      }
    }

    // Проверяем, есть ли локальные категории, удаленные на сервере
    for (final localCategory in currentCategories) {
      final existsOnServer =
          serverCategories.any((cat) => cat.id == localCategory.id);
      if (!existsOnServer) {
        // Категория была удалена на сервере, не добавляем в syncedCategories
      }
    }

    return syncedCategories;
  }

  /// Синхронизирует фразы с оптимизацией по updatedAt
  Future<List<Statement>> _syncStatements(
    List<Statement> currentStatements,
    DateTime lastSyncTime,
  ) async {
    final serverStatements = await _dataService.getStatements();

    // Создаем карту текущих фраз по ID для быстрого поиска
    final currentStatementsMap = {
      for (var stmt in currentStatements) stmt.id: stmt
    };

    final syncedStatements = <Statement>[];

    for (final serverStatement in serverStatements) {
      final localStatement = currentStatementsMap[serverStatement.id];

      if (localStatement == null) {
        // Новая фраза с сервера
        syncedStatements.add(serverStatement);
      } else if (serverStatement.updatedAt.isAfter(localStatement.updatedAt)) {
        // Фраза обновлена на сервере
        syncedStatements.add(serverStatement);
      } else {
        // Используем локальную версию
        syncedStatements.add(localStatement);
      }
    }

    // Проверяем, есть ли локальные фразы, удаленные на сервере
    for (final localStatement in currentStatements) {
      final existsOnServer =
          serverStatements.any((stmt) => stmt.id == localStatement.id);
      if (!existsOnServer) {
        // Фраза была удалена на сервере, не добавляем в syncedStatements
      }
    }

    return syncedStatements;
  }

  /// Проверяет, нужно ли выполнять синхронизацию
  Future<bool> shouldSync(DateTime? lastSyncTime) async {
    if (lastSyncTime == null) return true;

    final timeSinceLastSync = DateTime.now().difference(lastSyncTime);
    // Синхронизируем не чаще чем раз в минуту
    return timeSinceLastSync.inMinutes >= 1;
  }

  /// Получает статистику синхронизации
  Future<SyncStats> getSyncStats() async {
    final offlineData = await _storageService.loadOfflineData();
    if (offlineData == null) {
      return SyncStats.empty();
    }

    final categoriesCount = offlineData.categories.length;
    final statementsCount = offlineData.statements.length;
    final lastSyncTime = offlineData.lastUpdated;

    return SyncStats(
      categoriesCount: categoriesCount,
      statementsCount: statementsCount,
      lastSyncTime: lastSyncTime,
      dataVersion: offlineData.version,
    );
  }
}

/// Статистика синхронизации
class SyncStats {
  final int categoriesCount;
  final int statementsCount;
  final DateTime? lastSyncTime;
  final int dataVersion;

  SyncStats({
    required this.categoriesCount,
    required this.statementsCount,
    this.lastSyncTime,
    required this.dataVersion,
  });

  factory SyncStats.empty() => SyncStats(
        categoriesCount: 0,
        statementsCount: 0,
        dataVersion: 0,
      );
}
