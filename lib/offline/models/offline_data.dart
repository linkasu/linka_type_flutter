import 'package:json_annotation/json_annotation.dart';
import '../../api/models/category.dart';
import '../../api/models/statement.dart';

part 'offline_data.g.dart';

/// Модель для хранения оффлайн данных
@JsonSerializable()
class OfflineData {
  /// Список категорий
  final List<Category> categories;

  /// Список фраз
  final List<Statement> statements;

  /// Время последнего обновления данных
  final DateTime lastUpdated;

  /// Версия данных для оптимизации синхронизации
  final int version;

  OfflineData({
    required this.categories,
    required this.statements,
    required this.lastUpdated,
    this.version = 1,
  });

  factory OfflineData.fromJson(Map<String, dynamic> json) =>
      _$OfflineDataFromJson(json);

  Map<String, dynamic> toJson() => _$OfflineDataToJson(this);

  /// Создает пустой контейнер данных
  factory OfflineData.empty() => OfflineData(
        categories: [],
        statements: [],
        lastUpdated: DateTime.now(),
        version: 1,
      );

  /// Обновляет данные новыми значениями
  OfflineData copyWith({
    List<Category>? categories,
    List<Statement>? statements,
    DateTime? lastUpdated,
    int? version,
  }) {
    return OfflineData(
      categories: categories ?? this.categories,
      statements: statements ?? this.statements,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      version: version ?? this.version,
    );
  }
}
