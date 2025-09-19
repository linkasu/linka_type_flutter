import 'dart:async';
import '../api/api.dart';
import '../offline/services/offline_manager.dart';
import '../offline/models/sync_state.dart';

class DataRefreshService {
  // final DataService _dataService = DataService();
  final OfflineManager _offlineManager;

  Timer? _refreshTimer;
  bool _isRefreshing = false;

  // Текущая выбранная категория для мониторинга
  Category? _monitoredCategory;

  // Callbacks для уведомления об обновлениях
  Function(List<Category>)? _onCategoriesUpdated;
  Function(List<Statement>)? _onStatementsUpdated;
  Function(Category?, List<Statement>)? _onCategoryStatementsUpdated;
  // Function(bool)? _onOfflineModeChanged;
  Function(SyncState)? _onSyncStateChanged;

  DataRefreshService(this._offlineManager) {
    // Подписываемся на изменения состояния синхронизации
    _offlineManager.syncStateStream.listen((syncState) {
      _onSyncStateChanged?.call(syncState);
    });
  }

  void setCallbacks({
    Function(List<Category>)? onCategoriesUpdated,
    Function(List<Statement>)? onStatementsUpdated,
    Function(Category?, List<Statement>)? onCategoryStatementsUpdated,
    Function(bool)? onOfflineModeChanged,
    Function(SyncState)? onSyncStateChanged,
  }) {
    _onCategoriesUpdated = onCategoriesUpdated;
    _onStatementsUpdated = onStatementsUpdated;
    _onCategoryStatementsUpdated = onCategoryStatementsUpdated;
    // _onOfflineModeChanged = onOfflineModeChanged;
    _onSyncStateChanged = onSyncStateChanged;
  }

  /// Запускает периодическую проверку данных каждые 5 секунд
  void startPeriodicRefresh() {
    if (_refreshTimer != null && _refreshTimer!.isActive) {
      return; // Уже запущено
    }

    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkForUpdates();
    });

    print('DataRefreshService: Started periodic refresh every 5 seconds');
  }

  /// Останавливает периодическую проверку
  void stopPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    _isRefreshing = false;
    print('DataRefreshService: Stopped periodic refresh');
  }

  /// Принудительная проверка обновлений
  Future<void> forceRefresh() async {
    await _checkForUpdates();
  }

  Future<void> _checkForUpdates() async {
    if (_isRefreshing) return; // Предотвращаем одновременные запросы

    _isRefreshing = true;

    try {
      // Проверяем обновления категорий
      await _checkCategoriesUpdate();

      // Проверяем обновления фраз (всех или для выбранной категории)
      await _checkStatementsUpdate();

      // Проверяем обновления для отслеживаемой категории
      await _checkMonitoredCategory();
    } catch (e) {
      print('DataRefreshService: Error during refresh: $e');
      print('DataRefreshService: Stack trace: ${StackTrace.current}');
      // Не показываем ошибки пользователю, так как это фоновая проверка
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> _checkCategoriesUpdate() async {
    try {
      final newCategories = await _offlineManager.getCategories();

      if (_onCategoriesUpdated != null) {
        _onCategoriesUpdated!(newCategories);
      }
    } catch (e) {
      print('DataRefreshService: Error checking categories: $e');
    }
  }

  Future<void> _checkStatementsUpdate() async {
    try {
      final newStatements = await _offlineManager.getStatements();

      if (_onStatementsUpdated != null) {
        _onStatementsUpdated!(newStatements);
      }
    } catch (e) {
      print('DataRefreshService: Error checking statements: $e');
    }
  }

  /// Устанавливает категорию для мониторинга
  void setMonitoredCategory(Category? category) {
    _monitoredCategory = category;
    if (category != null) {
      print('DataRefreshService: Now monitoring category "${category.title}"');
    } else {
      print('DataRefreshService: Stopped monitoring category');
    }
  }

  /// Проверяет обновления для конкретной категории
  Future<void> checkCategoryStatements(Category category) async {
    try {
      // Получаем фразы только для выбранной категории
      final statements = await _offlineManager.getStatements();

      // Фильтруем по категории
      final categoryStatements =
          statements.where((stmt) => stmt.categoryId == category.id).toList();

      if (_onCategoryStatementsUpdated != null) {
        _onCategoryStatementsUpdated!(category, categoryStatements);
      }
    } catch (e) {
      print('DataRefreshService: Error checking category statements: $e');
    }
  }

  /// Проверяет обновления для отслеживаемой категории (вызывается автоматически каждые 5 сек)
  Future<void> _checkMonitoredCategory() async {
    if (_monitoredCategory != null) {
      await checkCategoryStatements(_monitoredCategory!);
    }
  }

  void dispose() {
    stopPeriodicRefresh();
  }
}
