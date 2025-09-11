import 'dart:async';
import '../../api/services/data_service.dart';
import '../../api/models/statement.dart';
import '../../api/models/category.dart';
import '../models/offline_operation.dart';
import 'json_storage_service.dart';

/// Сервис для управления оффлайн операциями
class OfflineOperationService {
  final DataService _dataService;
  final JsonStorageService _storageService;

  /// Максимальное количество попыток синхронизации операции
  static const int _maxRetryAttempts = 3;

  /// Таймаут между попытками в секундах
  static const int _retryDelaySeconds = 5;

  OfflineOperationService(this._dataService, this._storageService);

  /// Добавляет операцию создания фразы
  Future<void> addCreateStatementOperation({
    required String title,
    required String categoryId,
  }) async {
    final operation = OfflineOperation.createStatement(
      title: title,
      categoryId: categoryId,
    );
    await _storageService.addOfflineOperation(operation);
  }

  /// Добавляет операцию обновления фразы
  Future<void> addUpdateStatementOperation({
    required String statementId,
    required String title,
    required String categoryId,
  }) async {
    final operation = OfflineOperation.updateStatement(
      statementId: statementId,
      title: title,
      categoryId: categoryId,
    );
    await _storageService.addOfflineOperation(operation);
  }

  /// Добавляет операцию удаления фразы
  Future<void> addDeleteStatementOperation(
      {required String statementId}) async {
    final operation =
        OfflineOperation.deleteStatement(statementId: statementId);
    await _storageService.addOfflineOperation(operation);
  }

  /// Добавляет операцию создания категории
  Future<void> addCreateCategoryOperation({required String title}) async {
    final operation = OfflineOperation.createCategory(title: title);
    await _storageService.addOfflineOperation(operation);
  }

  /// Добавляет операцию обновления категории
  Future<void> addUpdateCategoryOperation({
    required String categoryId,
    required String title,
  }) async {
    final operation = OfflineOperation.updateCategory(
      categoryId: categoryId,
      title: title,
    );
    await _storageService.addOfflineOperation(operation);
  }

  /// Добавляет операцию удаления категории
  Future<void> addDeleteCategoryOperation({required String categoryId}) async {
    final operation = OfflineOperation.deleteCategory(categoryId: categoryId);
    await _storageService.addOfflineOperation(operation);
  }

  /// Синхронизирует все ожидающие операции
  Future<void> syncPendingOperations() async {
    final operations = await _storageService.loadOfflineOperations();
    final pendingOperations = operations.where((op) => !op.synced).toList();

    if (pendingOperations.isEmpty) {
      return;
    }

    for (final operation in pendingOperations) {
      await _syncOperation(operation);
    }
  }

  /// Синхронизирует одну операцию
  Future<void> _syncOperation(OfflineOperation operation) async {
    try {
      switch (operation.type) {
        case OfflineOperationType.createStatement:
          await _syncCreateStatement(operation);
          break;
        case OfflineOperationType.updateStatement:
          await _syncUpdateStatement(operation);
          break;
        case OfflineOperationType.deleteStatement:
          await _syncDeleteStatement(operation);
          break;
        case OfflineOperationType.createCategory:
          await _syncCreateCategory(operation);
          break;
        case OfflineOperationType.updateCategory:
          await _syncUpdateCategory(operation);
          break;
        case OfflineOperationType.deleteCategory:
          await _syncDeleteCategory(operation);
          break;
      }

      // Отмечаем операцию как синхронизированную
      await _storageService.updateOperationStatus(
        operationId: operation.id,
        synced: true,
      );
    } catch (e) {
      // Обновляем статус с ошибкой
      await _storageService.updateOperationStatus(
        operationId: operation.id,
        synced: false,
        error: e.toString(),
      );

      // Можно добавить логику повторных попыток здесь
      // await _retryOperation(operation);
    }
  }

  /// Синхронизирует операцию создания фразы
  Future<void> _syncCreateStatement(OfflineOperation operation) async {
    final title = operation.data['title'] as String;
    final categoryId = operation.data['categoryId'] as String;

    final statement = await _dataService.createStatement(title, categoryId);

    // Обновляем entityId операции с реальным ID созданной фразы
    final updatedOperation = operation.copyWith(entityId: statement.id);
    await _updateOperationEntityId(operation.id, statement.id);
  }

  /// Синхронизирует операцию обновления фразы
  Future<void> _syncUpdateStatement(OfflineOperation operation) async {
    final title = operation.data['title'] as String;
    final categoryId = operation.data['categoryId'] as String;

    await _dataService.updateStatement(
      operation.entityId,
      title,
      categoryId,
    );
  }

  /// Синхронизирует операцию удаления фразы
  Future<void> _syncDeleteStatement(OfflineOperation operation) async {
    await _dataService.deleteStatement(operation.entityId);
  }

  /// Синхронизирует операцию создания категории
  Future<void> _syncCreateCategory(OfflineOperation operation) async {
    final title = operation.data['title'] as String;

    final category = await _dataService.createCategory(title);

    // Обновляем entityId операции с реальным ID созданной категории
    await _updateOperationEntityId(operation.id, category.id);
  }

  /// Синхронизирует операцию обновления категории
  Future<void> _syncUpdateCategory(OfflineOperation operation) async {
    final title = operation.data['title'] as String;

    await _dataService.updateCategory(operation.entityId, title);
  }

  /// Синхронизирует операцию удаления категории
  Future<void> _syncDeleteCategory(OfflineOperation operation) async {
    await _dataService.deleteCategory(operation.entityId);
  }

  /// Обновляет entityId операции (для операций создания)
  Future<void> _updateOperationEntityId(
      String operationId, String newEntityId) async {
    final operations = await _storageService.loadOfflineOperations();
    final index = operations.indexWhere((op) => op.id == operationId);

    if (index != -1) {
      operations[index] = operations[index].copyWith(entityId: newEntityId);
      await _storageService.saveOfflineOperations(operations);
    }
  }

  /// Повторяет синхронизацию операции с задержкой
  Future<void> _retryOperation(OfflineOperation operation) async {
    if (operation.lastSyncAttempt != null) {
      final timeSinceLastAttempt =
          DateTime.now().difference(operation.lastSyncAttempt!);
      if (timeSinceLastAttempt.inSeconds < _retryDelaySeconds) {
        return; // Слишком рано для повторной попытки
      }
    }

    await Future.delayed(Duration(seconds: _retryDelaySeconds));
    await _syncOperation(operation);
  }

  /// Получает количество ожидающих операций
  Future<int> getPendingOperationsCount() async {
    final operations = await _storageService.loadOfflineOperations();
    return operations.where((op) => !op.synced).length;
  }

  /// Очищает успешно синхронизированные операции
  Future<void> clearSyncedOperations() async {
    final operations = await _storageService.loadOfflineOperations();
    final pendingOperations = operations.where((op) => !op.synced).toList();
    await _storageService.saveOfflineOperations(pendingOperations);
  }

  /// Получает все операции с ошибками
  Future<List<OfflineOperation>> getFailedOperations() async {
    final operations = await _storageService.loadOfflineOperations();
    return operations
        .where((op) => op.lastError != null && !op.synced)
        .toList();
  }
}
