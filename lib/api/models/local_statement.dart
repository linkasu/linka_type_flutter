import 'package:json_annotation/json_annotation.dart';
import 'sync_status.dart';

part 'local_statement.g.dart';

@JsonSerializable()
class LocalStatement {
  final String? id; // Может быть null для новых записей до синхронизации
  final String title;
  final String userId;
  final String categoryId;
  final int createdAt; // timestamp
  final int updatedAt; // timestamp
  final SyncStatus syncStatus;
  final String? localId; // Уникальный ID для оффлайн операций

  LocalStatement({
    this.id,
    required this.title,
    required this.userId,
    required this.categoryId,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    this.localId,
  });

  factory LocalStatement.fromJson(Map<String, dynamic> json) =>
      _$LocalStatementFromJson(json);

  Map<String, dynamic> toJson() => _$LocalStatementToJson(this);

  // Конвертация из API модели в локальную
  factory LocalStatement.fromApi(dynamic apiStatement) {
    return LocalStatement(
      id: apiStatement.id,
      title: apiStatement.title,
      userId: apiStatement.userId,
      categoryId: apiStatement.categoryId,
      createdAt: apiStatement.createdAt.millisecondsSinceEpoch,
      updatedAt: apiStatement.updatedAt.millisecondsSinceEpoch,
      syncStatus: SyncStatus.synced,
      localId: null,
    );
  }

  // Конвертация в API модель для отправки на сервер
  Map<String, dynamic> toApiJson() {
    return {
      'title': title,
      'categoryId': categoryId,
    };
  }

  // Создание копии с изменениями
  LocalStatement copyWith({
    String? id,
    String? title,
    String? userId,
    String? categoryId,
    int? createdAt,
    int? updatedAt,
    SyncStatus? syncStatus,
    String? localId,
  }) {
    return LocalStatement(
      id: id ?? this.id,
      title: title ?? this.title,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      localId: localId ?? this.localId,
    );
  }
}
