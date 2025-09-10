import 'dart:async';
import 'package:flutter/material.dart';

enum NotificationType {
  success,
  error,
  warning,
  info,
}

class AppNotification {
  final String id;
  final String title;
  final String? message;
  final NotificationType type;
  final DateTime timestamp;
  final Duration? autoDismissDelay;

  AppNotification({
    required this.id,
    required this.title,
    this.message,
    required this.type,
    DateTime? timestamp,
    this.autoDismissDelay,
  }) : timestamp = timestamp ?? DateTime.now();

  Color get backgroundColor {
    switch (type) {
      case NotificationType.success:
        return Colors.green.shade50;
      case NotificationType.error:
        return Colors.red.shade50;
      case NotificationType.warning:
        return Colors.orange.shade50;
      case NotificationType.info:
        return Colors.blue.shade50;
    }
  }

  Color get borderColor {
    switch (type) {
      case NotificationType.success:
        return Colors.green.shade300;
      case NotificationType.error:
        return Colors.red.shade300;
      case NotificationType.warning:
        return Colors.orange.shade300;
      case NotificationType.info:
        return Colors.blue.shade300;
    }
  }

  Color get textColor {
    switch (type) {
      case NotificationType.success:
        return Colors.green.shade800;
      case NotificationType.error:
        return Colors.red.shade800;
      case NotificationType.warning:
        return Colors.orange.shade800;
      case NotificationType.info:
        return Colors.blue.shade800;
    }
  }

  IconData get icon {
    switch (type) {
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.error:
        return Icons.error;
      case NotificationType.warning:
        return Icons.warning;
      case NotificationType.info:
        return Icons.info;
    }
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final List<AppNotification> _notifications = [];
  final StreamController<List<AppNotification>> _notificationsController =
      StreamController<List<AppNotification>>.broadcast();

  Stream<List<AppNotification>> get notificationsStream =>
      _notificationsController.stream;
  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  // Показать уведомление
  void showNotification({
    required String title,
    String? message,
    required NotificationType type,
    Duration? autoDismissDelay,
  }) {
    final notification = AppNotification(
      id: _generateId(),
      title: title,
      message: message,
      type: type,
      autoDismissDelay: autoDismissDelay,
    );

    _notifications.insert(0, notification);
    _notificationsController.add(_notifications);

    // Автоматическое скрытие
    if (autoDismissDelay != null) {
      Future.delayed(autoDismissDelay, () {
        dismissNotification(notification.id);
      });
    }
  }

  // Скрыть уведомление
  void dismissNotification(String id) {
    _notifications.removeWhere((notification) => notification.id == id);
    _notificationsController.add(_notifications);
  }

  // Очистить все уведомления
  void clearAllNotifications() {
    _notifications.clear();
    _notificationsController.add(_notifications);
  }

  // Предопределенные методы для удобства

  void showSuccess(String title,
      {String? message, Duration? autoDismissDelay}) {
    showNotification(
      title: title,
      message: message,
      type: NotificationType.success,
      autoDismissDelay: autoDismissDelay ?? const Duration(seconds: 3),
    );
  }

  void showError(String title, {String? message, Duration? autoDismissDelay}) {
    showNotification(
      title: title,
      message: message,
      type: NotificationType.error,
      autoDismissDelay: autoDismissDelay ?? const Duration(seconds: 5),
    );
  }

  void showWarning(String title,
      {String? message, Duration? autoDismissDelay}) {
    showNotification(
      title: title,
      message: message,
      type: NotificationType.warning,
      autoDismissDelay: autoDismissDelay ?? const Duration(seconds: 4),
    );
  }

  void showInfo(String title, {String? message, Duration? autoDismissDelay}) {
    showNotification(
      title: title,
      message: message,
      type: NotificationType.info,
      autoDismissDelay: autoDismissDelay ?? const Duration(seconds: 3),
    );
  }

  // Специфические уведомления для оффлайн режима

  void showOfflineMode() {
    showWarning(
      'Режим оффлайн',
      message:
          'Изменения будут синхронизированы при восстановлении подключения',
      autoDismissDelay: const Duration(seconds: 4),
    );
  }

  void showSyncStarted() {
    showInfo(
      'Синхронизация',
      message: 'Синхронизация данных с сервером...',
    );
  }

  void showSyncCompleted(int syncedCount) {
    showSuccess(
      'Синхронизация завершена',
      message:
          syncedCount > 0 ? 'Синхронизировано $syncedCount изменений' : null,
      autoDismissDelay: const Duration(seconds: 3),
    );
  }

  void showSyncError(String error) {
    showError(
      'Ошибка синхронизации',
      message: 'Не удалось синхронизировать данные: $error',
      autoDismissDelay: const Duration(seconds: 5),
    );
  }

  void showConnectionRestored() {
    showSuccess(
      'Подключение восстановлено',
      message: 'Запуск синхронизации...',
      autoDismissDelay: const Duration(seconds: 3),
    );
  }

  String _generateId() {
    return 'notification_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }

  void dispose() {
    _notificationsController.close();
  }
}
