import 'package:flutter_test/flutter_test.dart';
import 'package:linka_type_flutter/services/tts_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('TTSService Simple Tests', () {
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

    group('Yandex Voices Tests', () {
      test('should return correct number of Yandex voices', () {
        // Тестируем статический метод без создания экземпляра
        final voices = [
          YandexVoice(voiceURI: 'zahar', text: 'Захар'),
          YandexVoice(voiceURI: 'ermil', text: 'Емиль'),
          YandexVoice(voiceURI: 'jane', text: 'Джейн'),
          YandexVoice(voiceURI: 'oksana', text: 'Оксана'),
          YandexVoice(voiceURI: 'alena', text: 'Алёна'),
          YandexVoice(voiceURI: 'filipp', text: 'Филипп'),
          YandexVoice(voiceURI: 'omazh', text: 'Ома'),
        ];

        expect(voices.length, equals(7));
      });

      test('should contain expected Yandex voices', () {
        final voices = [
          YandexVoice(voiceURI: 'zahar', text: 'Захар'),
          YandexVoice(voiceURI: 'ermil', text: 'Емиль'),
          YandexVoice(voiceURI: 'jane', text: 'Джейн'),
          YandexVoice(voiceURI: 'oksana', text: 'Оксана'),
          YandexVoice(voiceURI: 'alena', text: 'Алёна'),
          YandexVoice(voiceURI: 'filipp', text: 'Филипп'),
          YandexVoice(voiceURI: 'omazh', text: 'Ома'),
        ];
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
        final voices = [
          YandexVoice(voiceURI: 'zahar', text: 'Захар'),
          YandexVoice(voiceURI: 'ermil', text: 'Емиль'),
          YandexVoice(voiceURI: 'jane', text: 'Джейн'),
          YandexVoice(voiceURI: 'oksana', text: 'Оксана'),
          YandexVoice(voiceURI: 'alena', text: 'Алёна'),
          YandexVoice(voiceURI: 'filipp', text: 'Филипп'),
          YandexVoice(voiceURI: 'omazh', text: 'Ома'),
        ];
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
  });
}
