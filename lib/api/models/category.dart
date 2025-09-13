import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

@JsonSerializable()
class Category {
  @JsonKey(fromJson: _stringFromJson)
  final String id;
  @JsonKey(fromJson: _stringFromJson)
  final String title;
  @JsonKey(name: 'userId', fromJson: _stringFromJson)
  final String userId;
  @JsonKey(name: 'createdAt', fromJson: _dateTimeFromJson)
  final DateTime createdAt;
  @JsonKey(name: 'updatedAt', fromJson: _dateTimeFromJson)
  final DateTime updatedAt;

  Category({
    required this.id,
    required this.title,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryToJson(this);

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
