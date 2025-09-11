import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../api/services/data_service.dart';
import '../../api/models/statement.dart';
import '../../api/models/category.dart';
import '../models/offline_data.dart';
import '../models/sync_state.dart';
import 'json_storage_service.dart';
import 'offline_operation_service.dart';
import 'sync_service.dart';

/// Основной менеджер оффлайн функциональности
class OfflineManager {
  final DataService _dataService;
  final JsonStorageService _storageService;
  final OfflineOperationService _operationService;
  final SyncService _syncService;

  /// Текущее состояние синхронизации
  SyncState _currentSyncState = SyncState.initial();

  /// Stream для отслеживания изменений состояния синхронизации
  final StreamController<SyncState> _syncStateController =
      StreamController<SyncState>.broadcast();

  /// Флаг, указывающий, находится ли система в оффлайн режиме
  bool _isOfflineMode = false;

  /// Подписка на изменения подключения
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  OfflineManager(
      this._dataService, this._storageService, this._operationService)
      : _syncService = SyncService(_dataService, _storageService) {
    _initialize();
  }

  /// Stream состояния синхронизации
  Stream<SyncState> get syncStateStream => _syncStateController.stream;

  /// Текущее состояние синхронизации
  SyncState get currentSyncState => _currentSyncState;

  /// Флаг оффлайн режима
  bool get isOfflineMode => _isOfflineMode;

  /// Инициализация менеджера
  Future<void> _initialize() async {
    await _loadSyncState();
    await _setupConnectivityMonitoring();
    await _checkInitialConnectivity();
  }

  /// Загружает состояние синхронизации из хранилища
  Future<void> _loadSyncState() async {
    final savedState = await _storageService.loadSyncState();
    if (savedState != null) {
      _currentSyncState = savedState;
      _syncStateController.add(_currentSyncState);
    }
  }

