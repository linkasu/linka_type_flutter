import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../utils/token_manager.dart';

class WebSocketService {
  static const String wsUrl = 'wss://type-backend.linka.su/api/ws';

  WebSocketChannel? _channel;
  bool _isConnected = false;

  Function(Map<String, dynamic>)? _onMessage;
  Function()? _onConnected;
  Function()? _onDisconnected;
  Function(dynamic)? _onError;

  bool get isConnected => _isConnected;

  void setMessageHandler(Function(Map<String, dynamic>) handler) {
    _onMessage = handler;
  }

  void setConnectionHandlers({
    Function()? onConnected,
    Function()? onDisconnected,
    Function(dynamic)? onError,
  }) {
    _onConnected = onConnected;
    _onDisconnected = onDisconnected;
    _onError = onError;
  }

  Future<void> connect() async {
    if (_isConnected) return;

    try {
      final token = await TokenManager.getToken();
      if (token == null) {
        throw Exception('No authentication token available');
      }

      final wsUri = Uri.parse('$wsUrl?token=$token');
      _channel = WebSocketChannel.connect(wsUri);

      _channel!.stream.listen(
        (data) {
          _handleMessage(data);
        },
        onDone: () {
          _isConnected = false;
          _onDisconnected?.call();
        },
        onError: (error) {
          _isConnected = false;
          _onError?.call(error);
        },
      );

      _isConnected = true;
      _onConnected?.call();
    } catch (e) {
      _onError?.call(e);
      rethrow;
    }
  }

  void disconnect() {
    if (_channel != null) {
      _channel!.sink.close();
      _channel = null;
      _isConnected = false;
      _onDisconnected?.call();
    }
  }

  void sendMessage(String type, Map<String, dynamic> payload) {
    if (!_isConnected || _channel == null) {
      throw Exception('WebSocket is not connected');
    }

    final message = {'type': type, 'payload': payload};

    _channel!.sink.add(jsonEncode(message));
  }

  void _handleMessage(dynamic data) {
    try {
      final message = jsonDecode(data) as Map<String, dynamic>;
      _onMessage?.call(message);
    } catch (e) {
      _onError?.call(e);
    }
  }

  void dispose() {
    disconnect();
  }
}
