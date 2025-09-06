import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:linka_type_flutter/services/tts_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TTSService Tests', () {
    late TTSService ttsService;

    setUpAll(() async {
      // Инициализируем SharedPreferences для тестов
      const MethodChannel(
        'plugins.flutter.io/shared_preferences',
      ).setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'getAll') {
          return <String, Object>{}; // Пустые настройки
        }
        return null;
      });
    });

    setUp(() async {
      ttsService = TTSService.instance;
      // Ждем инициализации
      await Future.delayed(const Duration(milliseconds: 100));
    });

    tearDown(() {
      ttsService.dispose();
    });

    group('YandexVoice Tests', () {
      test('should create YandexVoice with correct properties', () {
        final voice = YandexVoice(voiceURI: 'test_voice', text: 'Test Voice');

        expect(voice.voiceURI, equals('test_voice'));
        expect(voice.text, equals('Test Voice'));
      });
    });

    group('TTSVoice Tests', () {
      test('should create TTSVoice with correct properties', () {
        final voice = TTSVoice(
          voiceURI: 'test_voice',
          text: 'Test Voice',
          locale: 'ru-RU',
          isDefault: true,
        );

        expect(voice.voiceURI, equals('test_voice'));
        expect(voice.text, equals('Test Voice'));
        expect(voice.locale, equals('ru-RU'));
        expect(voice.isDefault, isTrue);
      });

      test('should create TTSVoice with default values', () {
        final voice = TTSVoice(voiceURI: 'test_voice', text: 'Test Voice');

        expect(voice.locale, isNull);
        expect(voice.isDefault, isFalse);
      });
    });

    group('TTSService Singleton Tests', () {
      test('should return same instance', () {
        final instance1 = TTSService.instance;
        final instance2 = TTSService.instance;

        expect(identical(instance1, instance2), isTrue);
      });
    });

    group('Yandex Voices Tests', () {
      test('should return correct number of Yandex voices', () {
        final voices = ttsService.getYandexVoices();

        expect(voices.length, equals(7));
      });

      test('should contain expected Yandex voices', () {
        final voices = ttsService.getYandexVoices();
        final voiceURIs = voices.map((v) => v.voiceURI).toList();

        expect(voiceURIs, contains('zahar'));
        expect(voiceURIs, contains('ermil'));
        expect(voiceURIs, contains('jane'));
        expect(voiceURIs, contains('oksana'));
        expect(voiceURIs, contains('alena'));
        expect(voiceURIs, contains('filipp'));
        expect(voiceURIs, contains('omazh'));
      });

      test('should have correct voice names', () {
        final voices = ttsService.getYandexVoices();
        final voiceMap = {for (var v in voices) v.voiceURI: v.text};

        expect(voiceMap['zahar'], equals('Захар'));
        expect(voiceMap['ermil'], equals('Емиль'));
        expect(voiceMap['jane'], equals('Джейн'));
        expect(voiceMap['oksana'], equals('Оксана'));
        expect(voiceMap['alena'], equals('Алёна'));
        expect(voiceMap['filipp'], equals('Филипп'));
        expect(voiceMap['omazh'], equals('Ома'));
      });
    });

    group('Settings Tests', () {
      test('should get default volume', () async {
        final volume = await ttsService.getVolume();
        expect(volume, equals(1.0));
      });

      test('should get default rate', () async {
        final rate = await ttsService.getRate();
        expect(rate, equals(1.0));
      });

      test('should get default pitch', () async {
        final pitch = await ttsService.getPitch();
        expect(pitch, equals(1.0));
      });

      test('should get default Yandex setting', () async {
        final useYandex = await ttsService.getUseYandex();
        expect(useYandex, isTrue);
      });

      test('should set and get volume', () async {
        await ttsService.setVolume(0.5);
        final volume = await ttsService.getVolume();
        expect(volume, equals(0.5));
      });

      test('should set and get rate', () async {
        await ttsService.setRate(1.5);
        final rate = await ttsService.getRate();
        expect(rate, equals(1.5));
      });

      test('should set and get pitch', () async {
        await ttsService.setPitch(1.2);
        final pitch = await ttsService.getPitch();
        expect(pitch, equals(1.2));
      });

      test('should set and get Yandex setting', () async {
        await ttsService.setUseYandex(false);
        final useYandex = await ttsService.getUseYandex();
        expect(useYandex, isFalse);
      });
    });

    group('Voice Selection Tests', () {
      test('should get selected voice', () async {
        final voice = await ttsService.getSelectedVoice();

        expect(voice.voiceURI, isNotEmpty);
        expect(voice.text, isNotEmpty);
      });

      test('should set voice correctly', () async {
        await ttsService.setVoice('zahar');
        final selectedVoice = await ttsService.getSelectedVoice();

        expect(selectedVoice.voiceURI, equals('zahar'));
        expect(selectedVoice.text, equals('Захар'));
      });

      test('should handle invalid voice gracefully', () async {
        await ttsService.setVoice('invalid_voice');
        final selectedVoice = await ttsService.getSelectedVoice();

        // Должен вернуть первый доступный голос
        expect(selectedVoice.voiceURI, isNotEmpty);
        expect(selectedVoice.text, isNotEmpty);
      });
    });

    group('Offline Voices Tests', () {
      test('should return empty list for offline voices on Linux', () async {
        final voices = await ttsService.getOfflineVoices();
        expect(voices, isEmpty);
      });

      test('should return null for default offline voice on Linux', () async {
        final voice = await ttsService.getDefaultOfflineVoice();
        expect(voice, isNull);
      });
    });

    group('Events Tests', () {
      test('should emit events when saying text', () async {
        final events = <String>[];
        ttsService.events.listen(events.add);

        // Запускаем say в отдельной задаче, чтобы не блокировать тест
        ttsService.say('test');

        // Ждем немного для обработки событий
        await Future.delayed(const Duration(milliseconds: 100));

        expect(events, contains('start'));
      });

      test('should emit end event when stopping', () async {
        final events = <String>[];
        ttsService.events.listen(events.add);

        await ttsService.stop();

        expect(events, contains('end'));
      });

      test('should emit multiple events during text processing', () async {
        final events = <String>[];
        ttsService.events.listen(events.add);

        ttsService.say('test message');
        await Future.delayed(const Duration(milliseconds: 200));

        expect(events, contains('start'));
        expect(events, contains('end'));
      });
    });

    group('Text Processing Tests', () {
      test('should handle empty text', () async {
        final events = <String>[];
        ttsService.events.listen(events.add);

        await ttsService.say('');

        expect(events, isEmpty);
      });

      test('should handle short text', () async {
        final events = <String>[];
        ttsService.events.listen(events.add);

        ttsService.say('hi');
        await Future.delayed(const Duration(milliseconds: 100));

        expect(events, contains('start'));
      });

      test('should handle long text', () async {
        final longText = 'A' * 100;
        final events = <String>[];
        ttsService.events.listen(events.add);

        ttsService.say(longText);
        await Future.delayed(const Duration(milliseconds: 100));

        expect(events, contains('start'));
      });

      test('should handle special characters', () async {
        final specialText = 'Привет! Как дела? 123';
        final events = <String>[];
        ttsService.events.listen(events.add);

        ttsService.say(specialText);
        await Future.delayed(const Duration(milliseconds: 100));

        expect(events, contains('start'));
      });
    });

    group('Download Tests', () {
      test('should handle download mode', () async {
        final events = <String>[];
        ttsService.events.listen(events.add);

        ttsService.say('test', download: true);
        await Future.delayed(const Duration(milliseconds: 100));

        expect(events, contains('start'));
      });

      test('should emit end event after download', () async {
        final events = <String>[];
        ttsService.events.listen(events.add);

        ttsService.say('test', download: true);
        await Future.delayed(const Duration(milliseconds: 200));

        expect(events, contains('start'));
        expect(events, contains('end'));
      });
    });

    group('Error Handling Tests', () {
      test('should handle network errors gracefully', () async {
        final events = <String>[];
        ttsService.events.listen(events.add);

        // Тестируем с очень длинным текстом, который может вызвать ошибку
        final veryLongText = 'A' * 10000;
        ttsService.say(veryLongText);
        await Future.delayed(const Duration(milliseconds: 100));

        expect(events, contains('start'));
      });
    });

    group('Integration Tests', () {
      test('should work with multiple operations', () async {
        final events = <String>[];
        ttsService.events.listen(events.add);

        // Устанавливаем настройки
        await ttsService.setVolume(0.8);
        await ttsService.setRate(1.2);
        await ttsService.setVoice('oksana');

        // Проверяем настройки
        final volume = await ttsService.getVolume();
        final rate = await ttsService.getRate();
        final voice = await ttsService.getSelectedVoice();

        expect(volume, equals(0.8));
        expect(rate, equals(1.2));
        expect(voice.voiceURI, equals('oksana'));

        // Тестируем воспроизведение
        ttsService.say('Тест интеграции');
        await Future.delayed(const Duration(milliseconds: 100));

        expect(events, contains('start'));
      });
    });
  });
}
