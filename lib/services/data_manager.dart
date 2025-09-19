import '../api/models/statement.dart';
import '../api/models/category.dart';
import '../api/services/data_service.dart';
import '../offline/services/offline_manager.dart';
import '../offline/services/json_storage_service.dart';
import '../offline/services/offline_operation_service.dart';
import '../offline/models/sync_state.dart';

/// Единый менеджер данных, обеспечивающий прозрачную работу в онлайн/оффлайн режимах
class DataManager {
  // final DataService _dataService;
  late final OfflineManager _offlineManager;

  DataManager._(DataService dataService);

  /// Создает и инициализирует DataManager
  static Future<DataManager> create(DataService dataService) async {
    final manager = DataManager._(dataService);

    // Инициализируем сервисы оффлайн функциональности
    final storageService = JsonStorageService();
    final operationService =
        OfflineOperationService(dataService, storageService);
    manager._offlineManager =
        OfflineManager(dataService, storageService, operationService);

    return manager;
  }

  /// Получает OfflineManager для доступа к оффлайн функциональности
  OfflineManager get offlineManager => _offlineManager;

  /// Получает состояние синхронизации
  Stream<SyncState> get syncStateStream => _offlineManager.syncStateStream;
  SyncState get currentSyncState => _offlineManager.currentSyncState;
  bool get isOfflineMode => _offlineManager.isOfflineMode;

  // ===== МЕТОДЫ РАБОТЫ С ФРАЗАМИ =====

  /// Получает список всех фраз
  Future<List<Statement>> getStatements() => _offlineManager.getStatements();

  /// Создает новую фразу
  Future<Statement> createStatement(String title, String categoryId) =>
      _offlineManager.createStatement(title, categoryId);

  /// Обновляет фразу
  Future<Statement> updateStatement(
          String id, String title, String categoryId) =>
      _offlineManager.updateStatement(id, title, categoryId);

  /// Удаляет фразу
  Future<void> deleteStatement(String id) =>
      _offlineManager.deleteStatement(id);

  // ===== МЕТОДЫ РАБОТЫ С КАТЕГОРИЯМИ =====

  /// Получает список всех категорий
  Future<List<Category>> getCategories() => _offlineManager.getCategories();

  /// Создает новую категорию
  Future<Category> createCategory(String title) =>
      _offlineManager.createCategory(title);

  /// Обновляет категорию
  Future<Category> updateCategory(String id, String title) =>
      _offlineManager.updateCategory(id, title);

  /// Удаляет категорию
  Future<void> deleteCategory(String id) => _offlineManager.deleteCategory(id);

  // ===== ДОПОЛНИТЕЛЬНЫЕ МЕТОДЫ =====

  /// Принудительная синхронизация
  Future<void> forceSync() => _offlineManager.forceSync();

  /// Очищает все оффлайн данные
  Future<void> clearOfflineData() => _offlineManager.clearOfflineData();

  /// Освобождает ресурсы
  void dispose() => _offlineManager.dispose();
}
