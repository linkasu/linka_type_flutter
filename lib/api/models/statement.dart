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

  Statement({
    required this.id,
    required this.title,
    required this.userId,
    required this.categoryId,
  });

  factory Statement.fromJson(Map<String, dynamic> json) =>
      _$StatementFromJson(json);
  Map<String, dynamic> toJson() => _$StatementToJson(this);
}
