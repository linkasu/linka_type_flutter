// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Statement _$StatementFromJson(Map<String, dynamic> json) => Statement(
  id: json['id'] as String,
  title: json['title'] as String,
  userId: json['user_id'] as String,
  categoryId: json['category_id'] as String,
);

Map<String, dynamic> _$StatementToJson(Statement instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'user_id': instance.userId,
  'category_id': instance.categoryId,
};
