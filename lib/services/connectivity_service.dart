import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

enum ConnectivityStatus { online, offline }

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<ConnectivityStatus> _statusController =
      StreamController<ConnectivityStatus>.broadcast();

  Stream<ConnectivityStatus> get statusStream => _statusController.stream;
  ConnectivityStatus _currentStatus = ConnectivityStatus.offline;

  ConnectivityStatus get currentStatus => _currentStatus;

  Future<void> initialize() async {
    // Проверяем начальное состояние
    final result = await _connectivity.checkConnectivity();
    _updateStatus(_mapConnectivityResult(result));

    // Слушаем изменения состояния подключения
    _connectivity.onConnectivityChanged.listen((result) {
      _updateStatus(_mapConnectivityResult(result));
    });
  }

  void _updateStatus(ConnectivityStatus newStatus) {
    if (_currentStatus != newStatus) {
      _currentStatus = newStatus;
      _statusController.add(newStatus);
    }
  }

  ConnectivityStatus _mapConnectivityResult(List<ConnectivityResult> results) {
    // Если хотя бы одно подключение активно, считаем что онлайн
    for (final result in results) {
      if (result != ConnectivityResult.none) {
        return ConnectivityStatus.online;
      }
    }
    return ConnectivityStatus.offline;
  }

  Future<bool> isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return _mapConnectivityResult(result) == ConnectivityStatus.online;
  }

  Future<void> dispose() async {
    await _statusController.close();
  }
}
