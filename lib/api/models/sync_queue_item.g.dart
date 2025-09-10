// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_queue_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncQueueItem _$SyncQueueItemFromJson(Map<String, dynamic> json) =>
    SyncQueueItem(
      id: (json['id'] as num?)?.toInt(),
      operation: $enumDecode(_$SyncOperationEnumMap, json['operation']),
      tableName: json['tableName'] as String,
      recordId: json['recordId'] as String,
      data: json['data'] as String?,
      createdAt: (json['createdAt'] as num).toInt(),
      retryCount: (json['retryCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$SyncQueueItemToJson(SyncQueueItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'operation': _$SyncOperationEnumMap[instance.operation]!,
      'tableName': instance.tableName,
      'recordId': instance.recordId,
      'data': instance.data,
      'createdAt': instance.createdAt,
      'retryCount': instance.retryCount,
    };

const _$SyncOperationEnumMap = {
  SyncOperation.create: 'create',
  SyncOperation.update: 'update',
  SyncOperation.delete: 'delete',
};
