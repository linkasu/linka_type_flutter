// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncState _$SyncStateFromJson(Map<String, dynamic> json) => SyncState(
      status: $enumDecode(_$SyncStatusEnumMap, json['status']),
      lastSyncTime: json['lastSyncTime'] == null
          ? null
          : DateTime.parse(json['lastSyncTime'] as String),
      errorMessage: json['errorMessage'] as String?,
      pendingOperations: (json['pendingOperations'] as num?)?.toInt() ?? 0,
      isOnline: json['isOnline'] as bool? ?? true,
    );

Map<String, dynamic> _$SyncStateToJson(SyncState instance) => <String, dynamic>{
      'status': _$SyncStatusEnumMap[instance.status]!,
      'lastSyncTime': instance.lastSyncTime?.toIso8601String(),
      'errorMessage': instance.errorMessage,
      'pendingOperations': instance.pendingOperations,
      'isOnline': instance.isOnline,
    };

const _$SyncStatusEnumMap = {
  SyncStatus.synced: 'synced',
  SyncStatus.syncing: 'syncing',
  SyncStatus.error: 'error',
  SyncStatus.offline: 'offline',
};
