// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Statement _$StatementFromJson(Map<String, dynamic> json) => Statement(
  id: json['id'] as String,
  title: json['text'] as String,
  userId: json['userId'] as String,
  categoryId: json['categoryId'] as String,
);

Map<String, dynamic> _$StatementToJson(Statement instance) => <String, dynamic>{
  'id': instance.id,
  'text': instance.title,
  'userId': instance.userId,
  'categoryId': instance.categoryId,
};