  /// Настраивает мониторинг подключения
  Future<void> _setupConnectivityMonitoring() async {
    final connectivity = Connectivity();

    _connectivitySubscription = connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) async {
        final result =
            results.isNotEmpty ? results.first : ConnectivityResult.none;
        final isOnline = result != ConnectivityResult.none;
        await _handleConnectivityChange(isOnline);
      },
    );
  }

  /// Проверяет начальное состояние подключения
  Future<void> _checkInitialConnectivity() async {
    final connectivity = Connectivity();
    final results = await connectivity.checkConnectivity();
    final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
    final isOnline = result != ConnectivityResult.none;
    await _handleConnectivityChange(isOnline);
  }

  /// Обрабатывает изменение состояния подключения
  Future<void> _handleConnectivityChange(bool isOnline) async {
    final wasOffline = _isOfflineMode;
    _isOfflineMode = !isOnline;

    // Обновляем состояние синхронизации
    if (isOnline && wasOffline) {
      // Переход из оффлайн в онлайн
      _currentSyncState = _currentSyncState.copyWith(
        status: SyncStatus.syncing,
        isOnline: true,
      );
      _syncStateController.add(_currentSyncState);

      // Запускаем синхронизацию
      await _syncOnConnectionRestore();
    } else if (!isOnline && !wasOffline) {
      // Переход в оффлайн
      final pendingCount = await _operationService.getPendingOperationsCount();
      _currentSyncState = SyncState.offline(pendingOperations: pendingCount);
      _syncStateController.add(_currentSyncState);
    } else {
      // Обновляем только флаг подключения
      _currentSyncState = _currentSyncState.copyWith(isOnline: isOnline);
      _syncStateController.add(_currentSyncState);
    }

    await _storageService.saveSyncState(_currentSyncState);
  }

  /// Синхронизирует данные при восстановлении подключения
  Future<void> _syncOnConnectionRestore() async {
    try {
      // Проверяем, нужно ли синхронизировать
      final shouldSync =
          await _syncService.shouldSync(_currentSyncState.lastSyncTime);
      if (!shouldSync) {
        final pendingCount =
            await _operationService.getPendingOperationsCount();
        _currentSyncState = SyncState.synced(pendingOperations: pendingCount);
        _syncStateController.add(_currentSyncState);
        await _storageService.saveSyncState(_currentSyncState);
        return;
      }

      // Синхронизируем ожидающие операции
      await _operationService.syncPendingOperations();

      // Интеллектуально синхронизируем данные с сервером
      final offlineData = await _storageService.loadOfflineData();
      final syncedData = await _syncService.syncWithServer(
        lastSyncTime: offlineData?.lastUpdated,
      );

      // Обновляем состояние
      final pendingCount = await _operationService.getPendingOperationsCount();
      _currentSyncState = SyncState.synced(pendingOperations: pendingCount);
      _syncStateController.add(_currentSyncState);

      await _storageService.saveSyncState(_currentSyncState);
    } catch (e) {
      final pendingCount = await _operationService.getPendingOperationsCount();
      _currentSyncState = SyncState.error(
        message: e.toString(),
        pendingOperations: pendingCount,
      );
      _syncStateController.add(_currentSyncState);

      await _storageService.saveSyncState(_currentSyncState);
    }
  }

  /// Получает список категорий (с учетом оффлайн режима)
  Future<List<Category>> getCategories() async {
    if (_isOfflineMode) {
      final offlineData = await _storageService.loadOfflineData();
      return offlineData?.categories ?? [];
    } else {
      try {
        // Используем интеллектуальную синхронизацию
        final offlineData = await _storageService.loadOfflineData();
        final syncedData = await _syncService.syncWithServer(
          lastSyncTime: offlineData?.lastUpdated,
        );

        return syncedData.categories;
      } catch (e) {
        // Fallback to offline data
        _isOfflineMode = true;
        final offlineData = await _storageService.loadOfflineData();
        return offlineData?.categories ?? [];
      }
    }
  }

  /// Получает список фраз (с учетом оффлайн режима)
  Future<List<Statement>> getStatements() async {
    if (_isOfflineMode) {
      final offlineData = await _storageService.loadOfflineData();
      return offlineData?.statements ?? [];
    } else {
      try {
        // Используем интеллектуальную синхронизацию
        final offlineData = await _storageService.loadOfflineData();
        final syncedData = await _syncService.syncWithServer(
          lastSyncTime: offlineData?.lastUpdated,
        );

        return syncedData.statements;
      } catch (e) {
        // Fallback to offline data
        _isOfflineMode = true;
        final offlineData = await _storageService.loadOfflineData();
        return offlineData?.statements ?? [];
      }
    }
  }

  /// Создает фразу (с учетом оффлайн режима)
  Future<Statement> createStatement(String title, String categoryId) async {
    if (_isOfflineMode) {
      // Добавляем операцию в очередь
      await _operationService.addCreateStatementOperation(
        title: title,
        categoryId: categoryId,
      );

      // Создаем временную фразу для локального отображения
      final tempStatement = Statement(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        userId: '', // Будет заполнен при синхронизации
        categoryId: categoryId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Обновляем локальные данные
      await _addStatementToOfflineData(tempStatement);

      // Обновляем состояние
      final pendingCount = await _operationService.getPendingOperationsCount();
      _currentSyncState =
          _currentSyncState.copyWith(pendingOperations: pendingCount);
      _syncStateController.add(_currentSyncState);
      await _storageService.saveSyncState(_currentSyncState);

      return tempStatement;
    } else {
      try {
        final statement = await _dataService.createStatement(title, categoryId);

        // Сохраняем в оффлайн данные
        await _addStatementToOfflineData(statement);

        return statement;
      } catch (e) {
        throw e;
      }
    }
  }

  /// Обновляет фразу (с учетом оффлайн режима)
  Future<Statement> updateStatement(
    String id,
    String title,
    String categoryId,
  ) async {
    if (_isOfflineMode) {
      // Добавляем операцию в очередь
      await _operationService.addUpdateStatementOperation(
        statementId: id,
        title: title,
        categoryId: categoryId,
      );

      // Обновляем локальные данные
      final updatedStatement = await _updateStatementInOfflineData(
        id,
        title,
        categoryId,
      );

      // Обновляем состояние
      final pendingCount = await _operationService.getPendingOperationsCount();
      _currentSyncState =
          _currentSyncState.copyWith(pendingOperations: pendingCount);
      _syncStateController.add(_currentSyncState);
      await _storageService.saveSyncState(_currentSyncState);

      return updatedStatement;
    } else {
      try {
        final statement =
            await _dataService.updateStatement(id, title, categoryId);

        // Обновляем в оффлайн данных
        await _updateStatementInOfflineData(id, title, categoryId);

        return statement;
      } catch (e) {
        throw e;
      }
    }
  }

  /// Удаляет фразу (с учетом оффлайн режима)
  Future<void> deleteStatement(String id) async {
    if (_isOfflineMode) {
      // Добавляем операцию в очередь
      await _operationService.addDeleteStatementOperation(statementId: id);

      // Удаляем из локальных данных
      await _removeStatementFromOfflineData(id);

      // Обновляем состояние
      final pendingCount = await _operationService.getPendingOperationsCount();
      _currentSyncState =
          _currentSyncState.copyWith(pendingOperations: pendingCount);
      _syncStateController.add(_currentSyncState);
      await _storageService.saveSyncState(_currentSyncState);
    } else {
      try {
        await _dataService.deleteStatement(id);

        // Удаляем из оффлайн данных
        await _removeStatementFromOfflineData(id);
      } catch (e) {
        throw e;
      }
    }
  }

  /// Создает категорию (с учетом оффлайн режима)
  Future<Category> createCategory(String title) async {
    if (_isOfflineMode) {
      // Добавляем операцию в очередь
      await _operationService.addCreateCategoryOperation(title: title);

      // Создаем временную категорию для локального отображения
      final tempCategory = Category(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        userId: '', // Будет заполнен при синхронизации
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Обновляем локальные данные
      await _addCategoryToOfflineData(tempCategory);

      // Обновляем состояние
      final pendingCount = await _operationService.getPendingOperationsCount();
      _currentSyncState =
          _currentSyncState.copyWith(pendingOperations: pendingCount);
      _syncStateController.add(_currentSyncState);
      await _storageService.saveSyncState(_currentSyncState);

      return tempCategory;
    } else {
      try {
        final category = await _dataService.createCategory(title);

        // Сохраняем в оффлайн данные
        await _addCategoryToOfflineData(category);

        return category;
      } catch (e) {
        throw e;
      }
    }
  }

  /// Обновляет категорию (с учетом оффлайн режима)
  Future<Category> updateCategory(String id, String title) async {
    if (_isOfflineMode) {
      // Добавляем операцию в очередь
      await _operationService.addUpdateCategoryOperation(
        categoryId: id,
        title: title,
      );

      // Обновляем локальные данные
      final updatedCategory = await _updateCategoryInOfflineData(id, title);

      // Обновляем состояние
      final pendingCount = await _operationService.getPendingOperationsCount();
      _currentSyncState =
          _currentSyncState.copyWith(pendingOperations: pendingCount);
      _syncStateController.add(_currentSyncState);
      await _storageService.saveSyncState(_currentSyncState);

      return updatedCategory;
    } else {
      try {
        final category = await _dataService.updateCategory(id, title);

        // Обновляем в оффлайн данных
        await _updateCategoryInOfflineData(id, title);

        return category;
      } catch (e) {
        throw e;
      }
    }
  }

  /// Удаляет категорию (с учетом оффлайн режима)
  Future<void> deleteCategory(String id) async {
    if (_isOfflineMode) {
      // Добавляем операцию в очередь
      await _operationService.addDeleteCategoryOperation(categoryId: id);

      // Удаляем из локальных данных
      await _removeCategoryFromOfflineData(id);

      // Обновляем состояние
      final pendingCount = await _operationService.getPendingOperationsCount();
      _currentSyncState =
          _currentSyncState.copyWith(pendingOperations: pendingCount);
      _syncStateController.add(_currentSyncState);
      await _storageService.saveSyncState(_currentSyncState);
    } else {
      try {
        await _dataService.deleteCategory(id);

        // Удаляем из оффлайн данных
        await _removeCategoryFromOfflineData(id);
      } catch (e) {
        throw e;
      }
    }
  }

  /// Вспомогательные методы для работы с оффлайн данными

  Future<void> _addStatementToOfflineData(Statement statement) async {
    final offlineData =
        await _storageService.loadOfflineData() ?? OfflineData.empty();
    final updatedStatements = [...offlineData.statements, statement];
    await _storageService.saveOfflineData(
      offlineData.copyWith(
        statements: updatedStatements,
        lastUpdated: DateTime.now(),
      ),
    );
  }

  Future<Statement> _updateStatementInOfflineData(
    String id,
    String title,
    String categoryId,
  ) async {
    final offlineData =
        await _storageService.loadOfflineData() ?? OfflineData.empty();
    final updatedStatements = offlineData.statements.map((stmt) {
      if (stmt.id == id) {
        return Statement(
          id: stmt.id,
          title: title,
          userId: stmt.userId,
          categoryId: categoryId,
          createdAt: stmt.createdAt,
          updatedAt: DateTime.now(),
        );
      }
      return stmt;
    }).toList();

    await _storageService.saveOfflineData(
      offlineData.copyWith(
        statements: updatedStatements,
        lastUpdated: DateTime.now(),
      ),
    );

    return updatedStatements.firstWhere((stmt) => stmt.id == id);
  }

  Future<void> _removeStatementFromOfflineData(String id) async {
    final offlineData =
        await _storageService.loadOfflineData() ?? OfflineData.empty();
    final updatedStatements =
        offlineData.statements.where((stmt) => stmt.id != id).toList();
    await _storageService.saveOfflineData(
      offlineData.copyWith(
        statements: updatedStatements,
        lastUpdated: DateTime.now(),
      ),
    );
  }

  Future<void> _addCategoryToOfflineData(Category category) async {
    final offlineData =
        await _storageService.loadOfflineData() ?? OfflineData.empty();
    final updatedCategories = [...offlineData.categories, category];
    await _storageService.saveOfflineData(
      offlineData.copyWith(
        categories: updatedCategories,
        lastUpdated: DateTime.now(),
      ),
    );
  }

  Future<Category> _updateCategoryInOfflineData(String id, String title) async {
    final offlineData =
        await _storageService.loadOfflineData() ?? OfflineData.empty();
    final updatedCategories = offlineData.categories.map((cat) {
      if (cat.id == id) {
        return Category(
          id: cat.id,
          title: title,
          userId: cat.userId,
          createdAt: cat.createdAt,
          updatedAt: DateTime.now(),
        );
      }
      return cat;
    }).toList();

    await _storageService.saveOfflineData(
      offlineData.copyWith(
        categories: updatedCategories,
        lastUpdated: DateTime.now(),
      ),
    );

    return updatedCategories.firstWhere((cat) => cat.id == id);
  }

  Future<void> _removeCategoryFromOfflineData(String id) async {
    final offlineData =
        await _storageService.loadOfflineData() ?? OfflineData.empty();
    final updatedCategories =
        offlineData.categories.where((cat) => cat.id != id).toList();
    await _storageService.saveOfflineData(
      offlineData.copyWith(
        categories: updatedCategories,
        lastUpdated: DateTime.now(),
      ),
    );
  }

  /// Принудительная синхронизация
  Future<void> forceSync() async {
    if (_isOfflineMode) {
      return;
    }

    _currentSyncState = _currentSyncState.copyWith(status: SyncStatus.syncing);
    _syncStateController.add(_currentSyncState);

    try {
      await _syncOnConnectionRestore();
    } catch (e) {}
  }

  /// Очищает все оффлайн данные
  Future<void> clearOfflineData() async {
    await _storageService.clearAllData();
    _currentSyncState = SyncState.initial();
    _syncStateController.add(_currentSyncState);
  }

  /// Освобождает ресурсы
  void dispose() {
    _connectivitySubscription?.cancel();
    _syncStateController.close();
  }
}
