import 'package:json_annotation/json_annotation.dart';

part 'statement.g.dart';

@JsonSerializable()
class Statement {
  @JsonKey(fromJson: _stringFromJson)
  final String id;
  @JsonKey(name: 'title', fromJson: _stringFromJson)
  final String title;
  @JsonKey(name: 'userId', fromJson: _stringFromJson)
  final String userId;
  @JsonKey(name: 'categoryId', fromJson: _stringFromJson)
  final String categoryId;
  @JsonKey(name: 'createdAt', fromJson: _dateTimeFromJson)
  final DateTime createdAt;
  @JsonKey(name: 'updatedAt', fromJson: _dateTimeFromJson)
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

  /// Helper функции для безопасного парсинга
  static String _stringFromJson(dynamic json) {
    if (json == null) return '';
    if (json is String) return json;
    return json.toString();
  }

  static DateTime _dateTimeFromJson(dynamic json) {
    if (json == null) return DateTime.now();
    if (json is String) return DateTime.parse(json);
    return DateTime.now();
  }
}
