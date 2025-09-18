import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/github_release.dart';
import 'dart:developer' as developer;

class GitHubReleaseService {
  static const String _baseUrl = 'https://api.github.com';
  static const String _lastCheckKey = 'last_release_check';
  static const String _skipVersionKey = 'skip_version';
  static const Duration _checkInterval = Duration(hours: 24);

  final String owner;
  final String repo;
  final String currentVersion;

  GitHubReleaseService({
    required this.owner,
    required this.repo,
    required this.currentVersion,
  });

  /// Проверяет, есть ли новые релизы
  Future<GitHubRelease?> checkForUpdates() async {
    developer.log('=== GITHUB RELEASE CHECK START ===');
    developer.log('Owner: $owner');
    developer.log('Repo: $repo');
    developer.log('Current version: $currentVersion');
    
    try {
      // Проверяем, нужно ли выполнять проверку сейчас
      if (!await _shouldCheckForUpdates()) {
        developer.log('Skipping update check - too soon since last check');
        return null;
      }

      developer.log('Fetching releases from GitHub API');
      final releases = await _fetchReleases();
      developer.log('Found ${releases.length} releases');
      
      if (releases.isEmpty) {
        developer.log('No releases found');
        return null;
      }

      // Ищем стабильный релиз новее текущей версии
      final stableReleases = releases.where((release) => release.isStable).toList();
      developer.log('Found ${stableReleases.length} stable releases');
      
      final latestRelease = stableReleases
          .where((release) => release.isNewerThan(currentVersion))
          .firstOrNull;

      if (latestRelease != null) {
        developer.log('Found newer release: ${latestRelease.tagName}');
        
        // Проверяем, не пропускал ли пользователь эту версию
        final skipVersion = await _getSkippedVersion();
        if (skipVersion != latestRelease.tagName) {
          developer.log('Release not skipped, showing update dialog');
          await _updateLastCheckTime();
          return latestRelease;
        } else {
          developer.log('Release ${latestRelease.tagName} was skipped by user');
        }
      } else {
        developer.log('No newer stable releases found');
      }

      developer.log('=== GITHUB RELEASE CHECK END - NO UPDATE ===');
      return null;
    } catch (e) {
      developer.log('=== GITHUB RELEASE CHECK ERROR ===');
      developer.log('Error type: ${e.runtimeType}');
      developer.log('Error message: $e');
      print('Ошибка при проверке обновлений: $e');
      return null;
    }
  }

  /// Получает список релизов с GitHub API
  Future<List<GitHubRelease>> _fetchReleases() async {
    final url = Uri.parse('$_baseUrl/repos/$owner/$repo/releases');
    developer.log('GitHub API URL: $url');
    
    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/vnd.github.v3+json',
        'User-Agent': 'LINKa-Type-Flutter/$currentVersion',
      },
    );

    developer.log('GitHub API response status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      developer.log('Successfully parsed ${jsonData.length} releases from GitHub API');
      return jsonData.map((json) => GitHubRelease.fromJson(json)).toList();
    } else {
      developer.log('GitHub API error response: ${response.body}');
      throw Exception('Не удалось получить релизы: ${response.statusCode}');
    }
  }

  /// Проверяет, нужно ли выполнять проверку обновлений
  Future<bool> _shouldCheckForUpdates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastCheckStr = prefs.getString(_lastCheckKey);

      if (lastCheckStr == null) return true;

      final lastCheck = DateTime.parse(lastCheckStr);
      final now = DateTime.now();

      return now.difference(lastCheck) > _checkInterval;
    } catch (e) {
      return true;
    }
  }

  /// Обновляет время последней проверки
  Future<void> _updateLastCheckTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastCheckKey, DateTime.now().toIso8601String());
    } catch (e) {
      print('Ошибка при обновлении времени проверки: $e');
    }
  }

  /// Получает пропущенную версию
  Future<String?> _getSkippedVersion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_skipVersionKey);
    } catch (e) {
      return null;
    }
  }

  /// Помечает версию как пропущенную
  Future<void> skipVersion(String version) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_skipVersionKey, version);
    } catch (e) {
      print('Ошибка при пропуске версии: $e');
    }
  }

  /// Сбрасывает пропущенную версию
  Future<void> clearSkippedVersion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_skipVersionKey);
    } catch (e) {
      print('Ошибка при сбросе пропущенной версии: $e');
    }
  }

  /// Открывает релиз в браузере
  Future<void> openReleaseInBrowser(String releaseUrl) async {
    try {
      final uri = Uri.parse(releaseUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Не удалось открыть URL: $releaseUrl');
      }
    } catch (e) {
      print('Ошибка при открытии браузера: $e');
    }
  }

  /// Принудительная проверка обновлений (игнорирует интервал)
  Future<GitHubRelease?> forceCheckForUpdates() async {
    try {
      final releases = await _fetchReleases();
      if (releases.isEmpty) return null;

      final latestRelease = releases
          .where((release) => release.isStable)
          .where((release) => release.isNewerThan(currentVersion))
          .firstOrNull;

      return latestRelease;
    } catch (e) {
      print('Ошибка при принудительной проверке обновлений: $e');
      return null;
    }
  }
}
