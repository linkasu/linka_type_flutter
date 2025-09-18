import 'package:json_annotation/json_annotation.dart';

part 'github_release.g.dart';

@JsonSerializable()
class GitHubRelease {
  final String name;
  @JsonKey(name: 'tag_name')
  final String tagName;
  final String body;
  @JsonKey(name: 'html_url')
  final String htmlUrl;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'published_at')
  final DateTime publishedAt;
  final bool draft;
  final bool prerelease;
  final List<GitHubAsset> assets;

  const GitHubRelease({
    required this.name,
    required this.tagName,
    required this.body,
    required this.htmlUrl,
    required this.createdAt,
    required this.publishedAt,
    required this.draft,
    required this.prerelease,
    required this.assets,
  });

  factory GitHubRelease.fromJson(Map<String, dynamic> json) =>
      _$GitHubReleaseFromJson(json);

  Map<String, dynamic> toJson() => _$GitHubReleaseToJson(this);

  /// Проверяет, является ли релиз стабильным (не draft и не prerelease)
  bool get isStable => !draft && !prerelease;

  /// Проверяет, является ли релиз новее указанной версии
  bool isNewerThan(String version) {
    return _compareVersions(tagName, version) > 0;
  }

  /// Сравнивает версии в формате semver
  int _compareVersions(String version1, String version2) {
    final v1Parts = _parseVersion(version1);
    final v2Parts = _parseVersion(version2);

    for (int i = 0; i < 3; i++) {
      if (v1Parts[i] > v2Parts[i]) return 1;
      if (v1Parts[i] < v2Parts[i]) return -1;
    }
    return 0;
  }

  /// Парсит версию в массив чисел [major, minor, patch]
  List<int> _parseVersion(String version) {
    final cleanVersion = version.replaceAll(RegExp(r'[^0-9.]'), '');
    final parts = cleanVersion.split('.');

    return [
      int.tryParse(parts.isNotEmpty ? parts[0] : '0') ?? 0,
      int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
      int.tryParse(parts.length > 2 ? parts[2] : '0') ?? 0,
    ];
  }
}

@JsonSerializable()
class GitHubAsset {
  final String name;
  @JsonKey(name: 'browser_download_url')
  final String browserDownloadUrl;
  final int size;
  @JsonKey(name: 'content_type')
  final String contentType;

  const GitHubAsset({
    required this.name,
    required this.browserDownloadUrl,
    required this.size,
    required this.contentType,
  });

  factory GitHubAsset.fromJson(Map<String, dynamic> json) =>
      _$GitHubAssetFromJson(json);

  Map<String, dynamic> toJson() => _$GitHubAssetToJson(this);
}
