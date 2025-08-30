import 'package:json_annotation/json_annotation.dart';

part 'data_models.g.dart';

@JsonSerializable()
class CreateStatementRequest {
  final String title;
  @JsonKey(name: 'category_id')
  final String categoryId;

  CreateStatementRequest({
    required this.title,
    required this.categoryId,
  });

  factory CreateStatementRequest.fromJson(Map<String, dynamic> json) => _$CreateStatementRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateStatementRequestToJson(this);
}

@JsonSerializable()
class UpdateStatementRequest {
  final String title;
  @JsonKey(name: 'category_id')
  final String categoryId;

  UpdateStatementRequest({
    required this.title,
    required this.categoryId,
  });

  factory UpdateStatementRequest.fromJson(Map<String, dynamic> json) => _$UpdateStatementRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateStatementRequestToJson(this);
}

@JsonSerializable()
class CreateCategoryRequest {
  final String title;

  CreateCategoryRequest({
    required this.title,
  });

  factory CreateCategoryRequest.fromJson(Map<String, dynamic> json) => _$CreateCategoryRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateCategoryRequestToJson(this);
}

@JsonSerializable()
class UpdateCategoryRequest {
  final String title;

  UpdateCategoryRequest({
    required this.title,
  });

  factory UpdateCategoryRequest.fromJson(Map<String, dynamic> json) => _$UpdateCategoryRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateCategoryRequestToJson(this);
}
