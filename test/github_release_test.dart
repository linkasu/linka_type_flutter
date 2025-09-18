import 'package:flutter_test/flutter_test.dart';
import 'package:linka_type_flutter/services/github_release/models/github_release.dart';

void main() {
  group('GitHubRelease', () {
    test('should parse version correctly', () {
      final release = GitHubRelease(
        name: 'Test Release',
        tagName: '1.2.3',
        body: 'Test body',
        htmlUrl: 'https://github.com/test/repo/releases/tag/1.2.3',
        createdAt: DateTime.now(),
        publishedAt: DateTime.now(),
        draft: false,
        prerelease: false,
        assets: [],
      );

      expect(release.isNewerThan('1.0.0'), true);
      expect(release.isNewerThan('1.2.2'), true);
      expect(release.isNewerThan('1.2.3'), false);
      expect(release.isNewerThan('1.3.0'), false);
      expect(release.isNewerThan('2.0.0'), false);
    });

    test('should handle version with v prefix', () {
      final release = GitHubRelease(
        name: 'Test Release',
        tagName: 'v1.2.3',
        body: 'Test body',
        htmlUrl: 'https://github.com/test/repo/releases/tag/v1.2.3',
        createdAt: DateTime.now(),
        publishedAt: DateTime.now(),
        draft: false,
        prerelease: false,
        assets: [],
      );

      expect(release.isNewerThan('1.0.0'), true);
      expect(release.isNewerThan('1.2.2'), true);
      expect(release.isNewerThan('1.2.3'), false);
      expect(release.isNewerThan('1.3.0'), false);
    });

    test('should identify stable release', () {
      final stableRelease = GitHubRelease(
        name: 'Stable Release',
        tagName: '1.0.0',
        body: 'Stable release',
        htmlUrl: 'https://github.com/test/repo/releases/tag/1.0.0',
        createdAt: DateTime.now(),
        publishedAt: DateTime.now(),
        draft: false,
        prerelease: false,
        assets: [],
      );

      final prerelease = GitHubRelease(
        name: 'Pre-release',
        tagName: '1.1.0-beta',
        body: 'Beta release',
        htmlUrl: 'https://github.com/test/repo/releases/tag/1.1.0-beta',
        createdAt: DateTime.now(),
        publishedAt: DateTime.now(),
        draft: false,
        prerelease: true,
        assets: [],
      );

      final draft = GitHubRelease(
        name: 'Draft Release',
        tagName: '1.2.0',
        body: 'Draft release',
        htmlUrl: 'https://github.com/test/repo/releases/tag/1.2.0',
        createdAt: DateTime.now(),
        publishedAt: DateTime.now(),
        draft: true,
        prerelease: false,
        assets: [],
      );

      expect(stableRelease.isStable, true);
      expect(prerelease.isStable, false);
      expect(draft.isStable, false);
    });
  });
}
