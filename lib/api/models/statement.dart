import 'package:json_annotation/json_annotation.dart';

part 'statement.g.dart';

@JsonSerializable()
class Statement {
  final String id;
  @JsonKey(name: 'text')
  final String title;
  @JsonKey(name: 'userId')
  final String userId;
  @JsonKey(name: 'categoryId')
  final String categoryId;
  @JsonKey(name: 'createdAt')
  final DateTime createdAt;
  @JsonKey(name: 'updatedAt')
  final DateTime updatedAt;

  Statement({
    required this.id,
    required this.title,
    required this.userId,
    required this.categoryId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Statement.fromJson(Map<String, dynamic> json) =>
      _$StatementFromJson(json);
  Map<String, dynamic> toJson() => _$StatementToJson(this);
}
