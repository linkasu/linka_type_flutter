import 'package:flutter/material.dart';
import '../models/sync_state.dart';

/// Виджет для отображения статуса синхронизации
class SyncStatusWidget extends StatelessWidget {
  final SyncState syncState;
  final VoidCallback? onSyncPressed;

  const SyncStatusWidget({
    super.key,
    required this.syncState,
    this.onSyncPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIcon(),
            color: _getTextColor(),
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            _getStatusText(),
            style: TextStyle(
              color: _getTextColor(),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (syncState.hasPendingOperations) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _getTextColor().withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Text(
                syncState.pendingOperations.toString(),
                style: TextStyle(
                  color: _getTextColor(),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          if (onSyncPressed != null && syncState.hasError) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onSyncPressed,
              child: Icon(
                Icons.refresh,
                color: _getTextColor(),
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (syncState.status) {
      case SyncStatus.synced:
        return Colors.green.withOpacity(0.1);
      case SyncStatus.syncing:
        return Colors.blue.withOpacity(0.1);
      case SyncStatus.error:
        return Colors.red.withOpacity(0.1);
      case SyncStatus.offline:
        return Colors.orange.withOpacity(0.1);
    }
  }

  Color _getTextColor() {
    switch (syncState.status) {
      case SyncStatus.synced:
        return Colors.green;
      case SyncStatus.syncing:
        return Colors.blue;
      case SyncStatus.error:
        return Colors.red;
      case SyncStatus.offline:
        return Colors.orange;
    }
  }

  IconData _getIcon() {
    switch (syncState.status) {
      case SyncStatus.synced:
        return Icons.check_circle;
      case SyncStatus.syncing:
        return Icons.sync;
      case SyncStatus.error:
        return Icons.error;
      case SyncStatus.offline:
        return Icons.wifi_off;
    }
  }

  String _getStatusText() {
    switch (syncState.status) {
      case SyncStatus.synced:
        return 'Синхронизировано';
      case SyncStatus.syncing:
        return 'Синхронизация...';
      case SyncStatus.error:
        return 'Ошибка синхронизации';
      case SyncStatus.offline:
        return 'Оффлайн режим';
    }
  }
}

/// Виджет для отображения подробной информации о синхронизации
class SyncStatusBanner extends StatelessWidget {
  final SyncState syncState;
  final VoidCallback? onRetryPressed;
  final VoidCallback? onDismissPressed;

  const SyncStatusBanner({
    super.key,
    required this.syncState,
    this.onRetryPressed,
    this.onDismissPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (syncState.status == SyncStatus.synced &&
        !syncState.hasPendingOperations) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getBannerColor(),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getBorderColor(),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getBannerIcon(),
                color: _getBannerTextColor(),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _getBannerTitle(),
                  style: TextStyle(
                    color: _getBannerTextColor(),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (onDismissPressed != null)
                IconButton(
                  onPressed: onDismissPressed,
                  icon: Icon(
                    Icons.close,
                    color: _getBannerTextColor(),
                    size: 20,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getBannerMessage(),
            style: TextStyle(
              color: _getBannerTextColor(),
              fontSize: 14,
            ),
          ),
          if (syncState.hasError && syncState.errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              syncState.errorMessage!,
              style: TextStyle(
                color: _getBannerTextColor().withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ],
          if (syncState.hasPendingOperations) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.pending,
                  color: _getBannerTextColor(),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Ожидающих операций: ${syncState.pendingOperations}',
                  style: TextStyle(
                    color: _getBannerTextColor(),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
          if (onRetryPressed != null &&
              (syncState.hasError || syncState.hasPendingOperations)) ...[
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onRetryPressed,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Повторить синхронизацию'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _getBannerTextColor(),
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getBannerColor() {
    switch (syncState.status) {
      case SyncStatus.synced:
        return Colors.green.withOpacity(0.1);
      case SyncStatus.syncing:
        return Colors.blue.withOpacity(0.1);
      case SyncStatus.error:
        return Colors.red.withOpacity(0.1);
      case SyncStatus.offline:
        return Colors.orange.withOpacity(0.1);
    }
  }

  Color _getBorderColor() {
    switch (syncState.status) {
      case SyncStatus.synced:
        return Colors.green.withOpacity(0.3);
      case SyncStatus.syncing:
        return Colors.blue.withOpacity(0.3);
      case SyncStatus.error:
        return Colors.red.withOpacity(0.3);
      case SyncStatus.offline:
        return Colors.orange.withOpacity(0.3);
    }
  }

  Color _getBannerTextColor() {
    switch (syncState.status) {
      case SyncStatus.synced:
        return Colors.green.shade700;
      case SyncStatus.syncing:
        return Colors.blue.shade700;
      case SyncStatus.error:
        return Colors.red.shade700;
      case SyncStatus.offline:
        return Colors.orange.shade700;
    }
  }

  IconData _getBannerIcon() {
    switch (syncState.status) {
      case SyncStatus.synced:
        return Icons.check_circle;
      case SyncStatus.syncing:
        return Icons.sync;
      case SyncStatus.error:
        return Icons.error;
      case SyncStatus.offline:
        return Icons.wifi_off;
    }
  }

  String _getBannerTitle() {
    switch (syncState.status) {
      case SyncStatus.synced:
        return 'Данные синхронизированы';
      case SyncStatus.syncing:
        return 'Синхронизация данных';
      case SyncStatus.error:
        return 'Ошибка синхронизации';
      case SyncStatus.offline:
        return 'Работа в оффлайн режиме';
    }
  }

  String _getBannerMessage() {
    switch (syncState.status) {
      case SyncStatus.synced:
        return 'Все данные успешно синхронизированы с сервером.';
      case SyncStatus.syncing:
        return 'Выполняется синхронизация данных с сервером...';
      case SyncStatus.error:
        return 'Произошла ошибка при синхронизации данных.';
      case SyncStatus.offline:
        return 'Нет подключения к интернету. Изменения будут синхронизированы при восстановлении связи.';
    }
  }
}
