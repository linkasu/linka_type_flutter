import 'package:flutter/material.dart';
import '../../services/connectivity_service.dart';
import '../../services/offline_data_service.dart';

class ConnectivityIndicator extends StatefulWidget {
  final OfflineDataService dataService;

  const ConnectivityIndicator({
    Key? key,
    required this.dataService,
  }) : super(key: key);

  @override
  State<ConnectivityIndicator> createState() => _ConnectivityIndicatorState();
}

class _ConnectivityIndicatorState extends State<ConnectivityIndicator> {
  ConnectivityStatus _status = ConnectivityStatus.offline;
  int _pendingCount = 0;

  @override
  void initState() {
    super.initState();
    _status = widget.dataService.currentConnectivityStatus;
    _loadPendingCount();

    widget.dataService.connectivityStream.listen((status) {
      if (mounted) {
        setState(() {
          _status = status;
        });
        _loadPendingCount();
      }
    });
  }

  Future<void> _loadPendingCount() async {
    final count = await widget.dataService.getPendingSyncCount();
    if (mounted) {
      setState(() {
        _pendingCount = count;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
          const SizedBox(width: 6),
          Text(
            _getStatusText(),
            style: TextStyle(
              color: _getTextColor(),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (_pendingCount > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _pendingCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (_status) {
      case ConnectivityStatus.online:
        return Colors.green.withOpacity(0.1);
      case ConnectivityStatus.offline:
        return Colors.red.withOpacity(0.1);
    }
  }

  Color _getTextColor() {
    switch (_status) {
      case ConnectivityStatus.online:
        return Colors.green.shade700;
      case ConnectivityStatus.offline:
        return Colors.red.shade700;
    }
  }

  IconData _getIcon() {
    switch (_status) {
      case ConnectivityStatus.online:
        return Icons.wifi;
      case ConnectivityStatus.offline:
        return Icons.wifi_off;
    }
  }

  String _getStatusText() {
    switch (_status) {
      case ConnectivityStatus.online:
        return 'Онлайн';
      case ConnectivityStatus.offline:
        return 'Оффлайн';
    }
  }
}
