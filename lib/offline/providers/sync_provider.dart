import 'package:flutter/foundation.dart';
import '../models/sync_state.dart';
import '../services/offline_manager.dart';

/// Провайдер для управления состоянием синхронизации
class SyncProvider extends ChangeNotifier {
  final OfflineManager _offlineManager;

  SyncState _syncState;

  SyncProvider(this._offlineManager)
      : _syncState = _offlineManager.currentSyncState {
    // Подписываемся на изменения состояния синхронизации
    _offlineManager.syncStateStream.listen((newState) {
      _syncState = newState;
      notifyListeners();
    });
  }

  /// Текущее состояние синхронизации
  SyncState get syncState => _syncState;

  /// Флаг оффлайн режима
  bool get isOfflineMode => _offlineManager.isOfflineMode;

  /// Количество ожидающих операций
  int get pendingOperations => _syncState.pendingOperations;

  /// Есть ли ожидающие операции
  bool get hasPendingOperations => _syncState.hasPendingOperations;

  /// Есть ли ошибка синхронизации
  bool get hasError => _syncState.hasError;

  /// Идет ли синхронизация
  bool get isSyncing => _syncState.isSyncing;

  /// Синхронизировано ли состояние
  bool get isSynced => _syncState.isSynced;

  /// Принудительная синхронизация
  Future<void> forceSync() async {
    await _offlineManager.forceSync();
  }

  /// Очищает все оффлайн данные
  Future<void> clearOfflineData() async {
    await _offlineManager.clearOfflineData();
  }

  /// Освобождает ресурсы
  @override
  void dispose() {
    _offlineManager.dispose();
    super.dispose();
  }
}
