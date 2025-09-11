import 'package:json_annotation/json_annotation.dart';

part 'sync_state.g.dart';

/// Состояние синхронизации
enum SyncStatus {
  /// Синхронизировано
  synced,

  /// Синхронизация в процессе
  syncing,

  /// Ошибка синхронизации
  error,

  /// Оффлайн режим
  offline,
}

/// Модель состояния синхронизации
@JsonSerializable()
class SyncState {
  /// Текущее состояние синхронизации
  final SyncStatus status;

  /// Время последней успешной синхронизации
  final DateTime? lastSyncTime;

  /// Сообщение об ошибке (если есть)
  final String? errorMessage;

  /// Количество ожидающих операций
  final int pendingOperations;

  /// Флаг наличия интернет-соединения
  final bool isOnline;

  SyncState({
    required this.status,
    this.lastSyncTime,
    this.errorMessage,
    this.pendingOperations = 0,
    this.isOnline = true,
  });

  factory SyncState.fromJson(Map<String, dynamic> json) =>
      _$SyncStateFromJson(json);

  Map<String, dynamic> toJson() => _$SyncStateToJson(this);

  /// Создает начальное состояние
  factory SyncState.initial() => SyncState(
        status: SyncStatus.offline,
        isOnline: false,
      );

  /// Создает состояние успешной синхронизации
  factory SyncState.synced({required int pendingOperations}) => SyncState(
        status: SyncStatus.synced,
        lastSyncTime: DateTime.now(),
        pendingOperations: pendingOperations,
        isOnline: true,
      );

  /// Создает состояние ошибки синхронизации
  factory SyncState.error({
    required String message,
    required int pendingOperations,
  }) =>
      SyncState(
        status: SyncStatus.error,
        errorMessage: message,
        pendingOperations: pendingOperations,
        isOnline: true,
      );

  /// Создает оффлайн состояние
  factory SyncState.offline({required int pendingOperations}) => SyncState(
        status: SyncStatus.offline,
        pendingOperations: pendingOperations,
        isOnline: false,
      );

  /// Создает состояние активной синхронизации
  factory SyncState.syncing({required int pendingOperations}) => SyncState(
        status: SyncStatus.syncing,
        pendingOperations: pendingOperations,
        isOnline: true,
      );

  /// Создает копию с обновленными полями
  SyncState copyWith({
    SyncStatus? status,
    DateTime? lastSyncTime,
    String? errorMessage,
    int? pendingOperations,
    bool? isOnline,
  }) {
    return SyncState(
      status: status ?? this.status,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      errorMessage: errorMessage ?? this.errorMessage,
      pendingOperations: pendingOperations ?? this.pendingOperations,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  /// Проверяет, находится ли система в синхронизированном состоянии
  bool get isSynced => status == SyncStatus.synced;

  /// Проверяет, есть ли ошибки синхронизации
  bool get hasError => status == SyncStatus.error;

  /// Проверяет, идет ли синхронизация
  bool get isSyncing => status == SyncStatus.syncing;

  /// Проверяет, работает ли система оффлайн
  bool get isOffline => status == SyncStatus.offline;

  /// Проверяет, есть ли ожидающие операции
  bool get hasPendingOperations => pendingOperations > 0;
}
