import 'package:json_annotation/json_annotation.dart';
import 'sync_status.dart';

part 'local_category.g.dart';

@JsonSerializable()
class LocalCategory {
  final String? id; // Может быть null для новых записей до синхронизации
  final String title;
  final String userId;
  final int createdAt; // timestamp
  final int updatedAt; // timestamp
  final SyncStatus syncStatus;
  final String? localId; // Уникальный ID для оффлайн операций

  LocalCategory({
    this.id,
    required this.title,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    this.localId,
  });

  factory LocalCategory.fromJson(Map<String, dynamic> json) =>
      _$LocalCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$LocalCategoryToJson(this);

  // Конвертация из API модели в локальную
  factory LocalCategory.fromApi(dynamic apiCategory) {
    return LocalCategory(
      id: apiCategory.id,
      title: apiCategory.title,
      userId: apiCategory.userId,
      createdAt: apiCategory.createdAt.millisecondsSinceEpoch,
      updatedAt: apiCategory.updatedAt.millisecondsSinceEpoch,
      syncStatus: SyncStatus.synced,
      localId: null,
    );
  }

  // Конвертация в API модель для отправки на сервер
  Map<String, dynamic> toApiJson() {
    return {
      'title': title,
    };
  }

  // Создание копии с изменениями
  LocalCategory copyWith({
    String? id,
    String? title,
    String? userId,
    int? createdAt,
    int? updatedAt,
    SyncStatus? syncStatus,
    String? localId,
  }) {
    return LocalCategory(
      id: id ?? this.id,
      title: title ?? this.title,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      localId: localId ?? this.localId,
    );
  }
}
