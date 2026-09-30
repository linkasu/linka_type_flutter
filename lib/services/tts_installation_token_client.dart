import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TTSInstallationCompatibilityException implements Exception {}

class TTSInstallationTokenClient {
  static const _tokenKey = 'tts_installation_token';
  static const _expiresAtKey = 'tts_installation_token_expires_at';
  static const _refreshWindow = Duration(hours: 24);
  static const _requestTimeout = Duration(seconds: 15);
  static final _baseUri = Uri.parse('https://backend.linka.su/v1/');

  final SharedPreferences _prefs;
  final http.Client _client;
  final DateTime Function() _now;

  TTSInstallationTokenClient(
    this._prefs, {
    http.Client? client,
    DateTime Function()? now,
  })  : _client = client ?? http.Client(),
        _now = now ?? DateTime.now;

  Future<http.Response> post(Map<String, dynamic> body) async {
    final idempotencyKey = _newUuid();
    var token = await _token();
    var response = await _postAnonymous(body, token, idempotencyKey);
    if (response.statusCode != 401) return response;

    token = await _bootstrap();
    return _postAnonymous(body, token, idempotencyKey);
  }

  Future<String> _token() async {
    final savedToken = _prefs.getString(_tokenKey)?.trim();
    final expiresAtMillis = _prefs.getInt(_expiresAtKey);
    final expiresAt = expiresAtMillis == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(expiresAtMillis);
    final now = _now();

    if (savedToken != null &&
        savedToken.isNotEmpty &&
        expiresAt != null &&
        expiresAt.isAfter(now)) {
      if (expiresAt.difference(now) > _refreshWindow) return savedToken;
      try {
        return await _bootstrap();
      } on TTSInstallationCompatibilityException {
        rethrow;
      } catch (_) {
        return savedToken;
      }
    }
    return _bootstrap();
  }

  Future<String> _bootstrap() async {
    final response = await _client
        .post(
          _baseUri.resolve('tts/installations'),
          headers: const {'Content-Type': 'application/json'},
          body: '{}',
        )
        .timeout(_requestTimeout);
    if (response.statusCode == 404 || response.statusCode == 501) {
      throw TTSInstallationCompatibilityException();
    }
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw http.ClientException('HTTP ${response.statusCode}');
    }

    final payload = jsonDecode(response.body);
    if (payload is! Map<String, dynamic>) {
      throw const FormatException('Invalid TTS installation response');
    }
    final token = (payload['token'] as String?)?.trim();
    final expiresAt = DateTime.tryParse(
      payload['expires_at']?.toString() ?? '',
    );
    if (token == null || token.isEmpty || expiresAt == null) {
      throw const FormatException('Invalid TTS installation response');
    }

    if (await _prefs.setString(_tokenKey, token)) {
      await _prefs.setInt(_expiresAtKey, expiresAt.millisecondsSinceEpoch);
    }
    return token;
  }

  Future<http.Response> _postAnonymous(
    Map<String, dynamic> body,
    String token,
    String idempotencyKey,
  ) async {
    final response = await _client
        .post(
          _baseUri.resolve('tts/anonymous'),
          headers: {
            'Content-Type': 'application/json',
            'X-TTS-Installation-Token': token,
            'Idempotency-Key': idempotencyKey,
          },
          body: jsonEncode(body),
        )
        .timeout(_requestTimeout);
    if (response.statusCode == 404 || response.statusCode == 501) {
      throw TTSInstallationCompatibilityException();
    }
    return response;
  }

  String _newUuid() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex =
        bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }
}
