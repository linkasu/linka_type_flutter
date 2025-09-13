// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
      id: Category._stringFromJson(json['id']),
      title: Category._stringFromJson(json['title']),
      userId: Category._stringFromJson(json['userId']),
      createdAt: Category._dateTimeFromJson(json['createdAt']),
      updatedAt: Category._dateTimeFromJson(json['updatedAt']),
    );

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'userId': instance.userId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
