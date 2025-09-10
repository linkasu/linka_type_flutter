import 'package:json_annotation/json_annotation.dart';

part 'sync_queue_item.g.dart';

enum SyncOperation { create, update, delete }

@JsonSerializable()
class SyncQueueItem {
  final int? id; // Автоинкрементный ID в базе
  final SyncOperation operation;
  final String tableName; // 'statements' или 'categories'
  final String recordId; // ID записи в локальной базе
  final String? data; // JSON данные для операции
  final int createdAt; // timestamp
  final int retryCount; // Количество попыток

  SyncQueueItem({
    this.id,
    required this.operation,
    required this.tableName,
    required this.recordId,
    this.data,
    required this.createdAt,
    this.retryCount = 0,
  });

  factory SyncQueueItem.fromJson(Map<String, dynamic> json) =>
      _$SyncQueueItemFromJson(json);

  Map<String, dynamic> toJson() => _$SyncQueueItemToJson(this);

  // Создание копии с изменениями
  SyncQueueItem copyWith({
    int? id,
    SyncOperation? operation,
    String? tableName,
    String? recordId,
    String? data,
    int? createdAt,
    int? retryCount,
  }) {
    return SyncQueueItem(
      id: id ?? this.id,
      operation: operation ?? this.operation,
      tableName: tableName ?? this.tableName,
      recordId: recordId ?? this.recordId,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
    );
  }
}
