// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateStatementRequest _$CreateStatementRequestFromJson(
  Map<String, dynamic> json,
) => CreateStatementRequest(
  title: json['title'] as String,
  categoryId: json['categoryId'] as String,
);

Map<String, dynamic> _$CreateStatementRequestToJson(
  CreateStatementRequest instance,
) => <String, dynamic>{
  'title': instance.title,
  'categoryId': instance.categoryId,
};

UpdateStatementRequest _$UpdateStatementRequestFromJson(
  Map<String, dynamic> json,
) => UpdateStatementRequest(
  title: json['title'] as String,
  categoryId: json['categoryId'] as String,
);

Map<String, dynamic> _$UpdateStatementRequestToJson(
  UpdateStatementRequest instance,
) => <String, dynamic>{
  'title': instance.title,
  'categoryId': instance.categoryId,
};

CreateCategoryRequest _$CreateCategoryRequestFromJson(
  Map<String, dynamic> json,
) => CreateCategoryRequest(title: json['title'] as String);

Map<String, dynamic> _$CreateCategoryRequestToJson(
  CreateCategoryRequest instance,
) => <String, dynamic>{'title': instance.title};

UpdateCategoryRequest _$UpdateCategoryRequestFromJson(
  Map<String, dynamic> json,
) => UpdateCategoryRequest(title: json['title'] as String);

Map<String, dynamic> _$UpdateCategoryRequestToJson(
  UpdateCategoryRequest instance,
) => <String, dynamic>{'title': instance.title};
