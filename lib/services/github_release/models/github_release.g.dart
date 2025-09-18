// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_release.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GitHubRelease _$GitHubReleaseFromJson(Map<String, dynamic> json) =>
    GitHubRelease(
      name: json['name'] as String,
      tagName: json['tag_name'] as String,
      body: json['body'] as String,
      htmlUrl: json['html_url'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      publishedAt: DateTime.parse(json['published_at'] as String),
      draft: json['draft'] as bool,
      prerelease: json['prerelease'] as bool,
      assets: (json['assets'] as List<dynamic>)
          .map((e) => GitHubAsset.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GitHubReleaseToJson(GitHubRelease instance) =>
    <String, dynamic>{
      'name': instance.name,
      'tag_name': instance.tagName,
      'body': instance.body,
      'html_url': instance.htmlUrl,
      'created_at': instance.createdAt.toIso8601String(),
      'published_at': instance.publishedAt.toIso8601String(),
      'draft': instance.draft,
      'prerelease': instance.prerelease,
      'assets': instance.assets,
    };

GitHubAsset _$GitHubAssetFromJson(Map<String, dynamic> json) => GitHubAsset(
      name: json['name'] as String,
      browserDownloadUrl: json['browser_download_url'] as String,
      size: (json['size'] as num).toInt(),
      contentType: json['content_type'] as String,
    );

Map<String, dynamic> _$GitHubAssetToJson(GitHubAsset instance) =>
    <String, dynamic>{
      'name': instance.name,
      'browser_download_url': instance.browserDownloadUrl,
      'size': instance.size,
      'content_type': instance.contentType,
    };
