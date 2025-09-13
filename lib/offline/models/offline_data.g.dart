// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OfflineData _$OfflineDataFromJson(Map<String, dynamic> json) => OfflineData(
      categories: (json['categories'] as List<dynamic>)
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList(),
      statements: (json['statements'] as List<dynamic>)
          .map((e) => Statement.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastUpdated: OfflineData._dateTimeFromJson(json['lastUpdated']),
      version: (json['version'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$OfflineDataToJson(OfflineData instance) =>
    <String, dynamic>{
      'categories': instance.categories,
      'statements': instance.statements,
      'lastUpdated': OfflineData._dateTimeToJson(instance.lastUpdated),
      'version': instance.version,
    };
