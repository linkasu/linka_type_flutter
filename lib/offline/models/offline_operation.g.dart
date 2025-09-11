// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_operation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OfflineOperation _$OfflineOperationFromJson(Map<String, dynamic> json) =>
    OfflineOperation(
      id: json['id'] as String,
      type: $enumDecode(_$OfflineOperationTypeEnumMap, json['type']),
      entityId: json['entityId'] as String,
      data: json['data'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      synced: json['synced'] as bool? ?? false,
      lastSyncAttempt: json['lastSyncAttempt'] == null
          ? null
          : DateTime.parse(json['lastSyncAttempt'] as String),
      lastError: json['lastError'] as String?,
    );

Map<String, dynamic> _$OfflineOperationToJson(OfflineOperation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$OfflineOperationTypeEnumMap[instance.type]!,
      'entityId': instance.entityId,
      'data': instance.data,
      'createdAt': instance.createdAt.toIso8601String(),
      'synced': instance.synced,
      'lastSyncAttempt': instance.lastSyncAttempt?.toIso8601String(),
      'lastError': instance.lastError,
    };

const _$OfflineOperationTypeEnumMap = {
  OfflineOperationType.createStatement: 'createStatement',
  OfflineOperationType.updateStatement: 'updateStatement',
  OfflineOperationType.deleteStatement: 'deleteStatement',
  OfflineOperationType.createCategory: 'createCategory',
  OfflineOperationType.updateCategory: 'updateCategory',
  OfflineOperationType.deleteCategory: 'deleteCategory',
};
