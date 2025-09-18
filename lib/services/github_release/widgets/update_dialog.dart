import 'package:flutter/material.dart';
import '../models/github_release.dart';
import '../github_release_service.dart';

class UpdateDialog extends StatelessWidget {
  final GitHubRelease release;
  final GitHubReleaseService releaseService;

  const UpdateDialog({
    super.key,
    required this.release,
    required this.releaseService,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.system_update, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Доступно обновление',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Версия ${release.tagName}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            if (release.name.isNotEmpty && release.name != release.tagName) ...[
              Text(
                release.name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
              ),
              const SizedBox(height: 8),
            ],
            if (release.body.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SizedBox(
                  height: 120,
                  child: SingleChildScrollView(
                    child: Text(
                      release.body,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  'Опубликовано: ${_formatDate(release.publishedAt)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await releaseService.skipVersion(release.tagName);
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: const Text('Напомнить позже'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Отмена'),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            await releaseService.openReleaseInBrowser(release.htmlUrl);
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          icon: const Icon(Icons.open_in_browser),
          label: const Text('Открыть в браузере'),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'сегодня';
    } else if (difference.inDays == 1) {
      return 'вчера';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} дн. назад';
    } else {
      return '${date.day}.${date.month}.${date.year}';
    }
  }

  /// Показывает диалог обновления
  static Future<void> show(
    BuildContext context,
    GitHubRelease release,
    GitHubReleaseService releaseService,
  ) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => UpdateDialog(
        release: release,
        releaseService: releaseService,
      ),
    );
  }
}

/// Виджет для отображения кнопки проверки обновлений в настройках
class UpdateCheckWidget extends StatefulWidget {
  final GitHubReleaseService releaseService;

  const UpdateCheckWidget({
    super.key,
    required this.releaseService,
  });

  @override
  State<UpdateCheckWidget> createState() => _UpdateCheckWidgetState();
}

class _UpdateCheckWidgetState extends State<UpdateCheckWidget> {
  bool _isChecking = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.system_update),
      title: const Text('Проверить обновления'),
      subtitle: const Text('Проверить наличие новых версий'),
      trailing: _isChecking
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: _isChecking ? null : _checkForUpdates,
    );
  }

  Future<void> _checkForUpdates() async {
    setState(() {
      _isChecking = true;
    });

    try {
      final release = await widget.releaseService.forceCheckForUpdates();

      if (mounted) {
        setState(() {
          _isChecking = false;
        });

        if (release != null) {
          await UpdateDialog.show(context, release, widget.releaseService);
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
      if (mounted) {
        setState(() {
          _isChecking = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при проверке обновлений: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
