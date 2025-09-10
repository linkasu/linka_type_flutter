// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocalCategory _$LocalCategoryFromJson(Map<String, dynamic> json) =>
    LocalCategory(
      id: json['id'] as String?,
      title: json['title'] as String,
      userId: json['userId'] as String,
      createdAt: (json['createdAt'] as num).toInt(),
      updatedAt: (json['updatedAt'] as num).toInt(),
      syncStatus: $enumDecode(_$SyncStatusEnumMap, json['syncStatus']),
      localId: json['localId'] as String?,
    );

Map<String, dynamic> _$LocalCategoryToJson(LocalCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'userId': instance.userId,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'syncStatus': _$SyncStatusEnumMap[instance.syncStatus]!,
      'localId': instance.localId,
    };

const _$SyncStatusEnumMap = {
  SyncStatus.synced: 'synced',
  SyncStatus.pending: 'pending',
  SyncStatus.deleted: 'deleted',
};
