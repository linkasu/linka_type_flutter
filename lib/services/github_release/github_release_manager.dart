import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'github_release_service.dart';
import 'widgets/update_dialog.dart';

class GitHubReleaseManager {
  static const String _defaultOwner = 'aacidov';
  static const String _defaultRepo = 'linka_type_flutter';

  late final GitHubReleaseService _releaseService;
  late final String _currentVersion;

  GitHubReleaseManager({
    String? owner,
    String? repo,
    String? currentVersion,
  }) {
    _currentVersion = currentVersion ?? '0.0.0';
    _releaseService = GitHubReleaseService(
      owner: owner ?? _defaultOwner,
      repo: repo ?? _defaultRepo,
      currentVersion: _currentVersion,
    );
  }

  /// Инициализация менеджера с автоматическим определением версии
  static Future<GitHubReleaseManager> create({
    String? owner,
    String? repo,
  }) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return GitHubReleaseManager(
        owner: owner,
        repo: repo,
        currentVersion: packageInfo.version,
      );
    } catch (e) {
      print('Ошибка при получении информации о пакете: $e');
      return GitHubReleaseManager(
        owner: owner,
        repo: repo,
        currentVersion: '0.0.0',
      );
    }
  }

  /// Проверяет обновления и показывает диалог при наличии новых версий
  Future<void> checkForUpdates(BuildContext context) async {
    try {
      final release = await _releaseService.checkForUpdates();

      if (release != null && context.mounted) {
        await UpdateDialog.show(context, release, _releaseService);
      }
    } catch (e) {
      print('Ошибка при проверке обновлений: $e');
    }
  }

  /// Принудительная проверка обновлений
  Future<void> forceCheckForUpdates(BuildContext context) async {
    try {
      final release = await _releaseService.forceCheckForUpdates();

      if (context.mounted) {
        if (release != null) {
          await UpdateDialog.show(context, release, _releaseService);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('У вас установлена последняя версия'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при проверке обновлений: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Создает виджет для проверки обновлений в настройках
  Widget createUpdateCheckWidget() {
    return UpdateCheckWidget(releaseService: _releaseService);
  }

  /// Получает сервис релизов для прямого использования
  GitHubReleaseService get releaseService => _releaseService;

  /// Получает текущую версию приложения
  String get currentVersion => _currentVersion;
}

/// Миксин для автоматической проверки обновлений при запуске
mixin UpdateCheckerMixin<T extends StatefulWidget> on State<T> {
  GitHubReleaseManager? _releaseManager;

  @override
  void initState() {
    super.initState();
    _initializeUpdateChecker();
  }

  Future<void> _initializeUpdateChecker() async {
    try {
      _releaseManager = await GitHubReleaseManager.create();

      // Проверяем обновления через небольшую задержку
      // чтобы не мешать инициализации приложения
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        await _releaseManager!.checkForUpdates(context);
      }
    } catch (e) {
      print('Ошибка при инициализации проверки обновлений: $e');
    }
  }

  /// Принудительная проверка обновлений
  Future<void> checkForUpdates() async {
    if (_releaseManager != null && mounted) {
      await _releaseManager!.forceCheckForUpdates(context);
    }
  }

  /// Получает менеджер релизов
  GitHubReleaseManager? get releaseManager => _releaseManager;
}
