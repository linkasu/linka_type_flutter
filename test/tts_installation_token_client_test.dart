import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:linka_type_flutter/services/tts_installation_token_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const now = '2026-09-30T12:00:00Z';
  final currentTime = DateTime.parse(now);

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('bootstraps and persists an installation token', () async {
    final requests = <http.Request>[];
    final client = MockClient((request) async {
      requests.add(request);
      if (request.url.path == '/v1/tts/installations') {
        expect(request.body, '{}');
        return http.Response(
          jsonEncode({
            'token': 'first-token',
            'expires_at': '2026-11-01T12:00:00Z',
          }),
          200,
        );
      }
      expect(request.url.path, '/v1/tts/anonymous');
      expect(request.headers['X-TTS-Installation-Token'], 'first-token');
      expect(request.headers['Idempotency-Key'], matches(_uuid));
      expect(jsonDecode(request.body), {'text': 'hello', 'voice': 'zahar'});
      return http.Response.bytes([1, 2], 200);
    });
    final prefs = await SharedPreferences.getInstance();
    final tokenClient = TTSInstallationTokenClient(
      prefs,
      client: client,
      now: () => currentTime,
    );

    final response = await tokenClient.post({
      'text': 'hello',
      'voice': 'zahar',
    });

    expect(response.statusCode, 200);
    expect(requests, hasLength(2));
    expect(prefs.getString('tts_installation_token'), 'first-token');
    expect(prefs.getInt('tts_installation_token_expires_at'), isNotNull);
  });

  test('uses a stored token until it enters the refresh window', () async {
    SharedPreferences.setMockInitialValues({
      'tts_installation_token': 'stored-token',
      'tts_installation_token_expires_at':
          currentTime.add(const Duration(hours: 25)).millisecondsSinceEpoch,
    });
    final client = MockClient((request) async {
      expect(request.url.path, '/v1/tts/anonymous');
      expect(request.headers['X-TTS-Installation-Token'], 'stored-token');
      return http.Response.bytes([1], 200);
    });
    final tokenClient = TTSInstallationTokenClient(
      await SharedPreferences.getInstance(),
      client: client,
      now: () => currentTime,
    );

    await tokenClient.post({'text': 'hello', 'voice': 'zahar'});
  });

  test('refreshes a token with less than 24 hours remaining', () async {
    SharedPreferences.setMockInitialValues({
      'tts_installation_token': 'expiring-token',
      'tts_installation_token_expires_at':
          currentTime.add(const Duration(hours: 23)).millisecondsSinceEpoch,
    });
    final client = MockClient((request) async {
      if (request.url.path == '/v1/tts/installations') {
        return http.Response(
          jsonEncode({
            'token': 'refreshed-token',
            'expires_at': '2026-11-01T12:00:00Z',
          }),
          200,
        );
      }
      expect(request.headers['X-TTS-Installation-Token'], 'refreshed-token');
      return http.Response.bytes([1], 200);
    });
    final tokenClient = TTSInstallationTokenClient(
      await SharedPreferences.getInstance(),
      client: client,
      now: () => currentTime,
    );

    await tokenClient.post({'text': 'hello', 'voice': 'zahar'});
  });

  test(
    'retries one unauthorized anonymous request with the same idempotency key',
    () async {
      var bootstrapCount = 0;
      final anonymousRequests = <http.Request>[];
      final client = MockClient((request) async {
        if (request.url.path == '/v1/tts/installations') {
          bootstrapCount++;
          return http.Response(
            jsonEncode({
              'token': bootstrapCount == 1 ? 'first-token' : 'second-token',
              'expires_at': '2026-11-01T12:00:00Z',
            }),
            200,
          );
        }
        anonymousRequests.add(request);
        return http.Response.bytes([
          1,
        ], anonymousRequests.length == 1 ? 401 : 200);
      });
      final tokenClient = TTSInstallationTokenClient(
        await SharedPreferences.getInstance(),
        client: client,
        now: () => currentTime,
      );

      final response = await tokenClient.post({
        'text': 'hello',
        'voice': 'zahar',
      });

      expect(response.statusCode, 200);
      expect(bootstrapCount, 2);
      expect(anonymousRequests, hasLength(2));
      expect(
        anonymousRequests.map((request) => request.headers['Idempotency-Key']),
        everyElement(
          equals(anonymousRequests.first.headers['Idempotency-Key']),
        ),
      );
      expect(
        anonymousRequests.map(
          (request) => request.headers['X-TTS-Installation-Token'],
        ),
        ['first-token', 'second-token'],
      );
    },
  );

  test('does not retry a second unauthorized response', () async {
    final responses = <int>[200, 401, 200, 401];
    final client = MockClient((_) async {
      final status = responses.removeAt(0);
      if (status == 200) {
        return http.Response(
          jsonEncode({
            'token': 'token-${responses.length}',
            'expires_at': '2026-11-01T12:00:00Z',
          }),
          status,
        );
      }
      return http.Response.bytes([1], status);
    });
    final tokenClient = TTSInstallationTokenClient(
      await SharedPreferences.getInstance(),
      client: client,
      now: () => currentTime,
    );

    expect((await tokenClient.post({'text': 'hello'})).statusCode, 401);
    expect(responses, isEmpty);
  });

  test(
    'signals unsupported installation endpoints for direct compatibility',
    () async {
      for (final status in [404, 501]) {
        SharedPreferences.setMockInitialValues({});
        final tokenClient = TTSInstallationTokenClient(
          await SharedPreferences.getInstance(),
          client: MockClient((_) async => http.Response('', status)),
          now: () => currentTime,
        );

        await expectLater(
          tokenClient.post({'text': 'hello'}),
          throwsA(isA<TTSInstallationCompatibilityException>()),
        );
      }
    },
  );
}

final _uuid = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
);
