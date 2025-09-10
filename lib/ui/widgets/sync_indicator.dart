import 'package:flutter/material.dart';
import '../../services/sync_service.dart';
import '../../services/offline_data_service.dart';

// Используем SyncProcessStatus из sync_service.dart
typedef SyncStatus = SyncProcessStatus;

class SyncIndicator extends StatefulWidget {
  final OfflineDataService dataService;

  const SyncIndicator({
    Key? key,
    required this.dataService,
  }) : super(key: key);

  @override
  State<SyncIndicator> createState() => _SyncIndicatorState();
}

class _SyncIndicatorState extends State<SyncIndicator>
    with TickerProviderStateMixin {
  SyncStatus _status = SyncStatus.idle;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();

    widget.dataService.syncStatusStream.listen((status) {
      if (mounted) {
        setState(() {
          _status = status;
        });

        if (status == SyncStatus.syncing) {
          _animationController.repeat();
        } else {
          _animationController.stop();
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_status == SyncStatus.idle) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_status == SyncStatus.syncing)
            RotationTransition(
              turns: _animationController,
              child: Icon(
                Icons.sync,
                color: _getIconColor(),
                size: 16,
              ),
            )
          else
            Icon(
              _getIcon(),
              color: _getIconColor(),
              size: 16,
            ),
          const SizedBox(width: 6),
          Text(
            _getStatusText(),
            style: TextStyle(
              color: _getTextColor(),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (_status) {
      case SyncStatus.syncing:
        return Colors.blue.withOpacity(0.1);
      case SyncStatus.completed:
        return Colors.green.withOpacity(0.1);
      case SyncStatus.error:
        return Colors.red.withOpacity(0.1);
      case SyncStatus.offline:
        return Colors.orange.withOpacity(0.1);
      default:
        return Colors.transparent;
    }
  }

  Color _getTextColor() {
    switch (_status) {
      case SyncStatus.syncing:
        return Colors.blue.shade700;
      case SyncStatus.completed:
        return Colors.green.shade700;
      case SyncStatus.error:
        return Colors.red.shade700;
      case SyncStatus.offline:
        return Colors.orange.shade700;
      default:
        return Colors.grey;
    }
  }

  Color _getIconColor() {
    switch (_status) {
      case SyncStatus.syncing:
        return Colors.blue.shade700;
      case SyncStatus.completed:
        return Colors.green.shade700;
      case SyncStatus.error:
        return Colors.red.shade700;
      case SyncStatus.offline:
        return Colors.orange.shade700;
      default:
        return Colors.grey;
    }
  }

  IconData _getIcon() {
    switch (_status) {
      case SyncStatus.completed:
        return Icons.check_circle;
      case SyncStatus.error:
        return Icons.error;
      case SyncStatus.offline:
        return Icons.cloud_off;
      default:
        return Icons.sync;
    }
  }

  String _getStatusText() {
    switch (_status) {
      case SyncStatus.syncing:
        return 'Синхронизация...';
      case SyncStatus.completed:
        return 'Синхронизировано';
      case SyncStatus.error:
        return 'Ошибка синхр.';
      case SyncStatus.offline:
        return 'Ожидание сети';
      default:
        return '';
    }
  }
}
