// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Statement _$StatementFromJson(Map<String, dynamic> json) => Statement(
      id: Statement._stringFromJson(json['id']),
      title: Statement._stringFromJson(json['title']),
      userId: Statement._stringFromJson(json['userId']),
      categoryId: Statement._stringFromJson(json['categoryId']),
      createdAt: Statement._dateTimeFromJson(json['createdAt']),
      updatedAt: Statement._dateTimeFromJson(json['updatedAt']),
    );

Map<String, dynamic> _$StatementToJson(Statement instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'userId': instance.userId,
      'categoryId': instance.categoryId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
