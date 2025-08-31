# TTS Модуль для Flutter

Модуль текстового преобразования в речь с поддержкой offline и online режимов.

## Возможности

- **Offline режим**: Использование встроенных голосов системы
- **Online режим**: Использование Яндекс TTS API
- Настройка громкости, скорости и тона
- Выбор голоса из доступных
- Скачивание аудиофайлов
- Сохранение настроек

## Установка зависимостей

Добавьте в pubspec.yaml:

```yaml
dependencies:
  flutter_tts: ^3.8.5
  audioplayers: ^5.2.1
  path_provider: ^2.1.1
  http: ^1.1.0
  shared_preferences: ^2.2.2
```

## Использование

### Базовое использование

```dart
import 'package:your_app/services/tts_service.dart';

final ttsService = TTSService.instance;

// Озвучить текст
await ttsService.say('Привет, мир!');

// Остановить воспроизведение
await ttsService.stop();
```

### Настройка параметров

```dart
// Громкость (0.0 - 1.0)
await ttsService.setVolume(0.8);

// Скорость (0.1 - 2.0)
await ttsService.setRate(1.2);

// Тон (0.5 - 2.0)
await ttsService.setPitch(1.1);

// Переключение между режимами
await ttsService.setUseYandex(true); // Яндекс TTS
await ttsService.setUseYandex(false); // Offline TTS
```

### Выбор голоса

```dart
// Получить список доступных голосов
final offlineVoices = await ttsService.getOfflineVoices();
final yandexVoices = ttsService.getYandexVoices();

// Установить голос
await ttsService.setVoice('zahar'); // Яндекс голос
await ttsService.setVoice('com.google.android.tts:ru-ru-x-ism-local'); // Offline голос
```

### События

```dart
ttsService.events.listen((event) {
  switch (event) {
    case 'start':
      print('Начало воспроизведения');
      break;
    case 'end':
      print('Конец воспроизведения');
      break;
    default:
      if (event.startsWith('error:')) {
        print('Ошибка: ${event.substring(6)}');
      }
  }
});
```

### Скачивание аудио

```dart
// Скачать аудиофайл
await ttsService.say('Текст для скачивания', download: true);
```

## Доступные голоса

### Яндекс голоса
- zahar (Захар)
- ermil (Емиль)
- jane (Джейн)
- oksana (Оксана)
- alena (Алёна)
- filipp (Филипп)
- omazh (Ома)

### Offline голоса
Зависят от системы и доступных языковых пакетов.

## Настройки Android

Добавьте разрешения в android/app/src/main/AndroidManifest.xml:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

## API Endpoint

Для онлайн режима используется:
- URL: https://tts.linka.su/tts
- Метод: POST
- Content-Type: application/json
- Body: {"text": "текст", "voice": "голос"}

## Сохранение настроек

Все настройки автоматически сохраняются в SharedPreferences:
- volume: громкость
- rate: скорость
- pitch: тон
- yandex: режим (true/false)
- voiceuri: выбранный голос

## Очистка ресурсов

```dart
@override
void dispose() {
  ttsService.dispose();
  super.dispose();
}
```
