import 'package:json_annotation/json_annotation.dart';

part 'offline_operation.g.dart';

/// Типы оффлайн операций
enum OfflineOperationType {
  createStatement,
  updateStatement,
  deleteStatement,
  createCategory,
  updateCategory,
  deleteCategory,
}

/// Модель для хранения отложенных оффлайн операций
@JsonSerializable()
class OfflineOperation {
  /// Уникальный ID операции
  final String id;

  /// Тип операции
  final OfflineOperationType type;

  /// ID сущности (statement или category)
  final String entityId;

  /// Данные операции (зависят от типа)
  final Map<String, dynamic> data;

  /// Время создания операции
  final DateTime createdAt;

  /// Флаг успешной синхронизации
  final bool synced;

  /// Время последней попытки синхронизации
  final DateTime? lastSyncAttempt;

  /// Сообщение об ошибке последней попытки
  final String? lastError;

  OfflineOperation({
    required this.id,
    required this.type,
    required this.entityId,
    required this.data,
    required this.createdAt,
    this.synced = false,
    this.lastSyncAttempt,
    this.lastError,
  });

  factory OfflineOperation.fromJson(Map<String, dynamic> json) =>
      _$OfflineOperationFromJson(json);

  Map<String, dynamic> toJson() => _$OfflineOperationToJson(this);

  /// Создает копию операции с обновленными полями
  OfflineOperation copyWith({
    String? id,
    OfflineOperationType? type,
    String? entityId,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    bool? synced,
    DateTime? lastSyncAttempt,
    String? lastError,
  }) {
    return OfflineOperation(
      id: id ?? this.id,
      type: type ?? this.type,
      entityId: entityId ?? this.entityId,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      synced: synced ?? this.synced,
      lastSyncAttempt: lastSyncAttempt ?? this.lastSyncAttempt,
      lastError: lastError ?? this.lastError,
    );
  }

  /// Создает операцию создания фразы
  static OfflineOperation createStatement({
    required String title,
    required String categoryId,
  }) {
    return OfflineOperation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: OfflineOperationType.createStatement,
      entityId: '', // Будет присвоен после создания на сервере
      data: {
        'title': title,
        'categoryId': categoryId,
      },
      createdAt: DateTime.now(),
    );
  }

  /// Создает операцию обновления фразы
  static OfflineOperation updateStatement({
    required String statementId,
    required String title,
    required String categoryId,
  }) {
    return OfflineOperation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: OfflineOperationType.updateStatement,
      entityId: statementId,
      data: {
        'title': title,
        'categoryId': categoryId,
      },
      createdAt: DateTime.now(),
    );
  }

  /// Создает операцию удаления фразы
  static OfflineOperation deleteStatement({required String statementId}) {
    return OfflineOperation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: OfflineOperationType.deleteStatement,
      entityId: statementId,
      data: {},
      createdAt: DateTime.now(),
    );
  }

  /// Создает операцию создания категории
  static OfflineOperation createCategory({required String title}) {
    return OfflineOperation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: OfflineOperationType.createCategory,
      entityId: '', // Будет присвоен после создания на сервере
      data: {'title': title},
      createdAt: DateTime.now(),
    );
  }

  /// Создает операцию обновления категории
  static OfflineOperation updateCategory({
    required String categoryId,
    required String title,
  }) {
    return OfflineOperation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: OfflineOperationType.updateCategory,
      entityId: categoryId,
      data: {'title': title},
      createdAt: DateTime.now(),
    );
  }

  /// Создает операцию удаления категории
  static OfflineOperation deleteCategory({required String categoryId}) {
    return OfflineOperation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: OfflineOperationType.deleteCategory,
      entityId: categoryId,
      data: {},
      createdAt: DateTime.now(),
    );
  }
}
